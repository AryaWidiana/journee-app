import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../models/photo_model.dart';

class PhotoRepository {
  static final Box<PhotoModel> _box =
      Hive.box<PhotoModel>('photosBox');

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static List<PhotoModel> photos = [];

  /// LOAD DATA DARI HIVE
  static void loadPhotos() {
    photos = _box.values.toList().reversed.toList();
  }

  /// SIMPAN FOTO
  static Future<void> addPhoto(PhotoModel photo) async {
    // Simpan ke Hive
    await _box.add(photo);

    // Simpan ke Firestore
    await _firestore.collection('photos').add({
      'imagePath': photo.imagePath,
      'description': photo.description,
      'latitude': photo.latitude,
      'longitude': photo.longitude,
      'createdAt': FieldValue.serverTimestamp(),
    });

    loadPhotos();
  }

  /// DELETE FOTO
  static Future<void> deletePhoto(int index) async {
    final photo = photos[index];

    /// 1. hapus file fisik
    final file = File(photo.imagePath);
    if (await file.exists()) {
      await file.delete();
    }

    /// 2. hapus dari Hive
    final hiveIndex =
        _box.length - 1 - index; // karena reversed
    await _box.deleteAt(hiveIndex);

    /// 3. hapus dari Firestore (berdasarkan imagePath)
    final query = await _firestore
        .collection('photos')
        .where('imagePath', isEqualTo: photo.imagePath)
        .get();

    for (final doc in query.docs) {
      await doc.reference.delete();
    }

    loadPhotos();
  }

  /// UPDATE DESKRIPSI
  static Future<void> updateDescription({
    required int index,
    required String description,
  }) async {
    final oldPhoto = photos[index];

    final updatedPhoto = oldPhoto.copyWith(
      description: description,
    );

    /// update Hive
    final hiveIndex =
        _box.length - 1 - index; // karena reversed
    await _box.putAt(hiveIndex, updatedPhoto);

    /// update Firestore
    final query = await _firestore
        .collection('photos')
        .where('imagePath', isEqualTo: oldPhoto.imagePath)
        .get();

    for (final doc in query.docs) {
      await doc.reference.update({
        'description': description,
      });
    }

    loadPhotos();
  }
}
