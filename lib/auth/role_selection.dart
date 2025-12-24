import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../pages/elderly/elderly_home.dart';
import '../../pages/caregiver/caregiver_home.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ElderlyHomePage()),
                );
              },
              child: const Text('Elderly'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CaregiverHomePage()),
                );
              },
              child: const Text('Caregiver'),
            ),
          ],
        ),
      ),
    );
  }
}
