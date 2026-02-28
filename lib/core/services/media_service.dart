import 'dart:io';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plushie_yourself/core/services/services.dart';
import 'package:share_plus/share_plus.dart';

class MediaService extends Services {
  /// Saves [bytes] as a PNG to the device gallery.
  /// Returns an error message on failure, null on success.
  static Future<String?> saveToGallery(Uint8List bytes,
      {String prefix = 'plushie'}) async {
    try {
      final name = '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
      await Gal.putImageBytes(bytes, name: name);
      return null;
    } catch (_) {
      return 'Could not save. Please try again.';
    }
  }

  /// Shares [bytes] as a PNG via the native share sheet.
  /// Returns an error message on failure, null on success.
  static Future<String?> shareImage(Uint8List bytes, {String? text}) async {
    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${DateTime.now().millisecondsSinceEpoch}.png';
      await File('${dir.path}/$path').writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile('${dir.path}/$path', mimeType: 'image/png')],
        text: text,
      );
      return null;
    } catch (_) {
      return 'Could not share. Please try again.';
    }
  }
}
