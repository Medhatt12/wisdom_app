import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/views/tasks/drawing_game_screen.dart';
import 'package:wisdom_app/widgets/player_widget.dart';

class MindfulnessScreen extends StatefulWidget {
  const MindfulnessScreen({super.key});

  @override
  _MindfulnessScreenState createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends State<MindfulnessScreen> {
  Color selectedColor = Colors.transparent;
  late AudioPlayer audioPlayer;
  bool _isAudioLoading = true;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.stop);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await audioPlayer.setSourceAsset('audio/music.mp3',
            mimeType: 'audio/mpeg');
        setState(() {
          _isAudioLoading = false;
        });
        audioPlayer.state = PlayerState.paused;
      } catch (e) {
        setState(() {
          _isAudioLoading = false;
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
          title: const Text('Pick a color'),
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
              child: const Text('Select'),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindfulness'),
        backgroundColor: themeProvider.themeData.colorScheme.background,
      ),
      body: _isAudioLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Take yourself about 15 minutes time and go to a place which is calm and where you will not be disturbed. Use headphones to listen to the following audio. It is a guided meditation. Try to be open towards your feelings. If unpleasant feelings arise during the exercise, you can interrupt or end it any time.',
                  ),
                  const SizedBox(height: 20),
                  // Audio Player
                  Container(
                    decoration: BoxDecoration(
                      color: themeProvider.currentThemeMode.colorScheme.primary
                          .withAlpha((themeProvider.currentThemeMode.colorScheme
                                      .primary.alpha -
                                  90)
                              .clamp(0, 255)
                              .toInt()),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PlayerWidget(player: audioPlayer),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'If your current feeling towards your relationship with ___ would have colours, which colours would that be? The next step will be the creation of a painting. Don’t think too much, chose the colours that resonate with your feelings.',
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      audioPlayer.stop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DrawingPage(),
                        ),
                      );
                    },
                    child: const Text('Continue to Drawing'),
                  ),
                ],
              ),
            ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final Color selectedColor;

  const SummaryScreen(this.selectedColor, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Summary with Painting',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Selected Color:',
              style: TextStyle(fontSize: 16),
            ),
            Container(
              width: 100,
              height: 100,
              color: selectedColor,
              margin: const EdgeInsets.only(top: 10),
            ),
            const SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              color: Colors.grey.shade300,
              child: const Center(
                child: Text('Painting'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
