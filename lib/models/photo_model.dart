import 'package:hive/hive.dart';

part 'photo_model.g.dart';

@HiveType(typeId: 0)
class PhotoModel {
  @HiveField(0)
  final String imagePath;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final DateTime createdAt;

  PhotoModel({
    required this.imagePath,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

PhotoModel copyWith({
  String? description,
}) {
  return PhotoModel(
    imagePath: imagePath,
    description: description ?? this.description,
    latitude: latitude,
    longitude: longitude,
    createdAt: createdAt,
  );
}

  /// ✅ UNTUK FIRESTORE
  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
    };
  }
}

