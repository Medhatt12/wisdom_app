import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color.fromARGB(255, 242, 205, 221);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black;
  static const Color accentColor = Colors.green;

  static const Color primaryDarkColor = Color.fromARGB(255, 242, 205, 221);
  static const Color backgroundDarkColor = Colors.white;
  static const Color textDarkColor = Colors.black;
  static const Color accentDarkColor = Colors.lightGreen;

  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: primaryColor,
    background: backgroundColor,
    onPrimary: textColor,
    onBackground: textColor,
    secondary: accentColor,
  );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: primaryDarkColor,
    background: backgroundDarkColor,
    onPrimary: textDarkColor,
    onBackground: textDarkColor,
    secondary: accentDarkColor,
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: AppColors.lightColorScheme,
  );

  ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: AppColors.darkColorScheme,
  );

  late ThemeData currentThemeMode; // Declare as late

  ThemeProvider() {
    currentThemeMode = lightTheme; // Assign inside the constructor
  }

  ThemeData get themeData => currentThemeMode;

  void toggleTheme() {
    currentThemeMode = currentThemeMode == lightTheme ? darkTheme : lightTheme;
    notifyListeners();
  }
}
