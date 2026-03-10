import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:plushie_yourself/core/services/services.dart';

class PlushieStorageService extends Services {
  static Directory? _dir;

  static Future<Directory> _getDir() async {
    if (_dir != null) return _dir!;
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/plushies');
    if (!await dir.exists()) await dir.create(recursive: true);
    _dir = dir;
    return dir;
  }

  static Future<String> save(Uint8List bytes) async {
    final dir = await _getDir();
    final path =
        '${dir.path}/plushie_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(path).writeAsBytes(bytes);
    return path;
  }

  static Future<List<File>> loadAll() async {
    final dir = await _getDir();
    final entities = await dir.list().toList();
    final files = entities.whereType<File>().toList();
    files.sort((a, b) => b.path.compareTo(a.path)); // newest first
    return files;
  }

  static Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
