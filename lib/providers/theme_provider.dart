import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Mulai dengan mode terang secara eksplisit

  ThemeMode get themeMode => _themeMode;

  // Mengubah tema berdasarkan kondisi saat ini
  void toggleTheme(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // Mengatur tema kembali ke mode terang (default)
  void resetToLightMode() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
