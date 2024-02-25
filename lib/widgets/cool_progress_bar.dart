import 'package:flutter/material.dart';

class CoolProgressBar extends StatefulWidget {
  final double value;

  CoolProgressBar({required this.value});

  @override
  _CoolProgressBarState createState() => _CoolProgressBarState();
}

class _CoolProgressBarState extends State<CoolProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _colorAnimation = ColorTween(begin: Colors.blue, end: Colors.green)
        .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: widget.value,
      backgroundColor: Colors.grey[300],
      valueColor: _colorAnimation,
    );
  }
}
