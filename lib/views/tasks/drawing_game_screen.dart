import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/main.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';
import 'package:wisdom_app/widgets/drawn_line.dart';
import 'package:wisdom_app/widgets/sketcher.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = GlobalKey();
  List<DrawnLine> lines = [];
  DrawnLine line = DrawnLine([], Colors.black, 5.0);
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;

  StreamController<List<DrawnLine>> linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController =
      StreamController<DrawnLine>.broadcast();

  void changeColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  List<Color> generateColorGradients(Color color) {
    final hslColor = HSLColor.fromColor(color);
    final lighterColor = hslColor
        .withLightness((hslColor.lightness + 0.2).clamp(0.0, 1.0))
        .toColor();
    final darkerColor = hslColor
        .withLightness((hslColor.lightness - 0.2).clamp(0.0, 1.0))
        .toColor();
    return [lighterColor, color, darkerColor];
  }

  Future<void> saveDrawing() async {
    try {
      RenderRepaintBoundary? boundary = _globalKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        ui.Image image = await boundary.toImage();
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          Uint8List pngBytes = byteData.buffer.asUint8List();
          await saveImageToFirestore(pngBytes);
        }
      }
    } catch (e) {
      print('Error saving drawing: $e');
    }
  }

  Future<String> saveImageToFirestore(Uint8List imageData) async {
    try {
      String base64Image = base64Encode(imageData);
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance
          .collection('tasks_answers')
          .doc(uid)
          .set({
        'drawing': {
          'image_data': base64Image,
        },
      }, SetOptions(merge: true));

      print('Image data saved to Firestore');
      return base64Image;
    } catch (e) {
      print('Error saving image data: $e');
      return '';
    }
  }

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = DrawnLine([], Colors.black, 5.0);
    });
  }

  void showSummaryBottomSheet(
      BuildContext context, Uint8List imageBytes, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: themeProvider.themeData.colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Summary of Your Drawing',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Image.memory(imageBytes, height: 200, width: 200),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Note: Once you submit, you cannot go back to this task.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                          child: const Text('Edit'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await saveDrawing();
                            final authService = Provider.of<AuthService>(
                                context,
                                listen: false);
                            final invitationService =
                                Provider.of<InvitationService>(context,
                                    listen: false);
                            invitationService.incrementTasksFinished(
                                authService.getCurrentUser()!.uid);
                            Navigator.pop(context);
                            _showTaskCompletionDialog(
                                context); // Show the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Custom Task Completion Dialog
  void _showTaskCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ShakeImage(), // Custom widget to animate stage 1 image
                const SizedBox(height: 16),
                const Text(
                  "Keep going to turn the wisdom caterpillar into a beautiful butterfly!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                    );
                  },
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          buildAllPaths(context),
          buildCurrentPath(context),
          buildStrokeToolbar(),
          buildColorToolbar(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        key: UniqueKey(),
        onPressed: () async {
          RenderRepaintBoundary? boundary = _globalKey.currentContext
              ?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary != null) {
            ui.Image image = await boundary.toImage();
            ByteData? byteData =
                await image.toByteData(format: ui.ImageByteFormat.png);
            if (byteData != null) {
              Uint8List pngBytes = byteData.buffer.asUint8List();
              showSummaryBottomSheet(context, pngBytes, themeProvider);
            }
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: Sketcher(
                  lines: [line],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        padding: const EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<DrawnLine>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: lines,
              ),
            );
          },
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    RenderBox? box = context.findRenderObject() as RenderBox?;
    Offset point = box!.globalToLocal(details.globalPosition);
    line = DrawnLine([point], selectedColor, selectedWidth);
  }

  void onPanUpdate(DragUpdateDetails details) {
    RenderBox? box = context.findRenderObject() as RenderBox?;
    Offset point = box!.globalToLocal(details.globalPosition);

    List<Offset> path = List.from(line.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);
    currentLineStreamController.add(line);
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line);
    linesStreamController.add(lines);
  }

  Widget buildStrokeToolbar() {
    return Positioned(
      bottom: 100.0,
      left: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildStrokeButton(5.0),
          buildStrokeButton(10.0),
          buildStrokeButton(15.0),
        ],
      ),
    );
  }

  Widget buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWidth = strokeWidth;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          decoration: BoxDecoration(
              color: selectedColor, borderRadius: BorderRadius.circular(50.0)),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Positioned(
      top: 40.0,
      left: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildClearButton(),
          const Divider(
            height: 10.0,
          ),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Select a color'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (color) {
                          changeColor(color);
                          Navigator.pop(context);
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              );
            },
            child: Icon(
              Icons.palette,
              color: selectedColor,
            ),
          ),
          _buildColorGradients(selectedColor)
        ],
      ),
    );
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: const CircleAvatar(
        child: Icon(
          Icons.delete,
          size: 20.0,
        ),
      ),
    );
  }

  Widget _buildColorGradients(Color color) {
    List<Color> gradients = generateColorGradients(color);
    return Column(
      children: gradients.map((Color gradientColor) {
        return GestureDetector(
          onTap: () {
            changeColor(gradientColor);
          },
          child: Container(
            width: 40.0,
            height: 40.0,
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
              color: gradientColor,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Shake effect for the task completion image
class ShakeImage extends StatefulWidget {
  const ShakeImage({super.key});

  @override
  _ShakeImageState createState() => _ShakeImageState();
}

class _ShakeImageState extends State<ShakeImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true); // Make it shake
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_controller.value * 10 - 5, 0),
          child: Image.asset('assets/images/STAGE1.png', height: 100),
        );
      },
    );
  }
}
