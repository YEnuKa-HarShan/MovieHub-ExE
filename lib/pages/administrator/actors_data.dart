import 'package:flutter/material.dart';
import 'package:moviehub_exe/widgets/maintenance_widget.dart';

class ActorsDataScreen extends StatelessWidget {
  const ActorsDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00203F), Color(0xFF004080)],
        ),
      ),
      child: const MaintenancePage(),
    );
  }
}