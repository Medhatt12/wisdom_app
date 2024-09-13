class Scenario {
  final String text;
  final List<Choice> choices;
  final List<String>?
      otherPerspectives; // For multiple perspectives, one per choice
  final String?
      singlePerspective; // For scenarios with one shared perspective for all choices
  final String? image;

  Scenario({
    required this.text,
    required this.choices,
    this.otherPerspectives, // Optional for scenarios with multiple perspectives
    this.singlePerspective, // Optional for scenarios with a single perspective
    this.image,
  });
}

class Choice {
  final String text;
  final int nextScenarioId;

  Choice({
    required this.text,
    required this.nextScenarioId,
  });
}
