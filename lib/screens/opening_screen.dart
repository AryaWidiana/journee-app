import 'package:flutter/material.dart';
import 'dart:async';

import 'home_page.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  late AnimationController _cloudController;
  late Animation<Offset> _cloudAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi logo (scale + fade)
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _logoController.forward();

    // Animasi awan (slide from bottom)
    _cloudController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _cloudAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // dari bawah
      end: const Offset(0, 0),   // posisi asli
    ).animate(CurvedAnimation(
      parent: _cloudController,
      curve: Curves.easeOut,
    ));

    _cloudController.forward();

    // Delay 5 detik, lalu pindah ke HomePage
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF403289),
              Color(0xFF4458AA),
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: ScaleTransition(
                scale: _logoAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 122,
                      height: 122,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Journee',
                      style: TextStyle(
                        fontFamily: 'Righteous',
                        fontSize: 32,
                        color: Color(0xFFFFD77A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _cloudAnimation,
                child: Image.asset(
                  'assets/images/cloud.png',
                  height: 91,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
