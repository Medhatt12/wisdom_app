import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ADayInTheLifeTwineScreen extends StatefulWidget {
  const ADayInTheLifeTwineScreen({super.key});

  @override
  State<ADayInTheLifeTwineScreen> createState() =>
      _ADayInTheLifeTwineScreenState();
}

class _ADayInTheLifeTwineScreenState extends State<ADayInTheLifeTwineScreen> {
  InAppWebViewController? webViewController;
  String? twineHtmlContent;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _loadHtmlFromAssets(); // Load the HTML file from assets on initialization
  }

  // Load the HTML file from the assets and store it in a string
  Future<void> _loadHtmlFromAssets() async {
    try {
      // Load the HTML file as a string
      String fileText =
          await rootBundle.loadString('assets/ADayInTheLifeOf.html');

      // Store the HTML content directly for web usage
      setState(() {
        twineHtmlContent = fileText;
      });
    } catch (e) {
      print("Error loading HTML file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("A Day in the Life - Twine"),
      ),
      body: Column(
        children: [
          progress < 1.0
              ? LinearProgressIndicator(value: progress)
              : const SizedBox(),
          Expanded(
            child: twineHtmlContent != null
                ? InAppWebView(
                    initialData: InAppWebViewInitialData(
                        data:
                            twineHtmlContent!), // Load the HTML content directly
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                      ),
                    ),
                    onWebViewCreated: (controller) {
                      webViewController = controller;
                    },
                    onProgressChanged: (controller, prog) {
                      setState(() {
                        progress = prog / 100;
                      });
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }
}
