import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:wisdom_app/games_data/drag_events.dart';

class DrawingGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wisdom App'),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: GameWidget(game: DragEventsGame()),
      ),
    );
  }
}
