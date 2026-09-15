import 'dart:io';

void main() async {
  // Setup: Create 1000 temporary files
  final tempDir = await Directory.systemTemp.createTemp('plushie_benchmark_');
  final index = <String>[];

  print('Setting up 1000 files...');
  for (int i = 0; i < 1000; i++) {
    final file = File('${tempDir.path}/file_$i.txt');
    await file.writeAsString('test');
    index.add(file.path);
  }

  // Add some missing files to the index
  for (int i = 0; i < 200; i++) {
    index.add('${tempDir.path}/missing_$i.txt');
  }

  print('Total files in index: ${index.length}');

  // Benchmark 1: Sequential (Current Implementation)
  final sw1 = Stopwatch()..start();
  final files1 = <File>[];
  final cleanedPaths1 = <String>[];

  for (final path in index) {
    final file = File(path);
    if (await file.exists()) {
      files1.add(file);
      cleanedPaths1.add(path);
    }
  }
  sw1.stop();
  print('Sequential time: ${sw1.elapsedMilliseconds}ms');

  // Benchmark 2: Concurrent (Optimized Implementation)
  final sw2 = Stopwatch()..start();
  final files2 = <File>[];
  final cleanedPaths2 = <String>[];

  final existsResults = await Future.wait(
    index.map((path) => File(path).exists())
  );

  for (int i = 0; i < index.length; i++) {
    if (existsResults[i]) {
      files2.add(File(index[i]));
      cleanedPaths2.add(index[i]);
    }
  }
  sw2.stop();
  print('Concurrent time: ${sw2.elapsedMilliseconds}ms');

  // Verify same results
  print('Sequential found: ${files1.length}');
  print('Concurrent found: ${files2.length}');

  // Cleanup
  await tempDir.delete(recursive: true);
}
