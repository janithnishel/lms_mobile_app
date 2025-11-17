import 'package:flutter/material.dart';
import 'dart:async';

import 'package:lms_app/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 💡 App Loading Logic
    // _initializeApp();
    // Animation controller (controls time)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // animation time
    )..repeat(reverse: true); // repeat zoom in & out

    // Define animation range (scale size)
    _animation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Optional: After splash, navigate to next screen
    // Timer(const Duration(seconds: 4), () {
    //   // Navigator.pushReplacement(...)
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

 

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final isTablet = screenWidth > 600;

    final logoSize = isTablet ? screenWidth * 0.25 : screenWidth * 0.45;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: ScaleTransition(
        scale: _animation, 
        child: Center(
          child: Image.asset(
            "assets/images/splash_logo.png",
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
