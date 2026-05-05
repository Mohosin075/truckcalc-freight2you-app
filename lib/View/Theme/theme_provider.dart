// theme_provider.dart (ফাইনাল + প্রোডাকশন রেডি)

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeProvider with ChangeNotifier {
  static const String _key = 'isDarkMode';
  final GetStorage _box = GetStorage();

  bool get isDarkMode => _box.read(_key) ?? false;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    await _box.write(_key, !isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await _box.write(_key, value);
    notifyListeners();
  }

  Future<void> init() async {
    await GetStorage.init(); 
  }
}