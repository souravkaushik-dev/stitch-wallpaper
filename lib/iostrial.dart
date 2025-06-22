import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass/liquid_glass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stitch/screens/home_screen.dart';

 // Import your actual home screen widget

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;
  final TextEditingController _nameController = TextEditingController();
  bool _showTextField = false;

  @override
  void initState() {
    super.initState();
    _checkIfNameExists();
  }


  Future<void> _checkIfNameExists() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');

    if (name != null && name.isNotEmpty) {
      // Skip splash if name already exists
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Initialize animation controller here
      _fadeController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );

      _fadeAnimation = CurvedAnimation(
        parent: _fadeController!,
        curve: Curves.easeInOut,
      );

      _fadeController!.forward();
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _showTextField = true;
        });
      });
    }
  }


  @override
  void dispose() {
    _fadeController?.dispose();
    _nameController.dispose();
    super.dispose();
  }




  Future<void> _submitName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text.trim());

    HapticFeedback.lightImpact();

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Home screen as background
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: WallpaperHomePage(), // Replace with your home screen
            ),
          ),

          // ✅ Apply blur over background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          // ✅ Center text with fade-in
          Center(
            child: _fadeAnimation != null
                ? FadeTransition(
              opacity: _fadeAnimation!,
              child: Text(
                'Stitch welcomes you',
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            )
                : const SizedBox(), // Or a loader / empty space
          ),

          // ✅ Skip Button
          if (_fadeAnimation != null)
            Positioned(
              top: 40,
              left: 20,
              child: FadeTransition(
                opacity: _fadeAnimation!,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),

          // ✅ Name input (bottom)
          if (_showTextField)
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: LiquidGlass(
                opacity: 0.2,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _nameController,
                    style: GoogleFonts.roboto(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: GoogleFonts.roboto(
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        onPressed: _submitName,
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submitName(),
                  ),
                ),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
