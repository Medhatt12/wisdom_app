import 'package:flutter/material.dart';

class AnimatedStageButton extends StatefulWidget {
  final int tasksFinished;
  final Color backgroundColor;

  const AnimatedStageButton({
    Key? key,
    required this.tasksFinished,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  _AnimatedStageButtonState createState() => _AnimatedStageButtonState();
}

class _AnimatedStageButtonState extends State<AnimatedStageButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController
    _controller = AnimationController(
      duration:
          const Duration(milliseconds: 500), // Duration of one shake cycle
      vsync: this,
    );

    // Create a Tween for the symmetrical shaking effect around 0 degrees
    _shakeAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );

    // Start the shaking animation
    _startShaking();
  }

  void _startShaking() {
    _controller.repeat(reverse: true); // Start shaking

    // Stop the shaking after 3 seconds, return to original position, and restart
    Future.delayed(Duration(seconds: 3), () {
      _controller.stop();
      setState(() {}); // Ensure the UI updates to show the stopped state

      // Wait for 3 seconds in the original position
      Future.delayed(Duration(seconds: 3), () {
        _controller.reset(); // Ensure it resets to 0 degrees
        _startShaking(); // Restart the shaking
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      shape: const CircleBorder(),
      backgroundColor: widget.backgroundColor,
      onPressed: () {}, // Define what happens when pressed
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.isAnimating
                ? _shakeAnimation.value
                : 0, // Shake symmetrically or return to original position
            child: child,
          );
        },
        child: Image.asset(
          'assets/images/STAGE${widget.tasksFinished.clamp(1, 6)}.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
