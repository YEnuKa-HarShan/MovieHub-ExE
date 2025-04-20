import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:moviehub_exe/widgets/checker_tool_widget.dart';

class CastCheckerScreen extends StatefulWidget {
  const CastCheckerScreen({super.key});

  @override
  _CastCheckerScreenState createState() => _CastCheckerScreenState();
}

class _CastCheckerScreenState extends State<CastCheckerScreen> with SingleTickerProviderStateMixin {
  List<dynamic> movies = [];
  Map<String, dynamic>? selectedMovie;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadMovies();
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _loadMovies() async {
    final String response = await rootBundle.loadString('assets/movies.json');
    final data = jsonDecode(response);
    setState(() {
      movies = data.where((movie) {
        final cast = movie['cast'];
        return cast != null && cast is List && cast.isNotEmpty && cast[0] != "";
      }).toList();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 250; // Account for 250px sidebar
    const leftColumnWidth = 380.0;
    final rightColumnWidth = screenWidth - leftColumnWidth;

    return Container(
      width: screenWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00203F), Color(0xFF004080)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Movie List
          Container(
            width: leftColumnWidth,
            color: Colors.white.withOpacity(0.1),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white.withOpacity(0.05),
                  child: const Row(
                    children: [
                      Text(
                        'Movies',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: movies.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];
                            return Card(
                              color: Colors.white.withOpacity(0.1),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                title: Text(
                                  movie['title'],
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  'Year: ${movie['year']}\nCast: ${movie['cast'].join(', ')}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedMovie = movie;
                                    _animationController.reset();
                                    _animationController.forward();
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          // Right Column: Checker Tool or Placeholder
          Container(
            width: rightColumnWidth > 0 ? rightColumnWidth : 50, // Ensure non-negative width
            color: Colors.transparent,
            child: selectedMovie != null
                ? CheckerToolWidget(
                    key: ValueKey(selectedMovie!['title']), // Ensure widget rebuilds
                    selectedMovie: selectedMovie!)
                : Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 200), // Constrain width for better fit
                        child: Card(
                          color: Colors.white.withOpacity(0.05), // Lower opacity for better background fit
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.movie_filter,
                                  size: 50,
                                  color: Colors.white70,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Select a Movie',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Choose a movie from the list to check its cast details',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}