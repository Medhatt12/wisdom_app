import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/l10n/l10n.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/views/avatar_customization_screen.dart';
import 'package:wisdom_app/views/caterpillar_game_screen.dart';
import 'package:wisdom_app/views/home_screen.dart';
import 'package:wisdom_app/views/login_screen.dart';
import 'package:wisdom_app/views/settings_screen.dart'; // Import SettingsScreen
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final languageProvider = LanguageProvider();
  final questionnaireController = QuestionnaireController();
  languageProvider.toggleLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: questionnaireController),
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(),
            '/home': (context) => MainScreen(),
            '/avatar': (context) => AvatarCustomizationScreen(),
            '/caterpillar': (context) => CaterpillarGameScreen(),
            '/settings': (context) =>
                SettingsScreen(), // Route for settings screen
          },
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          locale: Provider.of<LanguageProvider>(context).locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('de'),
          ],
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late User? _currentUser;
  final List<Widget> _screens = [
    HomeScreen(),
    AvatarCustomizationScreen(),
    CaterpillarGameScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() async {
    AuthService authService = Provider.of<AuthService>(context, listen: false);
    User? user = authService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Create Avatar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bathtub_rounded),
              label: 'Caterpillar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    } else {
      return LoginPage();
    }
  }
}
