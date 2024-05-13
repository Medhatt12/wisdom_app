import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';

class GridItem extends StatelessWidget {
  final String text;
  final IconData icon; // Add this line
  //final Color backgroundColor;
  final bool enabled;
  final Function()? onTap;

  const GridItem({
    required this.text,
    required this.icon, // Add this line
    //required this.backgroundColor,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
                color: enabled
                    ? themeProvider.themeData.colorScheme.primaryContainer
                    : Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon, // Add this line
                  size: 30, // Adjust size as needed
                  color: themeProvider.themeData.textTheme.bodyMedium?.color,
                ),
                SizedBox(height: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: themeProvider.themeData.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class TaskItem {
  final String title;
  final IconData icon;
  final Widget route; // Add route property
  bool isCompleted;

  TaskItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isCompleted = false,
  });
}

class TaskGridItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final bool enabled;
  final Function()? onTap;

  const TaskGridItem({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
      return GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 100,
          width: 120, // Fixed width for task items
          decoration: BoxDecoration(
              color: enabled ? backgroundColor : Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: themeProvider.themeData.textTheme.bodyMedium?.color,
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeProvider.themeData.textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
