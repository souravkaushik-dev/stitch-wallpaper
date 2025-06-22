import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_glass/liquid_glass.dart';

import 'categories/catgories_grid.dart';
import 'fav and download/fav_grid.dart';
import 'home_screen.dart';
import 'search.dart';

class MyBottomNavBarPage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const MyBottomNavBarPage({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  _MyBottomNavBarPageState createState() => _MyBottomNavBarPageState();
}

class _MyBottomNavBarPageState extends State<MyBottomNavBarPage> {
  int _selectedIndex = 0;
  Set<int> _tappedIcons = {};

  final List<Widget> _pages = [
    WallpaperHomePage(),
    CategoriesPage(),
    SearchPage(),
    FavoriteWallpapersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double totalWidth = constraints.maxWidth;
              double spaceWidth = totalWidth * 0.20;
              double navBarWidth = totalWidth * 0.70;

              return SizedBox(
                height: 64,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedIndex = 0;
                          _tappedIcons.add(0);
                        });
                        Future.delayed(const Duration(milliseconds: 200), () {
                          setState(() {
                            _tappedIcons.remove(0);
                          });
                        });
                      },
                      child: AnimatedScale(
                        scale: _tappedIcons.contains(0) ? 1.3 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: LiquidGlass(
                          opacity: 0.06,
                          borderRadius: BorderRadius.circular(30),
                          child: SizedBox(
                            height: 64,
                            width: spaceWidth,
                            child: Icon(
                              Hicons.home2LightOutline,
                              size: 22,
                              color: _selectedIndex == 0
                                  ? colorScheme.primary
                                  : _getUnselectedIconColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    LiquidGlass(
                      opacity: 0.06,
                      borderRadius: BorderRadius.circular(30),
                      child: SizedBox(
                        height: 64,
                        width: navBarWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildIconNavItem(
                              icon: HugeIcons.strokeRoundedGeometricShapes01,
                              index: 1,
                              color: colorScheme.primary,
                            ),
                            _buildIconNavItem(
                              icon: Hicons.search1LightOutline,
                              index: 2,
                              color: colorScheme.primary,
                            ),
                            _buildIconNavItem(
                              icon: Hicons.heart1LightOutline,
                              index: 3,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIconNavItem({
    required IconData icon,
    required int index,
    required Color color,
  }) {
    final isSelected = _selectedIndex == index;
    final isTapped = _tappedIcons.contains(index);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedIndex = index;
          _tappedIcons.add(index);
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          setState(() {
            _tappedIcons.remove(index);
          });
        });
      },
      child: AnimatedScale(
        scale: isTapped ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Icon(
          icon,
          size: 22,
          color: isSelected ? color : _getUnselectedIconColor(context),
        ),
      ),
    );
  }

  /// Returns adaptive color for unselected icons
  Color _getUnselectedIconColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white60 : Colors.black45;
  }
}
