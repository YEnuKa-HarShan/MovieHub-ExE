import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moviehub_exe/pages/administrator/movies_data.dart';
import 'package:moviehub_exe/pages/administrator/actors_data.dart';
import 'package:moviehub_exe/pages/administrator/cast_checker.dart';
import 'package:moviehub_exe/pages/administrator/users_data.dart';
import 'package:moviehub_exe/pages/administrator/tv_series_data.dart';

class AdministratorScreen extends StatefulWidget {
  const AdministratorScreen({super.key});

  @override
  _AdministratorScreenState createState() => _AdministratorScreenState();
}

class _AdministratorScreenState extends State<AdministratorScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MoviesDataScreen(),
    const ActorsDataScreen(),
    const CastCheckerScreen(),
    const UserDataScreen(),
    const TvSeriesDataScreen(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Movies Data', 'icon': Icons.movie},
    {'title': 'Actors Data', 'icon': Icons.person},
    {'title': 'Cast Checker', 'icon': Icons.check_circle},
    {'title': 'Users Data', 'icon': Icons.people},
    {'title': 'TV Series Data', 'icon': Icons.tv},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userData');
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00203F), Color(0xFF004080)],
          ),
        ),
        child: Row(
          children: [
            // Sidebar
            Container(
              width: 250,
              color: Colors.white.withOpacity(0.1),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white54),
                  // Menu Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: _selectedIndex == index
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                          elevation: _selectedIndex == index ? 4 : 0,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              _menuItems[index]['icon'],
                              color: Colors.white70,
                            ),
                            title: Text(
                              _menuItems[index]['title'],
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                                _animationController.reset();
                                _animationController.forward();
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: Color(0xFF00203F)),
                      label: const Text(
                        'Log out',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00203F),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _pages[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}