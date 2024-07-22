import 'package:flutter/material.dart';
import 'dart:math';
import '../models/scenario.dart';
import 'story_data.dart';

class StoryGameScreen extends StatefulWidget {
  final VoidCallback onLastScenarioChoiceMade;

  const StoryGameScreen({Key? key, required this.onLastScenarioChoiceMade})
      : super(key: key);

  @override
  _StoryGameScreenState createState() => _StoryGameScreenState();
}

class _StoryGameScreenState extends State<StoryGameScreen>
    with SingleTickerProviderStateMixin {
  int currentScenarioId = 0;
  late PageController pageController;
  bool isLastScenarioChoiceMade = false;
  int? selectedChoiceIndex;
  bool isFlipped = false;
  bool showFrontContent = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            showFrontContent = false;
          });
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            showFrontContent = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextScenario() {
    setState(() {
      currentScenarioId++;
      selectedChoiceIndex =
          null; // Reset the selected choice for the next scenario
      isLastScenarioChoiceMade =
          false; // Reset the flag when moving to another scenario
      isFlipped = false;
    });
    pageController.jumpToPage(currentScenarioId);
  }

  void _makeChoice(int index) {
    if (currentScenarioId == story.length - 1) {
      setState(() {
        isLastScenarioChoiceMade = true;
        selectedChoiceIndex = index;
      });
      widget.onLastScenarioChoiceMade();
    } else {
      setState(() {
        selectedChoiceIndex = index;
      });
    }
  }

  void _switchPerspective() {
    if (isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLastScenario = currentScenarioId == story.length - 1;
    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        itemCount: story.length,
        itemBuilder: (context, index) {
          final scenario = story[index];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final angle = _animation.value * pi;
                  final transform = Matrix4.rotationY(angle);
                  if (angle >= pi / 2) {
                    transform.rotateY(pi);
                  }
                  return Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    child: angle >= pi / 2
                        ? _buildPerspectiveCard(scenario.perspectiveText)
                        : _buildScenarioCard(scenario),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: isLastScenarioChoiceMade
          ? FloatingActionButton(
              heroTag: null,
              key: UniqueKey(),
              child: Icon(Icons.check),
              onPressed: () async {
                // Implement saveAnswersToFirestore logic here
              },
            )
          : null,
    );
  }

  Widget _buildScenarioCard(Scenario scenario) {
    final isLastScenario = currentScenarioId == story.length - 1;
    return SizedBox(
      height: double.infinity, // Full height of the screen
      child: Card(
        elevation: 8,
        key: ValueKey(false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: showFrontContent
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      scenario.image,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Text(
                      scenario.text,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    ...scenario.choices.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Choice choice = entry.value;
                      return ListTile(
                        leading: Icon(
                          selectedChoiceIndex == idx
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        title: Text(choice.text),
                        onTap: () => _makeChoice(idx),
                      );
                    }).toList(),
                    if (!isLastScenario && selectedChoiceIndex != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ElevatedButton(
                          onPressed: _nextScenario,
                          child: Text('Next'),
                        ),
                      ),
                    if (scenario.perspectiveSwitch != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: ElevatedButton(
                          onPressed: _switchPerspective,
                          child: Text(scenario.perspectiveSwitch!),
                        ),
                      ),
                  ],
                )
              : Container(), // Empty container to hide the content during flip
        ),
      ),
    );
  }

  Widget _buildPerspectiveCard(String? perspectiveText) {
    return SizedBox(
      height: double.infinity, // Full height of the screen
      child: Card(
        elevation: 8,
        key: ValueKey(true),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: !showFrontContent
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (perspectiveText != null)
                      Text(
                        perspectiveText,
                        style: TextStyle(fontSize: 18),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _switchPerspective,
                      child: Text('Back'),
                    ),
                  ],
                )
              : Container(), // Empty container to hide the content during flip
        ),
      ),
    );
  }
}
