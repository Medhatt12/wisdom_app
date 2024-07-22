import 'package:flutter/material.dart';
import 'package:wisdom_app/views/caterpillar_game_screen.dart';
import 'package:wisdom_app/views/custom_avatar_screen.dart';
import 'package:wisdom_app/views/home_screen.dart';
import 'package:wisdom_app/views/login_screen.dart';
import 'package:wisdom_app/views/settings_screen.dart';
import 'package:wisdom_app/views/tasks/mindfulness_task_screen.dart';
import 'package:wisdom_app/views/tasks/similarities_and_differences_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/avatar':
        return MaterialPageRoute(builder: (_) => CustomAvatarScreen());
      case '/caterpillar':
        return MaterialPageRoute(builder: (_) => CaterpillarGameScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case '/similarities-and-differences':
        return MaterialPageRoute(
            builder: (_) => SimilaritiesAndDifferencesPage());
      case '/mindfulness':
        return MaterialPageRoute(builder: (_) => MindfulnessScreen());

      default:
        return MaterialPageRoute(builder: (_) => const Scaffold());
    }
  }
}
