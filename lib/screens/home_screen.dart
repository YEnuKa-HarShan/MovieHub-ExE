import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moviehub_exe/pages/movies_page.dart';
import 'package:moviehub_exe/pages/home_page.dart';
import 'package:moviehub_exe/pages/tv_series_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0: Home, 1: Movies, 2: TV Series
  String _searchQuery = ''; // Store the current search query
  late TextEditingController _searchController; // Controller for search bar

  // List of pages to render based on selected index
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Initialize pages with searchQuery
    _updatePages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Update pages with the current search query
  void _updatePages() {
    _pages = [
      HomePage(searchQuery: _searchQuery),
      MoviesPage(onLogoutTap: () {}, searchQuery: _searchQuery),
      TvSeriesPage(searchQuery: _searchQuery),
    ];
  }

  // Handle navigation item selection and reset search
  void _onNavItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _searchQuery = ''; // Reset search query
      _searchController.clear(); // Clear search bar text
      _updatePages(); // Update pages with empty search query
    });
  }

  @override
  Widget build(BuildContext context) {
    // Function to show logout dialog when logout icon is tapped
    void showLogoutDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00203F), Color(0xFF0D3B66)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Warning',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want logout now?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: Text(
                          'No, I don\'t want logout now',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setBool('isLoggedIn', false);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (Route<dynamic> route) => false,
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4D4D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00203F), Color(0xFF0D3B66)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        title: LayoutBuilder(
          builder: (context, constraints) {
            double totalFixedWidth = 200 + 300 + 50;
            double searchBarWidth = constraints.maxWidth - totalFixedWidth;
            searchBarWidth = searchBarWidth < 150 ? 150 : searchBarWidth;

            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Column 1: MovieHub title
                Container(
                  width: 200,
                  padding: const EdgeInsets.only(left: 16.0),
                  child: const Text(
                    'MovieHub',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                      shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                    ),
                  ),
                ),
                // Column 2: Navigation items
                Container(
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _onNavItemSelected(0),
                            child: Text(
                              'Home',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: _selectedIndex == 0 ? Colors.white : Colors.white.withOpacity(0.7),
                                fontWeight: _selectedIndex == 0 ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 2,
                            width: _selectedIndex == 0 ? 40 : 0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _onNavItemSelected(1),
                            child: Text(
                              'Movies',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: _selectedIndex == 1 ? Colors.white : Colors.white.withOpacity(0.7),
                                fontWeight: _selectedIndex == 1 ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 2,
                            width: _selectedIndex == 1 ? 40 : 0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => _onNavItemSelected(2),
                            child: Text(
                              'TV Series',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: _selectedIndex == 2 ? Colors.white : Colors.white.withOpacity(0.7),
                                fontWeight: _selectedIndex == 2 ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 2,
                            width: _selectedIndex == 2 ? 40 : 0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Column 3: Search bar
                Container(
                  width: searchBarWidth,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _updatePages(); // Update pages with new search query
                        });
                      },
                    ),
                  ),
                ),
                // Column 4: Logout icon
                Container(
                  width: 50,
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: showLogoutDialog,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.logout,
                        color: Colors.white.withOpacity(0.7),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex], // Render the selected page
    );
  }
}