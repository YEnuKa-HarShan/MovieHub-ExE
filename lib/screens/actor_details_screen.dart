import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_details_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ActorDetailsScreen extends StatefulWidget {
  final Actor actor;

  const ActorDetailsScreen({super.key, required this.actor});

  @override
  State<ActorDetailsScreen> createState() => _ActorDetailsScreenState();
}

class _ActorDetailsScreenState extends State<ActorDetailsScreen> {
  List<Movie> movies = [];
  Map<String, String> movieImageMap = {};
  Map<String, List<Map<String, String>>> actorRolesMap = {};

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      // Load movies.json
      final String moviesResponse = await rootBundle.loadString('assets/movies.json');
      final List<dynamic> moviesData = json.decode(moviesResponse);

      // Load movie_images.json
      final String imagesResponse = await rootBundle.loadString('assets/items/movie_images.json');
      final List<dynamic> imagesData = json.decode(imagesResponse);

      // Load actor_roles.json
      final String rolesResponse = await rootBundle.loadString('assets/items/actor_roles.json');
      final List<dynamic> rolesData = json.decode(rolesResponse);

      // Create a map of title to portrait image
      movieImageMap = {
        for (var item in imagesData)
          if (item['title']?.isNotEmpty ?? false) item['title'].toString(): item['portrait'].toString()
      };

      // Create a map of actor name to roles
      actorRolesMap = {
        for (var item in rolesData)
          if (item['actor_name']?.isNotEmpty ?? false)
            item['actor_name'].toString(): List<Map<String, String>>.from(
                (item['roles'] ?? []).map((role) => {
                      'movie_id': role['movie_id'].toString(),
                      'character': role['character'].toString(),
                    }))
      };

      setState(() {
        movies = moviesData.map((json) => Movie.fromJson(json)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading movies: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: CustomScrollView(
        slivers: [
          // Minimal SliverAppBar for navigation
          SliverAppBar(
            backgroundColor: const Color(0xFF00203F),
            elevation: 4,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            expandedHeight: 56.0, // Minimal height for the app bar
          ),
          // Actor Profile Section
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Actor Image
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 75, // Matches the previous 150x150 dimensions (radius = diameter/2)
                      foregroundImage: AssetImage('assets/actors/${widget.actor.image}'),
                      backgroundColor: Colors.grey.shade800, // Fallback background color
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white70,
                        size: 50,
                      ), // Fallback child if image fails to load
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Actor Name
                Text(
                  widget.actor.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 16),
                // Actor Info Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biography',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Known For',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Acting in blockbuster movies and award-winning performances.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Movies Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Movies',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          // Movies Grid
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: movies.isEmpty
                ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                : Builder(
                    builder: (context) {
                      // Get movie IDs for the actor from actorRolesMap
                      final actorRoles = actorRolesMap[widget.actor.name] ?? [];
                      final actorMovieIds = actorRoles.map((role) => role['movie_id']).toSet();

                      final actorMovies = movies.where((movie) => actorMovieIds.contains(movie.id)).toList();

                      if (actorMovies.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'No movies found for ${widget.actor.name}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      // Sort movies by year (present to old)
                      actorMovies.sort((a, b) {
                        final yearA = int.tryParse(a.year) ?? 0;
                        final yearB = int.tryParse(b.year) ?? 0;
                        return yearB.compareTo(yearA); // Descending order (present to old)
                      });

                      return SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 4 columns
                          childAspectRatio: 2 / 3, // Maintain 2/3 aspect ratio
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final movie = actorMovies[index];
                            return _MovieItem(movie: movie, movieImageMap: movieImageMap);
                          },
                          childCount: actorMovies.length,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Widget for each movie item with hover effect
class _MovieItem extends StatefulWidget {
  final Movie movie;
  final Map<String, String> movieImageMap;

  const _MovieItem({required this.movie, required this.movieImageMap});

  @override
  _MovieItemState createState() => _MovieItemState();
}

class _MovieItemState extends State<_MovieItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Get portrait image from movieImageMap, fallback to movie.portrait
    final portraitImage = widget.movieImageMap[widget.movie.title] ?? widget.movie.portrait;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movie: widget.movie),
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: Stack(
          children: [
            // Movie Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/portrait/$portraitImage',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity, // Take full height of the grid item
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
              ),
            ),
            // Sliding Container with Gradient and Title/Year
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: _isHovered ? 0 : -100, // Slide up on hover
              child: Container(
                height: 100, // Height of the sliding container
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      const Color(0xFF00203F).withOpacity(0.8),
                      const Color(0xFF0D3B66).withOpacity(0.8),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      widget.movie.title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                    ),
                    Text(
                      widget.movie.year,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}