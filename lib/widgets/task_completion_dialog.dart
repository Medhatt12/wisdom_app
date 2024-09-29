import 'package:flutter/material.dart';

class TaskCompletionDialog extends StatefulWidget {
  final String taskName;
  final int currentStage;
  final VoidCallback onHomePressed;

  const TaskCompletionDialog({
    super.key,
    required this.taskName,
    required this.currentStage,
    required this.onHomePressed,
  });

  @override
  _TaskCompletionDialogState createState() => _TaskCompletionDialogState();
}

class _TaskCompletionDialogState extends State<TaskCompletionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  bool showNextStage = false;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController for shaking
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

    // Stop the shaking after 2 seconds, then transition to the next stage image
    Future.delayed(const Duration(seconds: 2), () {
      _controller.stop();
      Future.delayed(const Duration(milliseconds: 300), () {
        // Trigger the transition to the next stage after a small delay
        setState(() {
          showNextStage = true;
        });
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Congrats on finishing the task \"${widget.taskName}\"!",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: showNextStage
                      ? 0
                      : _shakeAnimation
                          .value, // Shake symmetrically or stay still
                  child: AnimatedSwitcher(
                    duration: const Duration(
                        milliseconds: 500), // Duration of the crossfade
                    child: Image.asset(
                      // Show next stage image if shaking has stopped
                      'assets/images/STAGE${showNextStage ? (widget.currentStage + 1).clamp(1, 6) : widget.currentStage}.png',
                      key: ValueKey<int>(showNextStage
                          ? widget.currentStage + 1
                          : widget.currentStage),
                      height: 100,
                      width: 100,
                    ),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onHomePressed,
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
