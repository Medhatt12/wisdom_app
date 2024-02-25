import 'package:flutter/material.dart';
import 'package:wisdom_app/models/avatar_customization.dart';
import '../controllers/avatar_customization_controller.dart';
import '../widgets/color_picker_dialog.dart';

class AvatarCustomizationScreen extends StatefulWidget {
  @override
  _AvatarCustomizationScreenState createState() =>
      _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState extends State<AvatarCustomizationScreen> {
  late AvatarCustomization _avatarCustomization;

  @override
  void initState() {
    super.initState();
    _avatarCustomization = AvatarCustomizationController.createAvatar();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAvatarPreview(),
            _buildGenderSelector(),
            _buildColorPicker(
              title: 'Hair Color',
              color: _avatarCustomization.hairColor,
              onColorChanged: (Color color) {
                setState(() {
                  _avatarCustomization.hairColor = color;
                });
              },
              context: context,
            ),
            _buildColorPicker(
              title: 'Skin Color',
              color: _avatarCustomization.skinColor,
              onColorChanged: (Color color) {
                setState(() {
                  _avatarCustomization.skinColor = color;
                });
              },
              context: context,
            ),
            _buildColorPicker(
              title: 'Eye Color',
              color: _avatarCustomization.eyeColor,
              onColorChanged: (Color color) {
                setState(() {
                  _avatarCustomization.eyeColor = color;
                });
              },
              context: context,
            ),
            SizedBox(height: 20),
            Text(
              'Select Character:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildCharacterSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    return Container(
      width: 120,
      height: 240,
      decoration: BoxDecoration(
        color: _avatarCustomization.skinColor,
        borderRadius: _avatarCustomization.bodyShape == BodyShape.circle
            ? BorderRadius.circular(100)
            : BorderRadius.zero,
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _avatarCustomization.hairColor,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 50,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Gender:'),
        Radio(
          value: Gender.male,
          groupValue: _avatarCustomization.gender,
          onChanged: (value) {
            setState(() {
              _avatarCustomization.gender = Gender.male;
            });
          },
        ),
        Text('Male'),
        Radio(
          value: Gender.female,
          groupValue: _avatarCustomization.gender,
          onChanged: (value) {
            setState(() {
              _avatarCustomization.gender = Gender.female;
            });
          },
        ),
        Text('Female'),
      ],
    );
  }

  Widget _buildCharacterSelector() {
    // Placeholder for character selector
    return Container(
      width: 200,
      height: 100,
      color: Colors.grey,
      child: Center(
        child: Text(
          'Character Selector Placeholder',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

Widget _buildColorPicker({
  required BuildContext context, // Receive BuildContext as a parameter
  required String title,
  required Color color,
  required ValueChanged<Color> onColorChanged,
}) {
  return Column(
    children: [
      Text(title),
      SizedBox(height: 8),
      GestureDetector(
        onTap: () {
          _showColorPickerDialog(context, color,
              onColorChanged); // Pass the context to the function
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ],
  );
}

void _showColorPickerDialog(
    BuildContext context, Color color, ValueChanged<Color> onColorChanged) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ColorPickerDialog(
        initialColor: color,
        onColorChanged: onColorChanged,
      );
    },
  );
}
