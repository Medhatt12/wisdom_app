import 'package:flutter/material.dart';
import 'package:wisdom_app/views/home_screen.dart';
import 'package:wisdom_app/views/avatar_customization_screen.dart';
import 'package:wisdom_app/views/caterpillar_game_screen.dart';
import 'package:wisdom_app/views/settings_screen.dart';

class TabNavigation extends StatefulWidget {
  @override
  _TabNavigationState createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    AvatarCustomizationScreen(),
    CaterpillarGameScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Create Avatar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bathtub_rounded),
            label: 'Caterpillar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
