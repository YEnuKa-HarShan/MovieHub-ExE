import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/administrator_screen.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop platforms
  if ([
    TargetPlatform.windows,
    TargetPlatform.macOS,
    TargetPlatform.linux,
  ].contains(defaultTargetPlatform)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(900, 600),
      minimumSize: Size(900, 600),
      maximumSize: Size(900, 600),
      center: true,
      skipTaskbar: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setResizable(false);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MovieHubApp());
}

class MovieHubApp extends StatelessWidget {
  const MovieHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieHub',
      theme: ThemeData(
        primaryColor: const Color(0xFF00203F),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF0D3B66),
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
          bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
          titleLarge: TextStyle(color: Color(0xFFFFFFFF)),
        ),
      ),
      home: const AuthCheck(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdministratorScreen(),
      },
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        try {
          final userData = json.decode(userDataString);
          final role = userData['role'];

          if (!mounted) return;

          // Navigate based on role
          if (role == 'Admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (role == 'User') {
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            // Invalid role, go to login
            Navigator.pushReplacementNamed(context, '/login');
          }
        } catch (e) {
          // Invalid userData, go to login
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // No user data, go to login
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      // Not logged in, go to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}