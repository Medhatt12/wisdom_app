import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdom_app/controllers/language_provider.dart';
import 'package:wisdom_app/controllers/questionnaire_controller.dart';
import 'package:wisdom_app/controllers/theme_provider.dart';
import 'package:wisdom_app/models/invitation.dart';
import 'package:wisdom_app/services/auth_service.dart';
import 'package:wisdom_app/services/invitation_service.dart';
import 'package:wisdom_app/views/caterpillar_game_screen.dart';
import 'package:wisdom_app/views/custom_avatar_screen.dart';
import 'package:wisdom_app/views/home_screen.dart';
import 'package:wisdom_app/views/login_screen.dart';
import 'package:wisdom_app/views/settings_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wisdom_app/views/splash_screen.dart';
import 'package:wisdom_app/views/tasks/drawing_game_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:badges/badges.dart' as badges;

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
        Provider<InvitationService>(create: (_) => InvitationService()),
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
          initialRoute: '',
          routes: {
            '': (context) => SplashScreen(),
            '/login': (context) => LoginPage(),
            '/home': (context) => const MainScreen(),
            '/avatar': (context) => CustomAvatarScreen(),
            '/caterpillar': (context) => CaterpillarGameScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/drawing': (context) => DrawingPage(),
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
  late Stream<List<Invitation>> _invitationsStream;
  int _selectedIndex = 0;
  late User? _currentUser;
  final List<Widget> _screens = [
    HomeScreen(),
    CaterpillarGameScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
    _invitationsStream = _getInvitationsStream();
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

  Stream<List<Invitation>> _getInvitationsStream() {
    return Provider.of<InvitationService>(context, listen: false)
        .getInvitationsCount(Provider.of<AuthService>(context, listen: false)
                .getCurrentUser()
                ?.uid ??
            '');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (_currentUser != null) {
      return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor:
              themeProvider.themeData.colorScheme.primaryContainer,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bathtub_rounded),
              label: 'Caterpillar',
            ),
            BottomNavigationBarItem(
              icon: StreamBuilder<List<Invitation>>(
                stream: _invitationsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    int invitationsCount = snapshot.data!.length;
                    return badges.Badge(
                      badgeContent: Text(
                        '$invitationsCount',
                        style: TextStyle(color: Colors.white),
                      ),
                      child: Icon(Icons.settings),
                    );
                  } else {
                    return Icon(Icons.settings);
                  }
                },
              ),
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
