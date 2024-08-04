// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:wisdom_app/widgets/drawn_line.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine>? lines;

  Sketcher({this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    if (lines != null) {
      for (int i = 0; i < lines!.length; ++i) {
        if (lines![i] == null) continue;
        for (int j = 0; j < lines![i].path.length - 1; ++j) {
          if (lines![i].path[j] != null && lines![i].path[j + 1] != null) {
            paint.color = lines![i].color;
            paint.strokeWidth = lines![i].width;
            canvas.drawLine(lines![i].path[j], lines![i].path[j + 1], paint);
          }
        }
      }
    } else {
      print("reload");
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
