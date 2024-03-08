import 'package:flutter/material.dart';
import 'package:wisdom_app/views/avatar_customization_screen.dart';
import 'package:wisdom_app/views/caterpillar_game_screen.dart';
import 'package:wisdom_app/views/home_screen.dart';
import 'package:wisdom_app/views/login_screen.dart';
import 'package:wisdom_app/views/settings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/avatar':
        return MaterialPageRoute(builder: (_) => AvatarCustomizationScreen());
      case '/caterpillar':
        return MaterialPageRoute(builder: (_) => CaterpillarGameScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      default:
        return MaterialPageRoute(builder: (_) => Scaffold());
    }
  }
}
