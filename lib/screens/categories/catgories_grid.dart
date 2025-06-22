// categories_page.dart
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:stitch/screens/full_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:m3_carousel/m3_carousel.dart';

import 'categorie_wall.dart';


class WallpaperInfo {
  final String id;
  final String imageUrl;

  WallpaperInfo({required this.id, required this.imageUrl});

  factory WallpaperInfo.fromJson(Map<String, dynamic> json) {
    return WallpaperInfo(
      id: json['id'],
      imageUrl: json['path'],
    );
  }
}

class WallpaperQuery {
  final String? query;

  WallpaperQuery({this.query});

  Map<String, String> toJson() {
    return {'q': query ?? ''};
  }
}

class WallhavenApiClient {
  final http.Client _httpClient;
  static const _baseUrl = 'wallhaven.cc';

  WallhavenApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<List<WallpaperInfo>> wallpaperSearch({WallpaperQuery? wallQuery}) async {
    final queryParameters = wallQuery?.toJson() ?? {};

    final request = Uri.https(
      _baseUrl,
      '/api/v1/search',
      queryParameters,
    );

    final response = await _httpClient.get(request);

    if (response.statusCode != 200) {
      throw Exception('Request failed with status: ${response.statusCode}');
    }

    final wallpaperListJson = jsonDecode(response.body) as Map<String, dynamic>;
    if (!wallpaperListJson.containsKey('data')) {
      throw Exception('Wallpaper not found');
    }

    return (wallpaperListJson['data'] as List)
        .map((item) => WallpaperInfo.fromJson(item))
        .toList();
  }
}

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<String> categories = ['animals', 'cars', 'nature', 'minimal', 'space']; // Declare categories here!
  Map<String, List<WallpaperInfo>> wallpapersByCategory = {};
  bool isLoading = true;

  Future<void> _fetchWallpapers(String category) async {
    try {
      final WallhavenApiClient apiClient = WallhavenApiClient();
      final wallpaperList = await apiClient.wallpaperSearch(
        wallQuery: WallpaperQuery(query: category),
      );

      setState(() {
        wallpapersByCategory[category] = wallpaperList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching wallpapers for $category: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch wallpapers concurrently
    Future.wait(categories.map((category) => _fetchWallpapers(category)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar with scrolling effect
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
                            'Carouse',
                            style: TextStyle(
                              fontFamily: 'sand',
                              fontSize: isCollapsed ? 24.0 : 42.0,
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
                              // Semi-transparent overlay
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
          // SliverList for the list of categories
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to the CategoryWallpapersPage
                          final wallpapers = wallpapersByCategory[category] ?? [];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryWallpapersPage(
                                category: category,
                                wallpapers: wallpapers,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          category.capitalize(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, fontFamily: 'display'),
                        ),
                      ),
                      if (wallpapersByCategory.containsKey(category) &&
                          wallpapersByCategory[category]!.isNotEmpty)
                        SizedBox(
                          height: 220,
                          child: M3Carousel(
                            type: "contained",
                           // heroAlignment: "center",
                            children: wallpapersByCategory[category]!.map((wallpaper) {
                              return GestureDetector(
                                onTap: () {
                                  final selectedWallpaper = wallpapersByCategory[category]![index].imageUrl; // Access the image URL correctly
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenWallpaperPreview(wallpaperUrl: selectedWallpaper),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  wallpaper.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 220,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      if (!wallpapersByCategory.containsKey(category) ||
                          wallpapersByCategory[category]!.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              "Watch dots merge to form your paper.",
                              style: TextStyle(
                                fontFamily: 'Display',
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
              childCount: categories.length,
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + this.substring(1);
  }}