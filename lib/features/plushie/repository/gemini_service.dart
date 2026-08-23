import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:plushie_yourself/core/services/services.dart';
import 'package:plushie_yourself/core/utils/app_constants.dart';
import 'package:plushie_yourself/features/plushie/repository/plushie_service_interface.dart';
import 'dart:convert' as convert;

export 'plushie_service_interface.dart';

class GeminiService implements IPlushieService {
  final String _apiKey;
  final HttpServices _httpServices;

  GeminiService({required String apiKey})
    : _apiKey = apiKey,
      _httpServices = HttpServices(apiKey: apiKey);

  @override
  Future<PlushieImageResult> transformToPlushie({
    required File imageFile,
  }) async {
    if (_apiKey.trim().isEmpty) {
      return PlushieImageResult.error(
        'Gemini API key is not configured. Please set GEMINI_API_KEY in your .env file.',
      );
    }

    final Uint8List imageBytes;
    try {
      imageBytes = await imageFile.readAsBytes();
    } catch (_) {
      return PlushieImageResult.error('Could not read image file.');
    }

    final mimeType = _getMimeType(imageFile.path);
    final base64Image = convert.base64Encode(imageBytes);

    // Multimodal Image-to-Image Plushie transformation with Gemini Flash Image
    final geminiImageUrl = AppConstants.geminiImageUrl;
    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              },
            },
            {
              'text': AppConstants.plushiePrompt,
            },
          ],
        },
      ],
      'generationConfig': {
        'responseModalities': ['IMAGE'],
      },
    };

    // Use x-goog-api-key header (do not use Bearer auth for Google AI Studio API keys)
    final result = await _httpServices.postMethod(
      geminiImageUrl,
      requestBody,
      headers: {
        'x-goog-api-key': _apiKey,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      timeout: const Duration(minutes: 2),
    );

    if (result is ServiceError) {
      return PlushieImageResult.error(_errorMessage(result));
    }

    try {
      if (result is Map && result['candidates'] is List) {
        final candidates = result['candidates'] as List;
        if (candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          if (content is Map && content['parts'] is List) {
            final parts = content['parts'] as List;
            for (final part in parts) {
              if (part is Map) {
                final inlineData = part['inlineData'] ?? part['inline_data'];
                if (inlineData is Map && inlineData['data'] != null) {
                  final base64Data = inlineData['data'] as String;
                  final bytes = convert.base64Decode(base64Data);
                  return PlushieImageResult.success(imageBytes: bytes);
                }
              }
            }
          }
        }
      }

      // Check if API returned an error object
      if (result is Map && result['error'] != null) {
        final err = result['error'];
        final message = err['message'] as String? ?? 'Gemini API error';
        return PlushieImageResult.error(message);
      }

      debugPrint('Unexpected Gemini response structure: $result');
      return PlushieImageResult.error(
        'No image returned from Gemini. Please try again.',
      );
    } catch (e) {
      debugPrint('Gemini parse error: $e');
      return PlushieImageResult.error('Could not process image response.');
    }
  }

  String _getMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  String _errorMessage(ServiceError error) {
    switch (error) {
      case ServiceError.authError:
        return 'API access denied. Verify your Gemini API key in Google AI Studio (aistudio.google.com).';
      case ServiceError.rateLimitError:
        return 'Google AI image quota limit reached. Note: Google AI Studio image generation requires a linked billing account (Pay-As-You-Go) at aistudio.google.com.';
      case ServiceError.timeoutError:
        return 'Request timed out. Please try again.';
      case ServiceError.socketError:
        return 'Network error. Check your internet connection.';
      case ServiceError.clientError:
        return 'Invalid request or photo format. Please try a different photo.';
      case ServiceError.serverError:
        return 'Google AI server error. Please try again later.';
      default:
        return 'Something went wrong with Gemini transformation. Please try again.';
    }
  }
}
