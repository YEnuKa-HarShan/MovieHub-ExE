import 'package:flutter/material.dart';
import 'package:moviehub_exe/pages/maintenance_page.dart'; // Adjust the import path based on your project structure

class AdministratorScreen extends StatelessWidget {
  const AdministratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MaintenancePage(),
    );
  }
}