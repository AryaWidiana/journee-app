import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../repositorys/photo_repository.dart';
import '../models/photo_model.dart';
import 'home_page.dart';
import 'camera_page.dart';
import 'setting_page.dart';
import 'package:geocoding/geocoding.dart';

class DatePage extends StatefulWidget {
  const DatePage({super.key});

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<PhotoModel> _photosOfSelectedDay = [];

  PhotoModel? _selectedPhoto;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _filterPhotosByDate(_selectedDay!);
  }

  void _filterPhotosByDate(DateTime date) {
    _photosOfSelectedDay = PhotoRepository.photos.where((photo) {
      final photoDate = photo.createdAt;
      return photoDate.year == date.year &&
          photoDate.month == date.month &&
          photoDate.day == date.day;
    }).toList();
    setState(() {});
  }

  Map<DateTime, List<PhotoModel>> _getEventMap() {
    Map<DateTime, List<PhotoModel>> map = {};
    for (var photo in PhotoRepository.photos) {
      final date = DateTime(
        photo.createdAt.year,
        photo.createdAt.month,
        photo.createdAt.day,
      );
      if (map[date] == null) {
        map[date] = [photo];
      } else {
        map[date]!.add(photo);
      }
    }
    return map;
  }

  /// ================= GET CITY =================
  Future<String> _getCity(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return [
          p.subAdministrativeArea,
          p.locality,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }
    } catch (_) {}
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventMap();

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

          /// ================= MOUNTAIN & TREES =================
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

          /// ================= CALENDAR TITLE =================
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Calendar',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),

          /// ================= CALENDAR + FOTO GRID =================
          Positioned.fill(
            top: 120,
            bottom: 120,
            child: Column(
              children: [
                /// ================= TABLE CALENDAR =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _filterPhotosByDate(selectedDay);
                        });
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        leftChevronVisible: false,
                        rightChevronVisible: false,
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                        weekendStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        weekendTextStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                        todayTextStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        selectedTextStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        todayDecoration: const BoxDecoration(
                          color: Color(0xFF8E7EFF),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        outsideDaysVisible: false,
                      ),
                      calendarBuilders: CalendarBuilders(
                        headerTitleBuilder: (context, day) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _focusedDay = DateTime(
                                      _focusedDay.year,
                                      _focusedDay.month - 1,
                                    );
                                  });
                                },
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              Text(
                                DateFormat('MMMM yyyy', 'en_US').format(day),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _focusedDay = DateTime(
                                      _focusedDay.year,
                                      _focusedDay.month + 1,
                                    );
                                  });
                                },
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          );
                        },
                        markerBuilder: (context, date, _) {
                          final dayKey = DateTime(
                            date.year,
                            date.month,
                            date.day,
                          );
                          if (events.containsKey(dayKey)) {
                            return Positioned(
                              bottom: 4,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// ================= FOTO GRID =================
                Expanded(
                  child: _photosOfSelectedDay.isEmpty
                      ? const Center(
                          child: Text(
                            'No photos on this day',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.70,
                          ),
                          itemCount: _photosOfSelectedDay.length,
                          itemBuilder: (context, index) {
                            final photo = _photosOfSelectedDay[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPhoto = photo;
                                  _selectedIndex = index;
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: photo.imagePath.startsWith('http')
                                    ? Image.network(
                                        photo.imagePath,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(photo.imagePath),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          /// ================= OVERLAY DETAIL =================
          if (_selectedPhoto != null) _overlayDetail(),

          /// ================= BOTTOM NAV =================
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Container(
              height: 67,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4C62BA),
                    Color(0xFF5F8BC2),
                    Color(0xFF4C95BA),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                      );
                    },
                    child: Image.asset(
                      'assets/images/icon_book.png',
                      width: 28,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CameraPage()),
                      );
                    },
                    child: Image.asset(
                      'assets/images/icon_star.png',
                      width: 24,
                    ),
                  ),
                  Image.asset('assets/images/icon_calendar_f.png', width: 22),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingPage()),
                      );
                    },
                    child: Image.asset(
                      'assets/images/icon_setting.png',
                      width: 24,
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

  /// ================= OVERLAY DETAIL (SAMA SEPERTI HOME) =================
  Widget _overlayDetail() {
    final photo = _selectedPhoto!;

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedPhoto = null;
          _selectedIndex = null;
        }),
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
                                _filterPhotosByDate(_selectedDay!);
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
                                _filterPhotosByDate(_selectedDay!);
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
}
