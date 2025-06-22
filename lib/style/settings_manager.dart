//dotstudios

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Preferences

final useSystemColor = ValueNotifier<bool>(
  Hive.box('settings').get('useSystemColor', defaultValue: true),
);

final usePureBlackColor = ValueNotifier<bool>(
  Hive.box('settings').get('usePureBlackColor', defaultValue: false),
);

final predictiveBack = ValueNotifier<bool>(
  Hive.box('settings').get('predictiveBack', defaultValue: false),
);


final themeModeSetting =
    Hive.box('settings').get('themeMode', defaultValue: 'dark') as String;

Color primaryColorSetting =
    Color(Hive.box('settings').get('accentColor', defaultValue: 0xff91cef4));

