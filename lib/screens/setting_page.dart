import 'package:flutter/material.dart';
import 'home_page.dart';
import 'date_page.dart';
import 'camera_page.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  static const double horizontalPadding = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// ================= BACKGROUND GRADIENT =================
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF403289), Color(0xFF4354A6)],
              ),
            ),
          ),

          /// ================= CONTENT =================
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  /// ================= HEADER =================
                  Center(
                    child: Column(
                      children: const [
                        Text(
                          'Pengaturan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Kelola aplikasi & preferensi kamu',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// ================= APP INFO =================
                  _GlassCard(
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/logo_app.png',
                            width: 96,
                            height: 96,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SizedBox(height: 13),
                                Text(
                                  'Journee',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Photo Journal with Location',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Versi 1.1.0',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// ================= PREFERENCES =================
                  const SizedBox(height: 20),
                  _sectionTitle('Preferensi'),

                  _GlassCard(
                    child: Column(
                      children: const [
                        _SettingItem(
                          icon: Icons.location_on_outlined,
                          title: 'Lokasi Otomatis',
                          subtitle: 'Simpan koordinat saat mengambil foto',
                        ),
                        _Divider(),
                        _SettingItem(
                          icon: Icons.cloud_outlined,
                          title: 'Simpan ke Cloud',
                          subtitle: 'Upload otomatis ke Cloudinary',
                        ),
                        _Divider(),
                        _SettingItem(
                          icon: Icons.photo_camera_outlined,
                          title: 'Kualitas Foto',
                          subtitle: 'Resolusi tinggi',
                        ),
                        _Divider(),
                        _SettingItem(
                          icon: Icons.dark_mode_outlined,
                          title: 'Tema',
                          subtitle: 'Coming soon',
                        ),
                      ],
                    ),
                  ),

                  /// ================= PRIVACY =================
                  const SizedBox(height: 20),
                  _sectionTitle('Privasi & Penyimpanan'),

                  _GlassCard(
                    child: Column(
                      children: const [
                        _SettingItem(
                          icon: Icons.storage_outlined,
                          title: 'Cache Foto',
                          subtitle: 'Kelola penyimpanan lokal',
                        ),
                        _Divider(),
                        _SettingItem(
                          icon: Icons.delete_outline,
                          title: 'Hapus Data Lokal',
                          subtitle: 'Tidak menghapus data cloud',
                          danger: true,
                        ),
                      ],
                    ),
                  ),

                  /// ================= ABOUT =================
                  const SizedBox(height: 20),
                  _sectionTitle('Tentang'),

                  _GlassCard(
                    child: Column(
                      children: const [
                        _SettingItem(
                          icon: Icons.info_outline,
                          title: 'Tentang Aplikasi',
                          subtitle: 'Informasi & tujuan aplikasi',
                        ),
                        _Divider(),
                        _SettingItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Kebijakan Privasi',
                          subtitle: 'Privasi pengguna',
                        ),
                        _Divider(),
                        _SettingItem(
                          icon: Icons.email_outlined,
                          title: 'Kontak Developer',
                          subtitle: 'support@journee.app',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ================= BOTTOM NAV =================
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: _BottomNav(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= SECTION TITLE =================
Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}


/// ================= GLASS CARD =================
class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.12),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
          ),
        ),
        child: child,
      ),
    );
  }
}


/// ================= SETTING ITEM =================
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: danger ? Colors.redAccent : Colors.white, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: danger ? Colors.redAccent : Colors.white,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ================= DIVIDER =================
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(height: 1, color: Colors.white.withOpacity(0.2)),
    );
  }
}

/// ================= BOTTOM NAV =================
Widget _BottomNav(BuildContext context) {
  return Container(
    height: 67,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(34),
      gradient: const LinearGradient(
        colors: [Color(0xFF4C62BA), Color(0xFF5F8BC2), Color(0xFF4C95BA)],
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
          child: Image.asset('assets/images/icon_book.png', width: 28),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraPage()),
            );
          },
          child: Image.asset('assets/images/icon_star.png', width: 24),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DatePage()),
            );
          },
          child: Image.asset('assets/images/icon_calendar.png', width: 22),
        ),
        Image.asset('assets/images/icon_setting_f.png', width: 24),
      ],
    ),
  );
}
