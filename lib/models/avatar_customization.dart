import 'package:flutter/material.dart';

enum BodyShape { circle, rectangle }

enum Gender { male, female }

class AvatarCustomization {
  Gender gender;
  Color hairColor;
  Color skinColor;
  Color eyeColor;
  BodyShape bodyShape;

  AvatarCustomization({
    required this.gender,
    required this.hairColor,
    required this.skinColor,
    required this.eyeColor,
    required this.bodyShape,
    required Color headColor,
    required Color bodyColor,
  });
}
