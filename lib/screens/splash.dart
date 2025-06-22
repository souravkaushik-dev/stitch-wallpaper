import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import to control system UI

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Set the transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Make status bar transparent
        statusBarIconBrightness: Brightness.light, // Set icons to light or dark based on preference
      ),
    );

    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Infinite scrolling wallpaper
          Positioned.fill(
            child: Row(
              children: [
                // First Column (moves upward)
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_controller.value * 400), // Move upward
                        child: buildColumn(0), // Build first column
                      );
                    },
                  ),
                ),
                // Second Column (moves downward)
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _controller.value * 400), // Move downward
                        child: buildColumn(1), // Build second column
                      );
                    },
                  ),
                ),
                // Third Column (moves upward)
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_controller.value * 400), // Move upward
                        child: buildColumn(2), // Build third column
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Blurred background for the text
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.2), // Optional dark overlay
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'stitch',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Display'
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Dot Your Walls with Style.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the home screen
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Text(' Start Dotting.',
                        style: TextStyle(
                          fontSize: 15,
                            fontFamily: 'Display'
                        ),),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build each column
  Widget buildColumn(int columnIndex) {
    return Stack(
      children: [
        // First set of images
        GridView.count(
          crossAxisCount: 1, // Only one item per row
          physics: NeverScrollableScrollPhysics(), // Prevent scrolling
          children: List.generate(8, (index) {
            return buildImage(columnIndex * 8 + index);
          }),
        ),
        // Second set of images for infinite effect
        Positioned(
          top: 400, // Change this value to match the height of your grid items
          child: GridView.count(
            crossAxisCount: 1, // Only one item per row
            physics: NeverScrollableScrollPhysics(), // Prevent scrolling
            children: List.generate(8, (index) {
              return buildImage(columnIndex * 8 + index);
            }),
          ),
        ),
      ],
    );
  }

  // Function to build individual images
  Widget buildImage(int index) {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage('assets/wallpaper$index.jpg'), // Your asset images
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
