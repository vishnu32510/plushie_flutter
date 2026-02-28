import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:plushie_yourself/core/services/services.dart';
import 'package:plushie_yourself/core/utils/app_constants.dart';
import 'dart:convert' as convert;

class OpenAIService {
  final HttpServices _httpServices;

  OpenAIService({required String apiKey})
      : _httpServices = HttpServices(apiKey: apiKey);

  Future<OpenAIImageResult> transformToPlushie({
    required File imageFile,
  }) async {
    final Uint8List imageBytes;
    try {
      imageBytes = await imageFile.readAsBytes();
    } catch (_) {
      return OpenAIImageResult.error('Could not read image file.');
    }

    final mimeType = _getMimeType(imageFile.path);
    final base64Image = convert.base64Encode(imageBytes);

    final body = {
      'model': 'gpt-4o',
      'tools': [
        {
          'type': 'image_generation',
          'quality': 'medium',
          'size': '1024x1024',
          'output_format': 'png',
        }
      ],
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_image',
              'image_url': 'data:$mimeType;base64,$base64Image',
            },
            {
              'type': 'input_text',
              'text': AppConstants.plushiePrompt,
            },
          ],
        },
      ],
    };

    final result = await _httpServices.postMethod(
      AppConstants.openAiResponsesUrl,
      body,
      timeout: const Duration(minutes: 3),
    );

    if (result is ServiceError) {
      return OpenAIImageResult.error(_errorMessage(result));
    }

    try {
      final output = result['output'] as List;
      for (final item in output) {
        if (item['type'] == 'image_generation_call') {
          final bytes = convert.base64Decode(item['result'] as String);
          return OpenAIImageResult.success(imageBytes: bytes);
        }
      }
      debugPrint('No image_generation_call in output: $output');
      return OpenAIImageResult.error('No image returned. Please try again.');
    } catch (e) {
      debugPrint('Parse error: $e');
      return OpenAIImageResult.error('Could not process image response.');
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
        return 'API access denied. Verify your OpenAI org at platform.openai.com.';
      case ServiceError.timeoutError:
        return 'Request timed out. Please try again.';
      case ServiceError.socketError:
        return 'Network error. Check your connection.';
      case ServiceError.clientError:
        return 'Invalid request. Please try again.';
      case ServiceError.serverError:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

class OpenAIImageResult {
  final Uint8List? imageBytes;
  final String? url;
  final String? error;

  const OpenAIImageResult._({this.imageBytes, this.url, this.error});

  factory OpenAIImageResult.success({Uint8List? imageBytes, String? url}) =>
      OpenAIImageResult._(imageBytes: imageBytes, url: url);

  factory OpenAIImageResult.error(String message) =>
      OpenAIImageResult._(error: message);

  bool get isSuccess => error == null;
}
