import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      final currentlyDark = isDarkMode(context);
      _themeMode = currentlyDark ? ThemeMode.light : ThemeMode.dark;
    } else {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    }
    notifyListeners();
  }
}
