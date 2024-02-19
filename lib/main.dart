import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/views/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wisdom_app/views/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  FirebaseApp app = await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDdAXblVu0F0TOMkVkCIGP4-KwloNqkVhI",
      appId: "1:672555705798:web:6346c22c1fe142b4ebfec7",
      messagingSenderId: "672555705798",
      projectId: "wisdom-app-62f23",
    ),
  );
  final languageProvider = LanguageProvider();
  final questionnaireController = QuestionnaireController();
  languageProvider.toggleLanguage(); // Set default language to English
  await questionnaireController
      .loadQuestions(languageProvider.locale.languageCode);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: questionnaireController),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(),
            '/home': (context) => HomePage(),
          },
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          locale: Provider.of<LanguageProvider>(context).locale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('de', 'DE'),
          ],
          home: HomePage(),
        );
      },
    );
  }
}
