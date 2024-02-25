import 'package:flutter/material.dart';
import '../models/avatar_customization.dart';

class AvatarCustomizationController {
  static AvatarCustomization createAvatar({
    Gender gender = Gender.male,
    Color hairColor = Colors.black,
    Color skinColor = Colors.red,
    Color eyeColor = Colors.blue,
    BodyShape bodyShape = BodyShape.rectangle,
    Color headColor = Colors.blue, // Default Material color
    Color bodyColor = Colors.green, // Default Material color
  }) {
    return AvatarCustomization(
      gender: gender,
      hairColor: hairColor,
      skinColor: skinColor,
      eyeColor: eyeColor,
      bodyShape: bodyShape,
      headColor: headColor,
      bodyColor: bodyColor,
    );
  }
}
