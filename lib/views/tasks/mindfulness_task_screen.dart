import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:wisdom_app/views/tasks/drawing_game_screen.dart';
import 'package:wisdom_app/widgets/player_widget.dart';

class MindfulnessScreen extends StatefulWidget {
  @override
  _MindfulnessScreenState createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends State<MindfulnessScreen> {
  Color selectedColor = Colors.transparent;
  late AudioPlayer audioPlayer;
  bool _isAudioLoading = true; // State variable to track audio loading

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Start playing the audio when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await audioPlayer.setSourceAsset('audio/music.mp3',
            mimeType: 'audio/mpeg');
        setState(() {
          _isAudioLoading = false; // Set loading to false when audio is loaded
        });
        audioPlayer.state = PlayerState.paused;
      } catch (e) {
        setState(() {
          _isAudioLoading =
              false; // Set loading to false even if there's an error
        });
        print('Error loading audio: $e');
      }
    });
  }

  @override
  void dispose() {
    // Stop the audio player when disposing of the screen
    audioPlayer.dispose();
    super.dispose();
  }

  void _pickColor() async {
    Color pickedColor = selectedColor;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (Color color) {
                pickedColor = color;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Select'),
              onPressed: () {
                setState(() {
                  selectedColor = pickedColor;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mindfulness'),
      ),
      body: _isAudioLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loader if audio is loading
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mindfulness',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Take yourself about 15 minutes time and go to a place which is calm and where you will not be disturbed. Use headphones to listen to the following audio. It is a guided meditation. Try to be open towards your feelings. If unpleasant feelings arise during the exercise, you can interrupt or end it any time.',
                  ),
                  SizedBox(height: 20),
                  // Audio Player
                  PlayerWidget(player: audioPlayer),
                  SizedBox(height: 20),
                  Text(
                    'If your current feeling towards your relationship with ___ would have colours, which colours would that be? The next step will be the creation of a painting. Don’t think too much, chose the colours that resonate with your feelings.',
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickColor,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      color: selectedColor,
                      child: Center(
                        child: Text(
                          'Tap to pick a color',
                          style: TextStyle(
                            color: useWhiteForeground(selectedColor)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Display the picked color
                  // if (selectedColor != Colors.transparent) ...[
                  //   Text(
                  //     'Picked Color:',
                  //     style: TextStyle(fontSize: 16),
                  //   ),
                  //   Container(
                  //     width: double.infinity,
                  //     height: 50,
                  //     color: selectedColor,
                  //     margin: EdgeInsets.only(top: 10),
                  //   ),
                  // ],
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Stop the audio player
                      audioPlayer.stop();

                      // Navigate to DrawingGameScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DrawingPage(),
                        ),
                      );
                    },
                    child: Text('Continue to Drawing'),
                  ),
                ],
              ),
            ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final Color selectedColor;

  SummaryScreen(this.selectedColor);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Summary with Painting',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Display the selected color and painting
            Text(
              'Selected Color:',
              style: TextStyle(fontSize: 16),
            ),
            Container(
              width: 100,
              height: 100,
              color: selectedColor,
              margin: EdgeInsets.only(top: 10),
            ),
            SizedBox(height: 10),
            // Replace the Container below with your painting widget
            Container(
              width: 200,
              height: 200,
              color: Colors.grey.shade300,
              child: Center(
                child: Text('Painting'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
