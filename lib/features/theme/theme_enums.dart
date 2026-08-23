import 'package:flutter/material.dart';

enum ThemeType {
  darkMode,
  lightMode,
  system,
  amoledMode,
}

extension ThemeTypeDetails on ThemeType {
  String get themeName {
    switch (this) {
      case ThemeType.darkMode:
        return "Dark";
      case ThemeType.lightMode:
        return "Light";
      case ThemeType.system:
        return "System";
      case ThemeType.amoledMode:
        return "Amoled";
    }
  }

  IconData get iconData {
    switch (this) {
      case ThemeType.darkMode:
        return Icons.dark_mode;
      case ThemeType.lightMode:
        return Icons.light_mode;
      case ThemeType.system:
        return Icons.sync_sharp;
      case ThemeType.amoledMode:
        return Icons.brightness_3_rounded;
    }
  }
}
