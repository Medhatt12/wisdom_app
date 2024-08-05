import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';

class GridItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool enabled;
  final Function()? onTap;

  const GridItem({
    required this.text,
    required this.icon,
    required this.enabled,
    this.onTap,
    required GlobalKey key,
  }) : super(key: key);

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
                const SizedBox(height: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: themeProvider.themeData.textTheme.bodyMedium?.color,
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
  final bool isCompleted; // New parameter to indicate whether task is completed
  final Function()? onTap;

  const TaskGridItem({super.key, 
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.enabled,
    required this.isCompleted, // New parameter
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: enabled && !isCompleted ? onTap : null,
      child: Container(
        height: 140,
        width: 140, // Fixed width for task items
        decoration: BoxDecoration(
          color: enabled ? backgroundColor : Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 30,
                    color: themeProvider.themeData.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign
                        .center, // Ensure text is centered within its container
                    style: TextStyle(
                      color:
                          themeProvider.themeData.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted) // Conditional rendering of check mark
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
