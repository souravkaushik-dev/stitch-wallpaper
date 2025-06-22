import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:m3_carousel/m3_carousel.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../full_screen.dart';

class FavoriteWallpapersPage extends StatefulWidget {
  @override
  _FavoriteWallpapersPageState createState() =>
      _FavoriteWallpapersPageState();
}

class _FavoriteWallpapersPageState extends State<FavoriteWallpapersPage> {
  List<String> favoriteWallpapers = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteWallpapers();
  }

  // Load favorite wallpapers from SharedPreferences
  Future<void> _loadFavoriteWallpapers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteWallpapers =
          prefs.getStringList('favorite_wallpapers') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
         SliverAppBar(
        expandedHeight: 160.0,
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
                        'stitched',
                        style: TextStyle(
                          fontFamily: 'sand',
                          fontSize: isCollapsed ? 24.0 : 42.0,
  // Using dynamic color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              background: Stack(
                children: [
                  if (isCollapsed)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
 // Dynamic background color
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(roundedCorner),
                      ),
                      color: Colors.transparent,
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                // Split the wallpapers into groups of 5.
                final startIndex = index * 5;
                final endIndex = (startIndex + 5) > favoriteWallpapers.length
                    ? favoriteWallpapers.length
                    : startIndex + 5;
                final wallpapersToShow =
                favoriteWallpapers.sublist(startIndex, endIndex);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 220, // Set a fixed height for the carousel
                    child: M3Carousel(
                      type: "contained",
                     // heroAlignment: "center",
                      freeScroll: false,
                      onTap: (int index) {
                        final selectedWallpaper = wallpapersToShow[index];
                        log('Tapped on wallpaper at index: $index with path: $selectedWallpaper');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenWallpaperPreview(wallpaperUrl: selectedWallpaper),
                          ),
                        );
                      },
                      children: wallpapersToShow.map((wallpaperUrl) {
                        return CachedNetworkImage(
                          imageUrl: wallpaperUrl,
                          fit: BoxFit.cover, // Ensure the image fills the space properly
                          width: double.infinity, // Full width of the container
                          height: double.infinity, // Full height of the container
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              childCount: (favoriteWallpapers.length / 5).ceil(),
            ),
          ),
        ],
      ),
    );
  }
}
