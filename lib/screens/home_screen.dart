import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> movies = [];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final String response = await rootBundle.loadString('assets/movies.json');
      final data = jsonDecode(response);
      setState(() {
        movies = data;
      });
    } catch (e) {
      print('Error loading movies: $e');
    }
  }

  // Filter movies for a given category
  List<dynamic> _filterMoviesForCategory(String category) {
    if (category == 'Most Viewed') {
      // Simulate "Most Viewed" by taking the first 15 movies
      return movies.take(15).toList();
    } else if (category == 'Latest Released') {
      // Sort by year (descending) and take the latest 15
      var sortedMovies = List.from(movies)
        ..sort((a, b) => int.parse(b['year']).compareTo(int.parse(a['year'])));
      return sortedMovies.take(15).toList();
    } else if (category == 'TV Series') {
      // Filter for TV Series (assuming "Series" in title)
      return movies
          .where((movie) =>
              movie['title'].toString().toLowerCase().contains('series'))
          .toList();
    } else {
      // Filter by language (English, Hindi, Tamil, etc.)
      return movies
          .where((movie) =>
              movie['language'].toString().toLowerCase() ==
              category.toLowerCase())
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background for contrast
      appBar: AppBar(
        title: const Text('MovieHub'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double padding = 16.0; // Consistent padding

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: maxWidth,
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
                  color: Colors.blue.shade700,
                  child: const Text(
                    'Welcome to MovieHub',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Category Sections
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategorySection('Most Viewed', maxWidth, padding),
                      const SizedBox(height: 24),
                      _buildCategorySection('Latest Released', maxWidth, padding),
                      const SizedBox(height: 24),
                      _buildCategorySection('English', maxWidth, padding),
                      const SizedBox(height: 24),
                      _buildCategorySection('Hindi', maxWidth, padding),
                      const SizedBox(height: 24),
                      _buildCategorySection('Tamil', maxWidth, padding),
                      const SizedBox(height: 24),
                      _buildCategorySection('Telugu', maxWidth, padding),
                      const SizedBox(height: 24),
                      _buildCategorySection('Kannada', maxWidth, padding),
                      const SizedBox(height: 24),
                      _buildCategorySection('Malayalam', maxWidth, padding),
                      const SizedBox(height: 24),
                      _buildCategorySection('TV Series', maxWidth, padding),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(String category, double maxWidth, double padding) {
    const double itemWidth = 110.0; // Increased by 10% (100 * 1.10)
    const double aspectRatio = 2 / 3; // Portrait aspect ratio (width:height = 2:3)
    const double itemHeight = itemWidth / aspectRatio; // 110 * 1.5 = 165px
    const double itemPadding = 8.0; // Padding between items
    const double seeMoreWidth = 60.0; // Width of See More button (including padding)

    // Filter movies for this category
    List<dynamic> categoryMovies = _filterMoviesForCategory(category);
    // Determine if See More button should be shown
    bool showSeeMore = categoryMovies.length > 15 &&
        !['Most Viewed', 'Latest Released'].contains(category);
    // Limit items to 15 for Most Viewed and Latest Released
    int totalItems = ['Most Viewed', 'Latest Released'].contains(category)
        ? categoryMovies.length.clamp(0, 15)
        : (showSeeMore ? 15 : categoryMovies.length);

    // Calculate number of visible items
    double availableWidth = maxWidth - (2 * padding); // Subtract horizontal padding
    int visibleItems = ((availableWidth - (showSeeMore ? seeMoreWidth : 0)) /
            (itemWidth + 2 * itemPadding))
        .floor();
    visibleItems = visibleItems < 1 ? 1 : visibleItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal Scroll Bar
        SizedBox(
          height: itemHeight + 60, // Height of image + space for title/year
          child: categoryMovies.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'No movies available',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: totalItems + (showSeeMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (showSeeMore && index == totalItems) {
                      // See More Button
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: itemPadding),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Add navigation or logic for See More
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16),
                              backgroundColor: Colors.blue,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }
                    // Movie Item
                    final movie = categoryMovies[index % categoryMovies.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: itemPadding),
                      child: Container(
                        width: itemWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Portrait Image with fixed aspect ratio
                            AspectRatio(
                              aspectRatio: aspectRatio, // 2:3 ratio (width:height)
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  movie['portrait_image'],
                                  width: itemWidth,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Movie Title
                            Text(
                              movie['title'],
                              style: const TextStyle(
                                fontSize: 14, // Unchanged
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Year
                            Text(
                              movie['year'],
                              style: TextStyle(
                                fontSize: 12, // Unchanged
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}