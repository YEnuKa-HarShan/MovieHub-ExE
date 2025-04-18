import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:moviehub_exe/models/movie.dart'; // Adjust path if needed
import 'package:moviehub_exe/screens/movie_details_screen.dart'; // Adjust path if needed
import 'package:moviehub_exe/widgets/no_results_widget.dart'; // Import the new widget
import 'dart:convert';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MoviesPage extends StatefulWidget {
  final VoidCallback onLogoutTap; // Callback for logout action
  final String searchQuery;

  const MoviesPage({super.key, required this.onLogoutTap, this.searchQuery = ''});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> with TickerProviderStateMixin {
  List<Movie> movies = [];
  List<Movie> filteredMovies = [];
  String selectedLanguage = '';
  final ScrollController _scrollController = ScrollController();
  Map<String, String> movieImageMap = {}; // Map to store title-to-portrait mappings

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMovies();
  }

  @override
  void didUpdateWidget(covariant MoviesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _filterMovies(widget.searchQuery);
    }
  }

  Future<void> _loadMovies() async {
    try {
      // Load movies.json
      final String moviesResponse = await DefaultAssetBundle.of(context).loadString('assets/movies.json');
      final List<dynamic> moviesData = json.decode(moviesResponse);

      // Load movie_images.json
      final String imagesResponse = await DefaultAssetBundle.of(context).loadString('assets/items/movie_images.json');
      final List<dynamic> imagesData = json.decode(imagesResponse);

      // Create a map of title to portrait image
      movieImageMap = {
        for (var item in imagesData) item['title'].toString(): item['portrait'].toString()
      };

      setState(() {
        movies = moviesData.map((json) => Movie.fromJson(json)).toList().reversed.toList();
        _filterMovies(widget.searchQuery); // Initial filter with searchQuery
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading movies: $e')),
        );
      }
    }
  }

  void _onScroll() {
    // Pagination can be added if needed
  }

  void _filterMovies(String query) {
    setState(() {
      filteredMovies = movies
          .where((movie) =>
              movie.title.toLowerCase().contains(query.toLowerCase()) &&
              (selectedLanguage.isEmpty || movie.language == selectedLanguage) &&
              (movieImageMap[movie.title]?.isNotEmpty ?? false))
          .toList();
    });
  }

  void _filterByLanguage(String language) {
    setState(() {
      selectedLanguage = (selectedLanguage == language) ? '' : language;
      _filterMovies(widget.searchQuery);
    });
  }

  Future<bool> _onWillPop() async {
    if (selectedLanguage.isNotEmpty) {
      setState(() {
        selectedLanguage = '';
        _filterMovies(widget.searchQuery);
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        color: const Color(0xFF0A1A2F),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.black.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLanguageButton('English'),
                  _buildLanguageButton('French'),
                  _buildLanguageButton('Hindi'),
                  _buildLanguageButton('Kannada'),
                  _buildLanguageButton('Korean'),
                  _buildLanguageButton('Malayalam'),
                  _buildLanguageButton('Tamil'),
                  _buildLanguageButton('Telugu'),
                ],
              ),
            ),
            Expanded(
              child: movies.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredMovies.isEmpty && widget.searchQuery.isNotEmpty
                      ? NoResultsWidget(searchQuery: widget.searchQuery) // Use the new widget
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 2 / 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: filteredMovies.length,
                          itemBuilder: (context, index) {
                            final movie = filteredMovies[index];
                            return MovieCard(
                              movie: movie,
                              searchQuery: widget.searchQuery,
                              movieImageMap: movieImageMap,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(String language) {
    bool isSelected = selectedLanguage == language;

    final textPainter = TextPainter(
      text: TextSpan(
        text: language,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final buttonWidth = textPainter.width + 24;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => _filterByLanguage(language),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: buttonWidth,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00A8E8) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 6)]
                : null,
          ),
          child: Center(
            child: Text(
              language,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class MovieCard extends StatefulWidget {
  final Movie movie;
  final String searchQuery;
  final Map<String, String> movieImageMap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.searchQuery,
    required this.movieImageMap,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _toggleCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      isFront = !isFront;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _toggleCard(),
      onExit: (_) => _toggleCard(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);
          final isBack = _animation.value > 0.5;

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isBack
                ? Transform(
                    transform: Matrix4.identity()..rotateY(3.14159),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  )
                : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final portraitImage = widget.movieImageMap[widget.movie.title] ?? widget.movie.portrait;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            portraitImage.isNotEmpty
                ? Image.asset(
                    'assets/portrait/$portraitImage',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white70,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey.shade800,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white70,
                        size: 40,
                      ),
                    ),
                  ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.movie.language,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFF00203F), Color(0xFF0D3B66)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHighlightedTitle(widget.movie.title, widget.searchQuery),
            const SizedBox(height: 4),
            Text(
              widget.movie.year,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsScreen(movie: widget.movie),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A8E8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'See More',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedTitle(String title, String query) {
    if (query.isEmpty) {
      return Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 14,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerTitle = title.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    while (start < title.length) {
      final index = lowerTitle.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: title.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: title.substring(start, index)));
      }
      final end = index + query.length;
      spans.add(
        TextSpan(
          text: title.substring(index, end),
          style: const TextStyle(
            color: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = end;
    }

    return Text.rich(
      TextSpan(
        children: spans,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}