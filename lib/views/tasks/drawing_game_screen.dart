import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wisdom_app/views/home_screen.dart';
import 'package:wisdom_app/views/tasks/similarities_and_differences_screen.dart';
import 'package:wisdom_app/widgets/drawn_line.dart';
import 'package:wisdom_app/widgets/sketcher.dart';

import '../../main.dart';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  GlobalKey _globalKey = GlobalKey();
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
          // Save image to Firestore
          await saveImageToFirestore(pngBytes);
        }
      }
    } catch (e) {
      print('Error saving drawing: $e');
    }
  }

  Future<String> saveImageToFirestore(Uint8List imageData) async {
    try {
      // Convert Uint8List to base64 string
      String base64Image = base64Encode(imageData);

      // Save base64 image data to Firestore
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance.collection('tasks_answers').doc(uid).set(
          {
            'drawing': {
              'image_data': base64Image,
            },
          },
          SetOptions(
              merge:
                  true)); // Use merge option to avoid overwriting existing data

      print('Image data saved to Firestore');

      // Return the saved base64 image data
      return base64Image;
    } catch (e) {
      print('Error saving image data: $e');
      return ''; // Return empty string or handle error appropriately
    }
  }

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = DrawnLine([], Colors.black, 5.0);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          await saveDrawing();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        },
        child: Icon(Icons.check),
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
          padding: EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: Sketcher(
                  lines: [line!],
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
        padding: EdgeInsets.all(4.0),
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

    List<Offset> path = List.from(line!.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);
    currentLineStreamController.add(line!);
  }

  void onPanEnd(DragEndDetails details) {
    lines = List.from(lines)..add(line!);
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
          Divider(
            height: 10.0,
          ),
          FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Select a color'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: selectedColor,
                        onColorChanged: changeColor,
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
        ],
      ),
    );
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: CircleAvatar(
        child: Icon(
          Icons.delete,
          size: 20.0,
        ),
      ),
    );
  }
}
