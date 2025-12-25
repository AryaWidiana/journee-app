import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'dyuycqyey';
  static const String uploadPreset = 'journee';

  static Future<String?> uploadImage(File imageFile) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    request.fields['upload_preset'] = uploadPreset;

    final response = await request.send();

    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final data = json.decode(resBody);
      return data['secure_url'];
    } else {
      return null;
    }
  }
}
