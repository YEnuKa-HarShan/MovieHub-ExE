import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String searchQuery;

  const HomePage({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1A2F), Color(0xFF0D3B66)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              searchQuery.isEmpty
                  ? 'Home Page Under Maintenance'
                  : 'Search Not Available',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              searchQuery.isEmpty
                  ? 'We are working on bringing you the best experience!'
                  : 'Search functionality is unavailable during maintenance.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}