import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import 'actor_details_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  List<Actor> actors = [];
  List<CastDisplay> castDisplay = [];
  Map<String, String> movieImageMap = {};
  Map<String, List<String>> movieDescriptionMap = {};
  Map<String, Map<String, String>> teraboxLinkMap = {};
  Map<String, List<Map<String, String>>> actorRolesMap = {};

  @override
  void initState() {
    super.initState();
    _loadActors();
    _loadMovieData();
  }

  Future<void> _loadActors() async {
    try {
      // Load actors.json
      final String actorsResponse = await rootBundle.loadString('assets/actors.json');
      final List<dynamic> actorsData = json.decode(actorsResponse);

      // Load actor_roles.json
      final String rolesResponse = await rootBundle.loadString('assets/items/actor_roles.json');
      final List<dynamic> rolesData = json.decode(rolesResponse);

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
        actors = actorsData.map((json) => Actor.fromJson(json)).toList();
        _prepareCastDisplay();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading actors: $e')),
        );
      }
    }
  }

  Future<void> _loadMovieData() async {
    try {
      // Load movie_images.json
      final String imagesResponse = await rootBundle.loadString('assets/items/movie_images.json');
      final List<dynamic> imagesData = json.decode(imagesResponse);
      movieImageMap = {
        for (var item in imagesData)
          if (item['title']?.isNotEmpty ?? false) item['title'].toString(): item['landscape'].toString()
      };

      // Load movie_descriptions.json
      final String descriptionsResponse = await rootBundle.loadString('assets/items/movie_descriptions.json');
      final List<dynamic> descriptionsData = json.decode(descriptionsResponse);
      movieDescriptionMap = {
        for (var item in descriptionsData)
          if (item['title']?.isNotEmpty ?? false)
            item['title'].toString(): List<String>.from(item['description'] ?? [])
      };

      // Load terabox_links.json
      final String teraboxResponse = await rootBundle.loadString('assets/items/terabox_links.json');
      final List<dynamic> teraboxData = json.decode(teraboxResponse);
      teraboxLinkMap = {
        for (var item in teraboxData)
          if (item['title']?.isNotEmpty ?? false)
            item['title'].toString(): {
              'link': item['link']?.toString() ?? '',
              'access_code': item['access_code']?.toString() ?? ''
            }
      };

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading movie data: $e')),
        );
      }
    }
  }

  void _prepareCastDisplay() {
    castDisplay = actors
        .where((actor) => widget.movie.cast.contains(actor.name))
        .map((actor) {
      // Get roles for this actor from actorRolesMap
      final actorRoles = actorRolesMap[actor.name] ?? [];
      // Find the role for the current movie
      final role = actorRoles.firstWhere(
        (r) => r['movie_id'] == widget.movie.id,
        orElse: () => {'movie_id': widget.movie.id, 'character': 'Unknown Character'},
      );
      return CastDisplay(
        actorName: actor.name,
        characterName: role['character']!,
        image: actor.image,
      );
    }).toList();
  }

  void _handleDownload(BuildContext context) {
    final teraboxData = teraboxLinkMap[widget.movie.title] ?? {'link': '', 'access_code': ''};
    final link = teraboxData['link'] ?? '';
    final accessCode = teraboxData['access_code'] ?? '';

    if (link.isEmpty || link.toLowerCase() == "coming soon") {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0A1A2F),
          title: const Text(
            'Coming Soon',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'This movie will be available soon!',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF00A8E8),
                  fontSize: 14,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0A1A2F),
          title: const Text(
            'Access Code',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          content: Text(
            '${widget.movie.title} ${widget.movie.year}.rar access code is $accessCode.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF00A8E8),
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final Uri url = Uri.parse(link);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not launch the link',
                          style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
                        ),
                        backgroundColor: Color(0xFF00203F),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A8E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Download Now',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  List<TextSpan> _parseDescription(String description) {
    final List<TextSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in boldRegex.allMatches(description)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: description.substring(lastIndex, match.start),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF00A8E8),
        ),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < description.length) {
      spans.add(TextSpan(
        text: description.substring(lastIndex),
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    // Get landscape image and description from maps, with fallback
    final landscapeImage = movieImageMap[widget.movie.title] ?? widget.movie.landscape;
    final descriptionList = movieDescriptionMap[widget.movie.title] ?? widget.movie.description;
    final descriptionText = descriptionList.isNotEmpty
        ? descriptionList.join('\n\n')
        : 'Description coming soon';

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.movie.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/landscape/$landscapeImage',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white70,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0A1A2F).withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color(0xFF00203F),
            elevation: 4,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.movie.language,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        widget.movie.year,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Genre: ${widget.movie.genre.join(", ")}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      children: _parseDescription(descriptionText),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cast',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: actors.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: castDisplay.map((cast) {
                                final actor = actors.firstWhere(
                                  (a) => a.name == cast.actorName,
                                  orElse: () => Actor(
                                    id: 'unknown',
                                    name: cast.actorName,
                                    image: cast.image,
                                    roles: [],
                                  ),
                                );
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ActorDetailsScreen(actor: actor),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundImage: AssetImage('assets/actors/${cast.image}'),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          cast.actorName,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          cast.characterName,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleDownload(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D3B66),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.blueAccent.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Download',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}