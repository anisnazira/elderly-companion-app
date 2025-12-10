// lib/pages/caregiver/caregiver_home.dart
import 'package:flutter/material.dart';

class CaregiverHomePage extends StatelessWidget {
  const CaregiverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Home')),
      body: const Center(child: Text('Caregiver Home Page')),
    );
  }
}
