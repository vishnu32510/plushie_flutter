import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:plushie_yourself/features/plushie/repository/openai_service.dart';

class FakeErrorFile extends Fake implements File {
  @override
  Future<Uint8List> readAsBytes() async {
    throw Exception('Simulated read error');
  }
}

void main() {
  group('OpenAIService Tests', () {
    test('transformToPlushie returns error when file read fails', () async {
      final service = OpenAIService(apiKey: 'dummy_key');
      final fakeFile = FakeErrorFile();

      final result = await service.transformToPlushie(imageFile: fakeFile);

      expect(result.isSuccess, isFalse);
      expect(result.error, equals('Could not read image file.'));
      expect(result.imageBytes, isNull);
    });
  });
}
