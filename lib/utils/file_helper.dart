import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<String> saveImagePermanently(String tempPath) async {
    final dir = await getApplicationDocumentsDirectory();

    final fileName =
        'photo_${DateTime.now().millisecondsSinceEpoch}${p.extension(tempPath)}';

    final newPath = p.join(dir.path, fileName);

    final newImage = await File(tempPath).copy(newPath);
    return newImage.path;
  }
}
