import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider with ChangeNotifier {
  String _fontFamily;

  FontProvider(this._fontFamily);

  String get fontFamily => _fontFamily;

  TextTheme get textTheme {
    return _fontFamily == 'Display'
        ? ThemeData.light().textTheme.apply(fontFamily: 'Display')
        : GoogleFonts.interTextTheme();
  }

  Future<void> toggleFont() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fontFamily = _fontFamily == 'Display' ? 'Inter' : 'Display';
    await prefs.setString('selectedFont', _fontFamily);
    notifyListeners();
  }
}
