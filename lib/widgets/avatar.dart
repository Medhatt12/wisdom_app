import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Avatar extends SpriteComponent {
  Avatar() : super(size: Vector2(64, 64));

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
