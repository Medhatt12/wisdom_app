import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFFF2CDD9);
  // #faf2d7
  static const Color backgroundColor = Color.fromARGB(255, 229, 228, 202);
  // static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black;
  static const Color accentColor = Colors.green;

  static const Color primaryDarkColor = Color(0xFF004D40);
  static const Color backgroundDarkColor = Color.fromARGB(255, 35, 36, 36);
  static const Color textDarkColor = Color(0xFFFFFFFF);
  static const Color accentDarkColor = Color(0xFF00BFA5);
}

class AppTextStyles {
  static TextStyle headline1(BuildContext context) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onBackground,
    );
  }

  static TextStyle bodyText1(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      color: Theme.of(context).colorScheme.onBackground,
    );
  }
}
