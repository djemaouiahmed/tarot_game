import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  // Light theme
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: const Color(0xFF1B5E20),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D3818),
      elevation: 0,
    ),
  );

  // Dark theme
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.amber,
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F0F1E),
      elevation: 0,
    ),
  );

  // Get gradient colors based on theme
  List<Color> get backgroundGradient => _isDarkMode
      ? [
          const Color(0xFF1A1A2E),
          const Color(0xFF0F0F1E),
          const Color(0xFF050510),
        ]
      : [
          const Color(0xFF1B5E20),
          const Color(0xFF0D3818),
          const Color(0xFF051810),
        ];

  List<Color> get cardGradient => _isDarkMode
      ? [Colors.deepPurple.shade800, Colors.deepPurple.shade900]
      : [Colors.deepPurple.shade700, Colors.deepPurple.shade900];

  Color get primaryAccent => _isDarkMode ? Colors.amber : Colors.amber;

  Color get secondaryAccent => _isDarkMode ? Colors.orange : Colors.green;
}
