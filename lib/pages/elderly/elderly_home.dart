import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'medication/medication_page.dart';
import 'appointment/appointment_page.dart';
import '../widgets/home_page_content.dart'; // keep Home Page placeholder
import '../widgets/steps_page.dart';
import '../widgets/profile_page.dart';

class ElderlyHomePage extends StatefulWidget {
  const ElderlyHomePage({super.key});

  @override
  State<ElderlyHomePage> createState() => _ElderlyHomePageState();
}

class _ElderlyHomePageState extends State<ElderlyHomePage> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    const MedicationPage(),    // index 0
    const AppointmentPage(),   // index 1
    const Center(child: Text('Home Page')), // index 2
    const Center(child: Text('Steps Page')), // index 3
    const Center(child: Text('Profile Page')), // index 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elderly Home')),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
