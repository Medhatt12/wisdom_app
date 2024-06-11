import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Scenario extends TextComponent {
  final String question;
  final List<String> options;
  final void Function(String) onOptionSelected;

  Scenario({
    required this.question,
    required this.options,
    required this.onOptionSelected,
  }) : super(text: '');

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Render scenario question and options
  }

  @override
  void update(double dt) {
    // Update scenario state
  }

  void selectOption(String option) {
    onOptionSelected(option);
  }
}
