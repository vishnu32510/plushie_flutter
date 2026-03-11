import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:plushie_yourself/core/services/services.dart';

class UsageService extends Services {
  static const int freeLimit = 5;
  static File? _file;

  static Future<File> _getFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/usage.json');
    return _file!;
  }

  static Future<Map<String, dynamic>> _readData() async {
    final file = await _getFile();
    if (!await file.exists()) return {};
    try {
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<void> _writeData(Map<String, dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }

  static Future<int> getCount(String uid) async {
    final data = await _readData();
    return (data[uid] as int?) ?? 0;
  }

  static Future<bool> canGenerate(String uid) async {
    return (await getCount(uid)) < freeLimit;
  }

  static Future<void> increment(String uid) async {
    final data = await _readData();
    data[uid] = ((data[uid] as int?) ?? 0) + 1;
    await _writeData(data);
  }
}
