import 'package:flutter/material.dart';
import '../models/scenario.dart';
import 'story_data.dart';

class StoryGameScreen extends StatefulWidget {
  final Function(List<String>)
      onLastScenarioChoiceMade; // Callback to pass story summary

  const StoryGameScreen({super.key, required this.onLastScenarioChoiceMade});

  @override
  _StoryGameScreenState createState() => _StoryGameScreenState();
}

class _StoryGameScreenState extends State<StoryGameScreen> {
  int currentScenarioId = 0;
  late PageController pageController;
  int? selectedChoiceIndex;
  List<String> otherPerspectiveStory =
      []; // Collect the "Other Perspective" texts
  bool isLastScenario = false;
  bool isFabEnabled =
      false; // Track if the FAB should be enabled for the last scenario

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  void _nextScenario() {
    setState(() {
      currentScenarioId++;
      selectedChoiceIndex =
          null; // Reset the selected choice for the next scenario
      isFabEnabled = false; // Reset the FAB state
      isLastScenario =
          currentScenarioId == story.length - 1; // Check if last scenario
    });
    pageController.jumpToPage(currentScenarioId);
  }

  void _makeChoice(int index) {
    final scenario = story[currentScenarioId];

    // Track the "Other Perspective" based on the user's choice
    if (scenario.otherPerspectives != null) {
      otherPerspectiveStory.add(scenario.otherPerspectives![index]);
    } else if (scenario.singlePerspective != null) {
      otherPerspectiveStory.add(scenario.singlePerspective!);
    }

    setState(() {
      selectedChoiceIndex = index;

      // If it's the last scenario, enable the FAB
      if (isLastScenario) {
        isFabEnabled = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: story.length,
        itemBuilder: (context, index) {
          final scenario = story[index];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: _buildScenarioCard(scenario),
            ),
          );
        },
      ),
      // Show FAB only for the last scenario, disabled until choice is made
      floatingActionButton: isLastScenario
          ? FloatingActionButton(
              heroTag: null,
              key: UniqueKey(),
              onPressed: isFabEnabled
                  ? () {
                      // Directly trigger the callback to show the bottom sheet
                      widget.onLastScenarioChoiceMade(otherPerspectiveStory);
                    }
                  : null, // Disable FAB if no choice is made
              backgroundColor: isFabEnabled
                  ? Theme.of(context).primaryColor
                  : Colors.grey, // Grey when disabled
              child: const Icon(Icons.check),
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
        key: const ValueKey(false),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              scenario.image != null
                  ? Image.asset(
                      scenario.image!,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const SizedBox(height: 0),
              const SizedBox(height: 20),
              Text(
                scenario.text,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
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
              }),
              if (!isLastScenario && selectedChoiceIndex != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: _nextScenario,
                    child: const Text('Next'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
