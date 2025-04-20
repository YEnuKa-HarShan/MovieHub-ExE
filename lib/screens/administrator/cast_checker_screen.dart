import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../widgets/checker_tool_widget.dart';

class CastCheckerScreen extends StatefulWidget {
  const CastCheckerScreen({super.key});

  @override
  _CastCheckerScreenState createState() => _CastCheckerScreenState();
}

class _CastCheckerScreenState extends State<CastCheckerScreen> {
  List<dynamic> movies = [];
  Map<String, dynamic>? selectedMovie;

  @override
  void initState() {
    super.initState();
    _loadMovies();
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const leftColumnWidth = 600.0;
    final rightColumnWidth = screenWidth > 900 ? screenWidth - leftColumnWidth : 300;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Movie List
          Container(
            width: leftColumnWidth,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.blue[800],
                  child: const Row(
                    children: [
                      Text(
                        'Movies',
                        style: TextStyle(
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
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                title: Text(
                                  movie['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Year: ${movie['year']}\nCast: ${movie['cast'].join(', ')}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedMovie = movie;
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
          // Right Column: Checker Tool
          Container(
            width: rightColumnWidth.toDouble(),
            color: Colors.grey[100],
            child: selectedMovie != null
                ? CheckerToolWidget(selectedMovie: selectedMovie!)
                : const Center(
                    child: Text(
                      'Select a movie to check cast',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}