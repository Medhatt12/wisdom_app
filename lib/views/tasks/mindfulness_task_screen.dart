import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wisdom_app/views/tasks/drawing_game_screen.dart';
import 'package:wisdom_app/widgets/player_widget.dart';

class MindfulnessScreen extends StatefulWidget {
  @override
  _MindfulnessScreenState createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends State<MindfulnessScreen> {
  String selectedColor = '';
  TextEditingController colorController = TextEditingController();
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Start playing the audio when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await audioPlayer.setSourceAsset('audio/music.mp3',
          mimeType: 'audio/mpeg');
      audioPlayer.state = PlayerState.paused;
    });
  }

  @override
  void dispose() {
    // Stop the audio player when disposing of the screen
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mindfulness'),
      ),
      body: SingleChildScrollView(
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
            Text(
              'Selected Color: $selectedColor',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            // Text Field for selecting colors
            TextField(
              controller: colorController,
              decoration: InputDecoration(
                labelText: 'Choose a Color',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    colorController.clear();
                    setState(() {
                      selectedColor = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedColor = value;
                });
              },
            ),
            SizedBox(height: 20),
            // Drawing Area (You can use a package like drawing_animation for this)
            // Replace the Container below with your drawing area widget
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
  final String selectedColor;

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
              'Selected Color: $selectedColor',
              style: TextStyle(fontSize: 16),
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
