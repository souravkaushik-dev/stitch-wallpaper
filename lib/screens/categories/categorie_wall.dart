import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stitch/screens/categories/catgories_grid.dart';

import '../full_screen.dart';  // Keep this import

class CategoryWallpapersPage extends StatelessWidget {
  final String category;
  final List<WallpaperInfo> wallpapers;

  CategoryWallpapersPage({required this.category, required this.wallpapers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar
          SliverAppBar(
            expandedHeight: 200.0,  // Adjusted height for a longer app bar
            floating: false,
            pinned: true,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                bool isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;
                double roundedCorner = isCollapsed ? 20.0 : 30.0;

                return FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: EdgeInsets.only(
                    top: isCollapsed ? 0.0 : 80.0,
                    left: 16.0,
                  ),
                  title: Align(
                    alignment: isCollapsed ? Alignment.centerLeft : Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: isCollapsed ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                        children: [
                          Text(
                            category.capitalize(),
                            style: TextStyle(
                              fontFamily: 'sand', // Replace with your custom font family
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  background: Stack(
                    children: [
                      // Only show the glassmorphism effect when the SliverAppBar is collapsed
                      if (isCollapsed)
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Frosted glass effect
                            child: Container(
                              color: Colors.white.withOpacity(0.1), // Semi-transparent overlay
                            ),
                          ),
                        ),
                      // Transparent background when not collapsed
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(roundedCorner),
                          ),
                          color: Colors.transparent, // Ensures the background remains transparent
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),
          // SliverGrid for Wallpapers in 2 columns with increased height
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final wallpaper = wallpapers[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      final selectedWallpaper = wallpapers[index].imageUrl; // Fix here
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenWallpaperPreview(wallpaperUrl: selectedWallpaper),
                        ),
                      );
                    },

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        wallpaper.imageUrl,  // Adjust this based on your Wallpaper model
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
              childCount: wallpapers.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,  // Two columns
              crossAxisSpacing: 7.0,
              mainAxisSpacing: 7.0,
              childAspectRatio: 0.75,  // Reduced ratio to make items taller
            ),
          ),
        ],
      ),
    );
  }
}
