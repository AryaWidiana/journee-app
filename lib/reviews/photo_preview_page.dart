import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../repositorys/photo_repository.dart';

class PhotoPreviewPage extends StatefulWidget {
  final String imagePath;
  final double lat;
  final double lng;

  const PhotoPreviewPage({
    super.key,
    required this.imagePath,
    required this.lat,
    required this.lng,
  });

  @override
  State<PhotoPreviewPage> createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends State<PhotoPreviewPage> {
  final TextEditingController _descController = TextEditingController();
  static const int maxWords = 30;

  int _wordCount(String text) =>
      text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF202523),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.9,
              ),
              child: _contentContainer(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _contentContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF202523),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: widget.imagePath.startsWith('http')
                ? Image.network(
                    widget.imagePath,
                    height: 406,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(widget.imagePath),
                    height: 406,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(height: 12),

          // DESCRIPTION INPUT
          TextField(
            controller: _descController,
            maxLines: null,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: 'Isi deskripsi di sini',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              counterStyle: const TextStyle(color: Colors.white54),
            ),
            onChanged: (value) {
              if (_wordCount(value) > maxWords) {
                final words = value
                    .trim()
                    .split(RegExp(r'\s+'))
                    .take(maxWords)
                    .join(' ');
                _descController.text = words;
                _descController.selection = TextSelection.fromPosition(
                  TextPosition(offset: words.length),
                );
              }
              setState(() {});
            },
          ),

          const SizedBox(height: 6),

          // WORD COUNTER
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_wordCount(_descController.text)}/$maxWords kata',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          const SizedBox(height: 16),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  text: 'Batal',
                  color: Colors.grey.shade800,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  text: 'Simpan',
                  color: const Color(0xFF9B8CFF),
                  onTap: _savePhoto,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _savePhoto() async {
    // Simpan langsung URL atau path
    final photo = PhotoModel(
      imagePath: widget.imagePath, // URL Cloudinary atau lokal
      description: _descController.text,
      latitude: widget.lat,
      longitude: widget.lng,
      createdAt: DateTime.now(),
    );

    await PhotoRepository.addPhoto(photo);

    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins-Medium',
          ),
        ),
      ),
    );
  }
}
