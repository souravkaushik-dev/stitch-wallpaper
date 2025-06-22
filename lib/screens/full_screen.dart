/// FullScreenWallpaperPreview with Fav + Download moved to bottom sheet
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:awesome_gallery_saver/gallery_saver.dart';
import 'package:blur/blur.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hicons/flutter_hicons.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:typing_animation/typing_animation_code.dart';

class FullScreenWallpaperPreview extends StatefulWidget {
  final String wallpaperUrl;

  const FullScreenWallpaperPreview({Key? key, required this.wallpaperUrl}) : super(key: key);

  @override
  _FullScreenWallpaperPreviewState createState() => _FullScreenWallpaperPreviewState();
}

class _FullScreenWallpaperPreviewState extends State<FullScreenWallpaperPreview> with TickerProviderStateMixin {
  bool _isSettingWallpaper = false;
  bool _isFavorite = false;
  File? _wallpaperFile;
  late AnimationController _arrowBounceController;
  bool _isDownloading = false;
  bool _isDownloadSuccess = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _downloadAndSaveWallpaper(widget.wallpaperUrl);
    _arrowBounceController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorite_wallpapers') ?? [];
    setState(() {
      _isFavorite = favorites.contains(widget.wallpaperUrl);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorite_wallpapers') ?? [];

    if (_isFavorite) {
      favorites.remove(widget.wallpaperUrl);
    } else {
      favorites.add(widget.wallpaperUrl);
    }

    await prefs.setStringList('favorite_wallpapers', favorites);
    setState(() {
      _isFavorite = !_isFavorite;
    });

    _showSuccessToast(_isFavorite ? '.paper added to fav' : '.paper removed from fav.');
  }

  Future<void> _downloadAndSaveWallpaper(String url) async {
    setState(() => _isDownloading = true);

    try {
      Dio dio = Dio();
      final directory = Directory('/storage/emulated/0/Pictures/');
      if (!directory.existsSync()) directory.createSync(recursive: true);

      String filePath = '${directory.path}/Wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await dio.download(url, filePath);

      File file = File(filePath);
      setState(() {
        _wallpaperFile = file;
        _isDownloadSuccess = true;
      });

      _showSuccessToast('.paper loaded successfully');
    } catch (e) {
      _showErrorToast('Failed to download wallpaper!');
      setState(() => _isDownloadSuccess = false);
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  void _showSuccessToast(String message) {
    CherryToast.success(title: Text(message, style: _toastStyle)).show(context);
  }

  void _showErrorToast(String message) {
    CherryToast.error(title: Text(message, style: _toastStyle)).show(context);
  }

  TextStyle get _toastStyle => const TextStyle(fontFamily: 'Display', fontSize: 16, fontWeight: FontWeight.w200);

  Future<void> _saveWallpaperToGallery() async {
    if (_wallpaperFile == null) return _showErrorToast('No wallpaper to save!');

    try {
      Uint8List fileBytes = await _wallpaperFile!.readAsBytes();
      var saveResult = await GallerySaver.saveImage(fileBytes);
      _showSuccessToast('.paper saved to gallery!!');
    } catch (e) {
      _showErrorToast('Error saving to gallery!');
    }
  }

  @override
  void dispose() {
    _arrowBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(widget.wallpaperUrl, fit: BoxFit.cover),
            ),
            Positioned.fill(child: Blur(blur: 10.0, child: Container())),
            if (_wallpaperFile != null)
              Positioned.fill(
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(50),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_wallpaperFile!, fit: BoxFit.cover, width: 350, height: 600),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: TypingAnimation(
                  text: 'Unfolding time depends on .paper resolution.',
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black, fontFamily: 'Display'),
                ),
              ),
            if (!_isSettingWallpaper)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => _showWallpaperOptions(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _arrowBounceController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 10 * _arrowBounceController.value),
                                child: child,
                              );
                            },
                            child: const Icon(Hicons.up2LightOutline, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Set Wallpaper',
                            style: TextStyle(fontFamily: 'needle', color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  void _showWallpaperOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          maxChildSize: 0.4,
          minChildSize: 0.25,
          initialChildSize: 0.3,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -6))],
                  ),
                  child: ListView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  _toggleFavorite();
                                },
                                child: _bottomSheetIcon(
                                  icon: _isFavorite ? Hicons.heart2Bold : Hicons.heart1LightOutline,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Favorite',
                                style: TextStyle(
                                  fontFamily: 'Display',
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pop(context);
                                  if (_isDownloadSuccess) {
                                    await _saveWallpaperToGallery();
                                  } else {
                                    _showErrorToast('Please wait until the .paper gets loaded');
                                  }
                                },
                                child: _bottomSheetIcon(
                                  icon: Hicons.down2LightOutline,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Download',
                                style: TextStyle(
                                  fontFamily: 'Display',
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildWallpaperOption('Set on Home Screen', WallpaperManager.HOME_SCREEN),
                      const SizedBox(height: 10),
                      _buildWallpaperOption('Set on Lock Screen', WallpaperManager.LOCK_SCREEN),
                      const SizedBox(height: 10),
                      _buildWallpaperOption('Set on Both', WallpaperManager.BOTH_SCREEN),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _bottomSheetIcon({required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildWallpaperOption(String title, int location) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 6)),
            ],
          ),
          child: ListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'sand',
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            onTap: () {
              Navigator.pop(context);
              _setWallpaper(widget.wallpaperUrl, location);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _setWallpaper(String wallpaperUrl, int location) async {
    setState(() => _isSettingWallpaper = true);
    _showLoadingDialog();

    Future.delayed(const Duration(seconds: 1), () async {
      try {
        final response = await http.get(Uri.parse(wallpaperUrl));
        if (response.statusCode == 200) {
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/wallpaper_original.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          final result = await WallpaperManager.setWallpaperFromFile(filePath, location);

          Navigator.of(context).pop();
          _showSuccessToast(result ? 'Wallpaper set successfully' : 'Failed to set wallpaper');
        } else {
          Navigator.of(context).pop();
          _showErrorToast('Failed to download image: ${response.statusCode}');
        }
      } catch (e) {
        Navigator.of(context).pop();
        _showErrorToast('Error setting wallpaper: $e');
      } finally {
        setState(() => _isSettingWallpaper = false);
      }
    });
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            width: 200,
            height: 255,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/loading4.gif'),
                const SizedBox(height: 8),
                const Text(
                  'Setting wallpaper. Please wait; high-resolution images may take time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'Display'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
