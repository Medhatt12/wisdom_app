import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';

class DragEventsGame extends FlameGame {
  final Color selectedColor;
  final void Function(Color) changeColor; // Function to update the color

  DragEventsGame(this.selectedColor, this.changeColor);

  @override
  Future<void> onLoad() async {
    addAll([
      DragTarget(selectedColor,
          changeColor), // Pass selectedColor and changeColor function
    ]);
  }
}

// This component is the pink-ish rectangle in the center of the game window.
// It uses the [DragCallbacks] mixin in order to receive drag events.
class DragTarget extends PositionComponent with DragCallbacks {
  Color selectedColor;
  final void Function(Color) changeColor; // Function to update the color

  DragTarget(this.selectedColor, this.changeColor)
      : super(size: Vector2.zero());

  final _rectPaint = Paint()..color = Colors.white;

  final Map<int, Trail> _trails = {};
  // Rest of the class...

  void updateColor(Color color) {
    selectedColor = color;
    for (final trail in _trails.values) {
      trail.color = color; // Update the color of existing trails
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    position = Vector2
        .zero(); // Ensure the drawing area starts from the top-left corner
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _rectPaint);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final trail = Trail(event.localPosition, selectedColor);
    _trails[event.pointerId] = trail;
    add(trail);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _trails[event.pointerId]!.addPoint(event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _trails.remove(event.pointerId)!.end();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _trails.remove(event.pointerId)!.cancel();
  }
}

class Trail extends Component {
  Trail(Vector2 origin, this.color)
      : _paths = [Path()..moveTo(origin.x, origin.y)],
        _opacities = [1],
        _lastPoint = origin.clone();

  final List<Path> _paths;
  final List<double> _opacities;
  Color color;
  late final _linePaint = Paint()..style = PaintingStyle.stroke;
  late final _circlePaint = Paint()..color = color;
  bool _released = false;
  final Vector2 _lastPoint;

  static final random = Random();
  static const lineWidth = 10.0;

  void updateColor(Color newColor) {
    color = newColor;
  }

  @override
  void render(Canvas canvas) {
    assert(_paths.length == _opacities.length);
    for (var i = 0; i < _paths.length; i++) {
      final path = _paths[i];
      final opacity = _opacities[i];
      if (opacity > 0) {
        _linePaint.color = color.withOpacity(opacity);
        _linePaint.strokeWidth = lineWidth * opacity;
        canvas.drawPath(path, _linePaint);
      }
    }
    canvas.drawCircle(
      _lastPoint.toOffset(),
      (lineWidth - 2) * _opacities.last + 2,
      _circlePaint,
    );
  }

  @override
  void update(double dt) {
    // No need to update opacity over time
    // Do nothing here or remove this method
  }

  void addPoint(Vector2 point) {
    if (!point.x.isNaN) {
      for (final path in _paths) {
        path.lineTo(point.x, point.y);
      }
      _lastPoint.setFrom(point);
    }
  }

  void end() => _released = true;

  void cancel() {
    _released = true;
    //color = const Color(0xFFFFFFFF);
  }
}

class Star extends PositionComponent with DragCallbacks {
  Star({
    required int n,
    required double radius1,
    required double radius2,
    required double sharpness,
    required this.color,
    super.position,
  }) {
    _path = Path()..moveTo(radius1, 0);
    for (var i = 0; i < n; i++) {
      final p1 = Vector2(radius2, 0)..rotate(tau / n * (i + sharpness));
      final p2 = Vector2(radius2, 0)..rotate(tau / n * (i + 1 - sharpness));
      final p3 = Vector2(radius1, 0)..rotate(tau / n * (i + 1));
      _path.cubicTo(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
    }
    _path.close();
  }

  final Color color;
  final Paint _paint = Paint();
  final Paint _borderPaint = Paint()
    ..color = const Color(0xFFffffff)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final _shadowPaint = Paint()
    ..color = const Color(0xFF000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
  late final Path _path;

  @override
  bool containsLocalPoint(Vector2 point) {
    return _path.contains(point.toOffset());
  }

  @override
  void render(Canvas canvas) {
    if (isDragged) {
      _paint.color = color.withOpacity(0.5);
      canvas.drawPath(_path, _paint);
      canvas.drawPath(_path, _borderPaint);
    } else {
      _paint.color = color.withOpacity(1);
      canvas.drawPath(_path, _shadowPaint);
      canvas.drawPath(_path, _paint);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    priority = 10;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    priority = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }
}
