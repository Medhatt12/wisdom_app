import 'package:flutter/material.dart';
import 'theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      background: AppColors.backgroundColor,
      onPrimary: AppColors.textColor,
      onBackground: AppColors.textColor,
      secondary: AppColors.accentColor,
    ),
    scaffoldBackgroundColor: AppColors.backgroundColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey;
          }
          return AppColors.primaryColor;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.white; // Adjust if needed
          }
          return AppColors.textColor;
        }),
      ),
    ),
  );

  ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDarkColor,
      background: AppColors.backgroundDarkColor,
      onPrimary: AppColors.textDarkColor,
      onBackground: AppColors.textDarkColor,
      secondary: AppColors.accentDarkColor,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDarkColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey;
          }
          return AppColors.primaryDarkColor;
        }),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.white; // Adjust if needed
          }
          return AppColors.textDarkColor;
        }),
      ),
    ),
  );

  late ThemeData currentThemeMode;

  ThemeProvider() {
    currentThemeMode = lightTheme;
  }

  ThemeData get themeData => currentThemeMode;

  void toggleTheme() {
    currentThemeMode = currentThemeMode == lightTheme ? darkTheme : lightTheme;
    notifyListeners();
  }
}
