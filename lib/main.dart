import 'package:stitch/drawer/update.dart';
import 'package:stitch/iostrial.dart';
import 'package:stitch/screens/splash.dart' hide SplashScreen;
import 'package:stitch/settings_menu/cache.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stitch/screens/fav%20and%20download/fav_grid.dart';
import 'package:stitch/screens/nav.dart';
import 'package:stitch/drawer/aboout_us.dart';
import 'package:stitch/drawer/about.paper.dart';
import 'package:stitch/drawer/faqs.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:stitch/style/dynamic_color_temp_fix.dart';
import 'drawer/font_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String fontFamily = prefs.getString('selectedFont') ?? 'Inter'; // Default to Inter

  runApp(
    ChangeNotifierProvider(
      create: (context) => FontProvider('Inter'), // Default font
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _primaryColor = Colors.deepPurple;
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  static const platform = MethodChannel('com.studios.stitch/accentColor');

  @override
  void initState() {
    super.initState();
    _loadSavedAccentColor();
    _getDeviceAccentColor();
  }

  Future<void> _getDeviceAccentColor() async {
    Color accentColor;
    try {
      final int result = await platform.invokeMethod('getAccentColor');
      accentColor = Color(result);
    } on PlatformException catch (e) {
      accentColor = Colors.deepPurple;
      print("Failed to get accent color: '${e.message}'");
    }
    _saveAccentColor(accentColor);

    setState(() {
      _primaryColor = accentColor;
    });
  }

  Future<void> _saveAccentColor(Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('accentColor', color.value);
  }

  Future<void> _loadSavedAccentColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int colorValue = prefs.getInt('accentColor') ?? Colors.deepPurple.value;
    setState(() {
      _primaryColor = Color(colorValue);
    });
  }

  void _setSystemTheme(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    setState(() {
      _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    _setSystemTheme(context);
    final fontProvider = Provider.of<FontProvider>(context);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        if (lightDynamic != null && darkDynamic != null) {
          (lightDynamic, darkDynamic) =
          tempGenerateDynamicColourSchemes(lightDynamic, darkDynamic);
        }

        final lightScheme = lightDynamic ??
            ColorScheme.fromSeed(seedColor: _primaryColor, brightness: Brightness.light);
        final darkScheme = darkDynamic ??
            ColorScheme.fromSeed(seedColor: _primaryColor, brightness: Brightness.dark);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'stitch',
          themeMode: _themeMode, // System, Light, or Dark Theme
          theme: ThemeData(
            colorScheme: lightScheme, // Apply font globally
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
          ),
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/FavoriteWallpapersPage':
                return MaterialPageRoute(builder: (context) => FavoriteWallpapersPage());
              case '/faq':
                return MaterialPageRoute(builder: (context) => FAQPage());
              case '/about':
                return MaterialPageRoute(builder: (context) => Aboutdottunes());
              case '/aboutus':
                return MaterialPageRoute(builder: (context) => AboutPage());
              case '/last update':
                return MaterialPageRoute(builder: (context) => updatedottunes());
              default:
                return MaterialPageRoute(builder: (context) => MyBottomNavBarPage(
                  themeMode: _themeMode,
                  onThemeChanged: (ThemeMode value) {
                    setState(() {
                      _themeMode = value;
                    });
                  },
                ));
            }
          },
          home: SplashScreen(),
        );
      },
    );
  }
}
