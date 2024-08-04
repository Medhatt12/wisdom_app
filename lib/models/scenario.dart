class Scenario {
  final String text;
  final List<Choice> choices;
  final String? perspectiveSwitch;
  final String? perspectiveText;
  final String? image;

  Scenario({
    required this.text,
    required this.choices,
    this.perspectiveSwitch,
    this.perspectiveText,
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
