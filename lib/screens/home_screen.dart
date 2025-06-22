import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:m3_carousel/m3_carousel.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typing_animation/typing_animation.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:liquid_glass/liquid_glass.dart';
import '../drawer/font_provider.dart';
import '../settings_menu/cache.dart';
import '../shared/models/wallpaper_query.dart';
import '../style/app_colors.dart';
import '../wallhaven/api/wallhaven_api_client.dart';
import 'full_screen.dart';

class WallpaperHomePage extends StatefulWidget {
  @override
  _WallpaperHomePageState createState() => _WallpaperHomePageState();
}

class _WallpaperHomePageState extends State<WallpaperHomePage> {
  final String appVersion = "DEV MODE";
  Color _primaryColor = Colors.deepPurple;
  ThemeMode _themeMode = ThemeMode.system;
  Future<List<Wallpaper>>? _trendingWallpapersFuture;
  Future<List<Wallpaper>>? _dotPicksWallpapersFuture;
  final WallhavenApiClient _wallhavenApiClient = WallhavenApiClient();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _refreshWallpapers();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Needle';
    });
  }

  void _refreshWallpapers() {
    setState(() {
      _trendingWallpapersFuture = _fetchWallpapers();
      _dotPicksWallpapersFuture = _fetchDotPicksWallpapers();
    });
  }

  Future<List<Wallpaper>> _fetchWallpapers() async {
    final wallpaperList = await _wallhavenApiClient.wallpaperSearch();
    return wallpaperList.data.map((w) => Wallpaper(path: w.path)).toList();
  }

  Future<List<Wallpaper>> _fetchDotPicksWallpapers() async {
    final dotPicksList = await _wallhavenApiClient.wallpaperSearch(wallQuery: WallpaperQuery(page: 2));
    return dotPicksList.data.map((w) => Wallpaper(path: w.path)).toList();
  }

  void _setSystemTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    setState(() {
      _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    _setSystemTheme(context);
    return DynamicColorBuilder(
      builder: (light, dark) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            backgroundColor: Colors.transparent,
            child: LiquidGlass(
              blur: 8,
              opacity: 0.5,
              borderRadius: BorderRadius.zero,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  DrawerHeader(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                          child: Container(color: Colors.transparent),
                        ),
                        Center(
                          child: TypingAnimation(
                            text: _userName.isEmpty ? 'Needle' : _userName,
                            textStyle: GoogleFonts.merriweatherSans(
                              fontWeight: FontWeight.w300,
                              fontSize: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDrawerItem(Hicons.attachmentLightOutline, 'App Version: $appVersion'),
                  const Divider(),
                  _buildDrawerItem(Hicons.heart1LightOutline, '.Fav Papers', route: '/FavoriteWallpapersPage'),
                  _buildDrawerItem(Hicons.documentAlignCenter4LightOutline, '.faqs', route: '/faq'),
                  _buildDrawerItem(Hicons.delete2LightOutline, 'clear cache', onTap: () => clearCache(context)),
                  const Divider(),
                  _buildDrawerItem(Hicons.hashtagLightOutline, 'about .paper', route: '/about'),
                  _buildDrawerItem(Hicons.numericalStarLightOutline, 'about .studios', route: '/aboutus'),
                  _buildDrawerItem(Hicons.numericalStarLightOutline, 'last revision', route: '/last update'),
                  const Divider(),
                  _buildDrawerItem(Hicons.paletteLightOutline, 'Choose Accent Color', onTap: () async {
                    Color? selectedColor = await _showAccentColorPicker();
                    if (selectedColor != null) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('accentColor', selectedColor.value);
                      setState(() => _primaryColor = selectedColor);
                    }
                  }),
                ],
              ),
            ),
          ),
          body: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(light ?? ThemeData.light().colorScheme, dark ?? ThemeData.dark().colorScheme),
              _buildCarouselSection("Today's Trending", _trendingWallpapersFuture, light!, dark!),
              _buildCarouselSection("Stitches", _dotPicksWallpapersFuture, light, dark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, {String? route, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Material(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              if (route != null) Navigator.pushNamed(context, route);
              if (onTap != null) onTap();
            },
            borderRadius: BorderRadius.circular(26),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: Theme.of(context).colorScheme.onSurface),
                  SizedBox(width: 16),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Color?> _showAccentColorPicker() async {
    return showDialog<Color>(
      context: context,
      builder: (context) {
        Color tempColor = _primaryColor;
        return AlertDialog(
          title: Text('Select Accent Color', style: GoogleFonts.inter()),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableColors.map((color) => GestureDetector(
              onTap: () => Navigator.pop(context, color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: tempColor == color ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            )).toList(),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel'))],
        );
      },
    );
  }

  SliverAppBar _buildSliverAppBar(ColorScheme light, ColorScheme dark) {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      leading: IconButton(
        icon: Icon(Hicons.menuHamburger1LightOutline),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          var top = constraints.biggest.height;
          bool isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;
          return FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.only(top: isCollapsed ? 0.0 : 80.0, left: 16.0),
            title: Align(
              alignment: isCollapsed ? Alignment.centerLeft : Alignment.center,
              child: Text(
                'stitch - ',
                style: TextStyle(
                  fontFamily: 'sand',
                  fontSize: isCollapsed ? 24.0 : 42.0,
                ),
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                color: Colors.transparent,
              ),
            ),
          );
        },
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(80),
        ),
      ),
    );
  }

  Widget _buildCarouselSection(String title, Future<List<Wallpaper>>? wallpapersFuture, ColorScheme light, ColorScheme dark) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              fontFamily: 'Display',
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        FutureBuilder<List<Wallpaper>>(
          future: wallpapersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No wallpapers found.'));
            } else {
              return Container(
                height: 220,
                child: M3Carousel(
                  type: "contained",
                  freeScroll: false,
                  onTap: (int tapIndex) {
                    final selected = snapshot.data![tapIndex];
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => FullScreenWallpaperPreview(wallpaperUrl: selected.path),
                    ));
                  },
                  children: snapshot.data!.map((wallpaper) =>
                      CachedNetworkImage(
                        imageUrl: wallpaper.path,
                        fit: BoxFit.cover,
                        height: 220,
                        placeholder: (context, url) => Center(
                          child: TypingAnimation(
                            text: 'stitching',
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: dark.onPrimary,
                              fontFamily: 'Display',
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      )
                  ).toList(),
                ),
              );
            }
          },
        ),
      ]),
    );
  }
}

class Wallpaper {
  final String path;
  Wallpaper({required this.path});
}
