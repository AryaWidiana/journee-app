import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'screens/opening_screen.dart';
import 'models/photo_model.dart';
import '../repositorys/photo_repository.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// INIT HIVE
  await Hive.initFlutter();
  Hive.registerAdapter(PhotoModelAdapter());
  await Hive.openBox<PhotoModel>('photosBox');
  PhotoRepository.loadPhotos();

  /// INIT DATE FORMAT
  await initializeDateFormatting('id_ID', null);

  /// INIT FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journee',
      debugShowCheckedModeBanner: false,
      home: const OpeningScreen(),
    );
  }
}
