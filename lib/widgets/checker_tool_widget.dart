import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CheckerToolWidget extends StatefulWidget {
  final Map<String, dynamic> selectedMovie;

  const CheckerToolWidget({super.key, required this.selectedMovie});

  @override
  _CheckerToolWidgetState createState() => _CheckerToolWidgetState();
}

class _CheckerToolWidgetState extends State<CheckerToolWidget> with SingleTickerProviderStateMixin {
  List<String> actors = [];
  List<bool> isValidActor = [];
  bool allActorsValid = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadActors();
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

  @override
  void didUpdateWidget(covariant CheckerToolWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMovie != oldWidget.selectedMovie) {
      _loadActors();
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _loadActors() async {
    final String response = await rootBundle.loadString('assets/actors.json');
    final List<dynamic> data = jsonDecode(response);
    final actorNames = data.map((actor) => actor['actor_name'].toString()).toList();

    final cast = widget.selectedMovie['cast'] as List<dynamic>;
    setState(() {
      actors = cast.map((e) => e.toString()).toList();
      isValidActor = actors.map((actor) => actorNames.contains(actor)).toList();
      allActorsValid = isValidActor.isNotEmpty && isValidActor.every((valid) => valid);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue[800],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              'Cast Checker: ${widget.selectedMovie['title']}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: actors.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : allActorsValid
                    ? Center(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Card(
                              color: Colors.white.withOpacity(0.05),
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
                                      Icons.celebration,
                                      size: 50,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Congratulations!',
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
                                      'All cast members are updated',
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
                      )
                    : ListView.builder(
                        itemCount: actors.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.white.withOpacity(0.1),
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                actors[index],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: isValidActor[index] ? Colors.white : Colors.red,
                                  fontWeight: isValidActor[index] ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                              trailing: Icon(
                                isValidActor[index] ? Icons.check_circle : Icons.error,
                                color: isValidActor[index] ? Colors.green : Colors.red,
                              ),
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