import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

import '../repositorys/photo_repository.dart';
import '../models/photo_model.dart';
import 'camera_page.dart';
import 'date_page.dart';
import 'setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PhotoModel? _selectedPhoto;
  int? _selectedIndex;

  /// ================= GET CITY =================
  Future<String> _getCity(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return [
          p.subAdministrativeArea,
          p.locality,
        ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
      }
    } catch (_) {}
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const horizontalPadding = 16.0;

    return Scaffold(
      body: Stack(
        children: [
          /// ================= BACKGROUND =================
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF4C62BA),
                  Color(0xFF5F8BC2),
                  Color(0xFF4C95BA),
                ],
              ),
            ),
          ),

          /// ================= CLOUDS =================
          Positioned(
            left: -50,
            top: 0,
            child: Image.asset('assets/images/cloud_left.png', width: 200),
          ),
          Positioned(
            right: -50,
            top: 0,
            child: Image.asset('assets/images/cloud_right.png', width: 200),
          ),

          /// ================= DATE =================
          Positioned(
            top: 80,
            left: horizontalPadding,
            child: Text(
              DateFormat('EEE, dd MMMM yyyy', 'id_ID').format(now),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          /// ================= WEEK SELECTOR =================
          Positioned(
            top: 130,
            left: horizontalPadding,
            right: horizontalPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final offset = index - 3;
                final currentDay = now.add(Duration(days: offset));

                const daysLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                final dayLetter = daysLetters[currentDay.weekday % 7];

                final isToday =
                    currentDay.day == now.day &&
                    currentDay.month == now.month &&
                    currentDay.year == now.year;

                return Container(
                  width: 44,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(isToday ? 1 : 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayLetter,
                        style: TextStyle(
                          color: isToday ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${currentDay.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isToday ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          /// ================= BACKGROUND IMAGE =================
          Positioned(
            top: 260,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/mountain.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 310,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/trees.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          /// ================= CONTENT =================
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 120,
            child: PhotoRepository.photos.isEmpty
                ? _emptyState(context)
                : _photoGrid(),
          ),

          /// ================= OVERLAY (DETAIL PHOTO) =================
          if (_selectedPhoto != null) _overlayDetail(),

          /// ================= BOTTOM NAV =================
          _bottomNav(context),
        ],
      ),
    );
  }

  /// ================= EMPTY STATE =================
  Widget _emptyState(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CameraPage()),
        ),
        child: const CircleAvatar(
          radius: 38,
          backgroundColor: Color(0xFF9B8CFF),
          child: Icon(Icons.add, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  /// ================= PHOTO GRID =================
  Widget _photoGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: PhotoRepository.photos.length,
      itemBuilder: (_, index) {
        final photo = PhotoRepository.photos[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPhoto = photo;
              _selectedIndex = index;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: photo.imagePath.startsWith('http')
                ? Image.network(photo.imagePath, fit: BoxFit.cover)
                : Image.file(File(photo.imagePath), fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  /// ================= OVERLAY DETAIL =================
  Widget _overlayDetail() {
    final photo = _selectedPhoto!;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPhoto = null),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black54,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: AspectRatio(
                        aspectRatio: 4 / 5,
                        child: photo.imagePath.startsWith('http')
                            ? Image.network(photo.imagePath, fit: BoxFit.cover)
                            : Image.file(
                                File(photo.imagePath),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      photo.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoBox(
                      child: FutureBuilder<String>(
                        future: _getCity(photo.latitude, photo.longitude),
                        builder: (_, snap) {
                          return Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  snap.data ?? 'Loading...',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    _infoBox(
                      child: Center(
                        child: Text(
                          'Lat: ${photo.latitude}   Lng: ${photo.longitude}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.15),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final controller = TextEditingController(
                                text: _selectedPhoto!.description,
                              );
                              final result = await showDialog<String>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Edit description'),
                                  content: TextField(controller: controller),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(
                                        context,
                                        controller.text,
                                      ),
                                      child: const Text('Save'),
                                    ),
                                  ],
                                ),
                              );

                              if (result != null && _selectedIndex != null) {
                                await PhotoRepository.updateDescription(
                                  index: _selectedIndex!,
                                  description: result,
                                );
                                setState(() {
                                  _selectedPhoto = null;
                                  _selectedIndex = null;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.25),
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete photo'),
                                  content: const Text(
                                    'Are you sure want to delete?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && _selectedIndex != null) {
                                await PhotoRepository.deletePhoto(
                                  _selectedIndex!,
                                );
                                setState(() {
                                  _selectedPhoto = null;
                                  _selectedIndex = null;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  /// ================= BOTTOM NAV =================
  Widget _bottomNav(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: Container(
        height: 67,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: const LinearGradient(
            colors: [Color(0xFF4C62BA), Color(0xFF5F8BC2), Color(0xFF4C95BA)],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/images/icon_book_f.png', width: 28),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraPage()),
              ),
              child: Image.asset('assets/images/icon_star.png', width: 24),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DatePage()),
              ),
              child: Image.asset('assets/images/icon_calendar.png', width: 22),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingPage()),
              ),
              child: Image.asset('assets/images/icon_setting.png', width: 24),
            ),
          ],
        ),
      ),
    );
  }
}
