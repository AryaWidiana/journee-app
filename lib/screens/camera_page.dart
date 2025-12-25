import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

import '../reviews/photo_preview_page.dart';
import '../services/cloudinary_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _flashOn = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    /// 🔒 LOCK ORIENTATION → PORTRAIT ONLY
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _switchCamera() async {
    _cameraIndex = _cameraIndex == 0 ? 1 : 0;
    _flashOn = false;
    await _controller?.dispose();
    await _initCamera();
  }

  Future<void> _toggleFlash() async {
    _flashOn = !_flashOn;
    await _controller?.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  /// 📍 Ambil lokasi device
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission lokasi ditolak');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    final XFile file = await _controller!.takePicture();

    final url = await CloudinaryService.uploadImage(File(file.path));

    if (url != null) {
      Position position = await _getCurrentLocation();
      _openPreview(url, position.latitude, position.longitude);
    }
  }

  /// 📂 Upload dari galeri
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    final url = await CloudinaryService.uploadImage(File(image.path));

    if (url != null) {
      Position position = await _getCurrentLocation();
      _openPreview(url, position.latitude, position.longitude);
    }
  }

  void _openPreview(String path, double lat, double lng) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PhotoPreviewPage(imagePath: path, lat: lat, lng: lng),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();

    /// 🔓 RESTORE ORIENTATION NORMAL
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// ================= CAMERA PREVIEW (NO STRETCH) =================
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            ),
          ),

          /// ================= BACK =================
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset('assets/icons/back.png', width: 50),
            ),
          ),

          /// ================= BOTTOM BAR =================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 130,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF202523),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// 📂 GALERI
                  GestureDetector(
                    onTap: _pickFromGallery,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// 📸 SHUTTER
                  GestureDetector(
                    onTap: _takePicture,
                    child: Image.asset('assets/icons/camera.png', width: 75),
                  ),

                  const SizedBox(width: 27),

                  /// ⚡ FLASH
                  GestureDetector(
                    onTap: _toggleFlash,
                    child: Image.asset('assets/icons/flash.png', width: 22),
                  ),

                  const SizedBox(width: 40),

                  /// 🔄 SWITCH CAMERA
                  GestureDetector(
                    onTap: _switchCamera,
                    child: Image.asset(
                      'assets/icons/switch_camera.png',
                      width: 33,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
