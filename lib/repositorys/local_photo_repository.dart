import 'package:hive/hive.dart';
import '../models/photo_model.dart';

class LocalPhotoRepository {
  static final Box<PhotoModel> _box =
      Hive.box<PhotoModel>('photosBox');

  static List<PhotoModel> getAllPhotos() {
    return _box.values.toList().reversed.toList();
  }

  static Future<void> addPhoto(PhotoModel photo) async {
    await _box.add(photo);
  }
}
