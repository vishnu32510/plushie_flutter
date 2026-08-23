import 'dart:io';
import 'dart:typed_data';

abstract class IPlushieService {
  Future<PlushieImageResult> transformToPlushie({
    required File imageFile,
  });
}

class PlushieImageResult {
  final Uint8List? imageBytes;
  final String? url;
  final String? error;

  const PlushieImageResult._({this.imageBytes, this.url, this.error});

  factory PlushieImageResult.success({Uint8List? imageBytes, String? url}) =>
      PlushieImageResult._(imageBytes: imageBytes, url: url);

  factory PlushieImageResult.error(String message) =>
      PlushieImageResult._(error: message);

  bool get isSuccess => error == null;
}

// Aliases for seamless backward compatibility
typedef OpenAIImageResult = PlushieImageResult;
typedef GeminiImageResult = PlushieImageResult;
