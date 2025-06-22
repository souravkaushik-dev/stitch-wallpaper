import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stitch/shared/models/wallpaper.dart';
import 'package:stitch/shared/models/wallpaper_query.dart';
import 'package:stitch/wallhaven/api/wallhaven_api_client.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:liquid_glass/liquid_glass.dart';

import 'full_screen.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Wallpaper> _wallpapers = [];
  bool _isLoading = false;

  final WallhavenApiClient _apiClient = WallhavenApiClient();

  Future<void> _searchWallpapers(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final wallpaperList = await _apiClient.wallpaperSearch(
        wallQuery: WallpaperQuery(query: query),
      );
      setState(() {
        _wallpapers = wallpaperList.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background glass
          Positioned.fill(
            child: LiquidGlass(
              blur: 30,
              opacity: isDark ? 0.1 : 0.07,
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    var top = constraints.biggest.height;
                    bool isCollapsed =
                        top <= kToolbarHeight + MediaQuery.of(context).padding.top;
                    double roundedCorner = isCollapsed ? 20.0 : 30.0;

                    return FlexibleSpaceBar(
                      centerTitle: true,
                      titlePadding: EdgeInsets.only(
                        top: isCollapsed ? 0.0 : 80.0,
                        left: 16.0,
                      ),
                      title: Align(
                        alignment:
                        isCollapsed ? Alignment.centerLeft : Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: isCollapsed
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              Text(
                                'stitch here',
                                style: TextStyle(
                                  fontFamily: 'sand',
                                  fontSize: isCollapsed ? 24.0 : 42.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(roundedCorner),
                          ),
                          color: Colors.transparent,
                        ),
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
                delegate: SliverChildListDelegate([
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (!_isLoading && _wallpapers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 32.0),
                        child: Text("You haven’t stitched any wallpapers yet.",
                          style: TextStyle(
                            fontFamily: 'sand',
                          ),),
                      ),
                    ),
                ]),
              ),

              if (!_isLoading && _wallpapers.isNotEmpty)
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final wallpaper = _wallpapers[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenWallpaperPreview(
                                  wallpaperUrl: wallpaper.path),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            wallpaper.path,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    childCount: _wallpapers.length,
                  ),
                ),
            ],
          ),

          // Bottom Search Bar (floating glass style)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 10,
            left: 20,
            right: 20,
            child: LiquidGlass(
              blur: 20,
              borderRadius: BorderRadius.circular(20),
              opacity: isDark ? 0.2 : 0.35,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'start stitching',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black38,
                      fontFamily: 'sand',
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Hicons.search1LightOutline,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () => _searchWallpapers(_controller.text),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (query) => _searchWallpapers(query),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
