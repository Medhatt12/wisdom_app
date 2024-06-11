import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DayInTheLifeGame extends FlameGame with TapCallbacks {
  late Avatar avatar;
  late DecisionTracker decisionTracker;
  int currentScenarioIndex = 0;
  int score = 0;

  Scenario? _scenario;

  @override
  Future<void> onLoad() async {
    decisionTracker = DecisionTracker('user_id'); // Replace with actual user ID

    avatar = Avatar();
    add(avatar);

    loadNextScenario();
  }

  void loadNextScenario() {
    if (currentScenarioIndex < scenarios.length) {
      final scenarioData = scenarios[currentScenarioIndex];
      _scenario = Scenario(
        question: scenarioData['question'],
        options: scenarioData['options'],
        correctAnswer: scenarioData['correctAnswer'],
        onOptionSelected: (option) {
          if (option == scenarioData['correctAnswer']) {
            score++;
          }
          currentScenarioIndex++;
          remove(_scenario!);
          loadNextScenario();
        },
      )..position = Vector2(50, 50); // Set initial position
      add(_scenario!);
    } else {
      // Game over, show summary
      overlays.add('Summary');
    }
  }

  Scenario? get currentScenario => _scenario;

  final List<Map<String, dynamic>> scenarios = [
    {
      'question': "What should your partner do first thing in the morning?",
      'options': ["Exercise", "Have Breakfast", "Check Emails"],
      'correctAnswer': 2,
    },
    {
      'question': "What would your partner likely do on a stressful day?",
      'options': ["Meditate", "Go for a walk", "Watch TV"],
      'correctAnswer': 0,
    },
    // Add more scenarios here
  ];
}

class Avatar extends SpriteComponent {
  Avatar() : super(size: Vector2(64, 64), position: Vector2(100, 100));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(
        'wise-owl.png'); // Ensure you have an avatar image in your assets
  }

  @override
  void update(double dt) {
    // Handle avatar updates
  }
}

class DecisionTracker {
  final String userId;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  DecisionTracker(this.userId);

  Future<void> saveDecision(String scenario, String decision) async {
    await users.doc(userId).collection('decisions').add({
      'scenario': scenario,
      'decision': decision,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

class Scenario extends PositionComponent with TapCallbacks {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final void Function(int) onOptionSelected;

  Scenario({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.onOptionSelected,
  });

  @override
  Future<void> onLoad() async {
    size = Vector2(300, 300); // Set the size of the component

    add(WrappedText(
      text: question,
      position: Vector2(0, 0),
      maxWidth: 300, // Adjust width as needed
    ));

    for (int i = 0; i < options.length; i++) {
      add(TappableText(
        text: options[i],
        position: Vector2(0, 150 + i * 50), // Adjust position to avoid overlap
        onTap: () => onOptionSelected(i),
      ));
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    print('onTapDown');
    return true;
  }
}

class TappableText extends TextComponent with TapCallbacks {
  final String text;
  final VoidCallback onTap;
  final bool isQuestion;

  TappableText({
    required this.text,
    required Vector2 position,
    required this.onTap,
    this.isQuestion = false,
  }) : super(
          text: text,
          position: position,
          textRenderer: TextPaint(
            style: TextStyle(
              color: Colors.white,
              fontSize: isQuestion ? 20 : 18,
            ),
          ),
        );

  @override
  bool onTapDown(TapDownEvent event) {
    onTap();
    return true;
  }
}

class WrappedText extends PositionComponent {
  final String text;
  final double maxWidth;
  final TextPaint textRenderer;

  WrappedText({
    required this.text,
    required Vector2 position,
    required this.maxWidth,
  })  : textRenderer = TextPaint(
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        super(position: position);

  @override
  Future<void> onLoad() async {
    final lines = _wrapText(text, maxWidth, textRenderer);
    double yOffset = 0;
    for (var line in lines) {
      add(TextComponent(
        text: line,
        position: Vector2(0, yOffset),
        textRenderer: textRenderer,
      ));
      yOffset += _measureTextHeight(line, textRenderer);
    }
  }

  List<String> _wrapText(String text, double maxWidth, TextPaint textRenderer) {
    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';
    for (var word in words) {
      final testLine = currentLine.isEmpty ? word : '$currentLine $word';
      final textWidth = _measureTextWidth(testLine, textRenderer);
      if (textWidth <= maxWidth) {
        currentLine = testLine;
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    return lines;
  }

  double _measureTextWidth(String text, TextPaint textRenderer) {
    final textSpan = TextSpan(text: text, style: textRenderer.style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  double _measureTextHeight(String text, TextPaint textRenderer) {
    final textSpan = TextSpan(text: text, style: textRenderer.style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.height;
  }
}
