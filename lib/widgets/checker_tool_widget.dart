import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class CheckerToolWidget extends StatefulWidget {
  final Map<String, dynamic> selectedMovie;

  const CheckerToolWidget({super.key, required this.selectedMovie});

  @override
  _CheckerToolWidgetState createState() => _CheckerToolWidgetState();
}

class _CheckerToolWidgetState extends State<CheckerToolWidget> {
  List<String> actors = [];
  List<bool> isValidActor = [];

  @override
  void initState() {
    super.initState();
    _loadActors();
  }

  Future<void> _loadActors() async {
    final String response = await rootBundle.loadString('assets/actors.json');
    final List<dynamic> data = jsonDecode(response);
    final actorNames = data.map((actor) => actor['name'].toString()).toList();

    final cast = widget.selectedMovie['cast'] as List<dynamic>;
    setState(() {
      actors = cast.map((e) => e.toString()).toList();
      isValidActor = actors.map((actor) => actorNames.contains(actor)).toList();
    });
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
                : ListView.builder(
                    itemCount: actors.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        elevation: 2,
                        child: ListTile(
                          title: Text(
                            actors[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: isValidActor[index] ? Colors.black : Colors.red,
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