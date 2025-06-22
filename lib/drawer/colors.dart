import 'package:flutter/material.dart';

class ColorProvider with ChangeNotifier {
  Color _accentColor = Colors.blue; // Default color

  Color get accentColor => _accentColor;

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners(); // Notify listeners to rebuild UI
  }
}
