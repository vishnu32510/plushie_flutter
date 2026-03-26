import 'dart:io';
import 'dart:typed_data';
import 'dart:convert' as convert;
import 'package:path_provider/path_provider.dart';
import 'package:plushie_yourself/core/services/services.dart';

class PlushieStorageService extends Services {
  static Directory? _dir;
  static const String _indexFileName = '.plushie_index.json';

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
    await _addToIndex(path);
    return path;
  }

  static Future<List<File>> loadAll() async {
    final dir = await _getDir();
    final index = await _readIndex();

    if (index == null) {
      // Migration: first run after index support, seed index from current files.
      final entities = await dir.list().toList();
      final files =
          entities
              .whereType<File>()
              .where((f) => !_isIndexFile(f))
              .toList()
            ..sort((a, b) => b.path.compareTo(a.path));
      await _writeIndex(files.map((f) => f.path).toList());
      return files;
    }

    final files = <File>[];
    final cleanedPaths = <String>[];
    for (final path in index) {
      final file = File(path);
      if (await file.exists()) {
        files.add(file);
        cleanedPaths.add(path);
      }
    }

    // Keep index in sync if files were removed externally.
    if (cleanedPaths.length != index.length) {
      await _writeIndex(cleanedPaths);
    }
    return files;
  }

  static Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
    await _removeFromIndex(path);
  }

  /// Clears visible gallery entries without deleting actual image files.
  static Future<void> clearVisibleEntries() async {
    await _writeIndex([]);
  }

  static File _indexFile(Directory dir) => File('${dir.path}/$_indexFileName');

  static bool _isIndexFile(File file) {
    final segments = file.uri.pathSegments;
    if (segments.isEmpty) return false;
    return segments.last == _indexFileName;
  }

  static Future<List<String>?> _readIndex() async {
    final dir = await _getDir();
    final file = _indexFile(dir);
    if (!await file.exists()) return null;
    try {
      final raw = await file.readAsString();
      final decoded = convert.jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded.whereType<String>().toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeIndex(List<String> paths) async {
    final dir = await _getDir();
    final file = _indexFile(dir);
    await file.writeAsString(convert.jsonEncode(paths));
  }

  static Future<void> _addToIndex(String path) async {
    final existing = await _readIndex() ?? [];
    if (existing.contains(path)) return;
    existing.insert(0, path);
    await _writeIndex(existing);
  }

  static Future<void> _removeFromIndex(String path) async {
    final existing = await _readIndex();
    if (existing == null) return;
    existing.remove(path);
    await _writeIndex(existing);
  }
}
