import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart'; 
import 'medication/medication_page.dart'; 
import 'appointment/appointment_page.dart';

class ElderlyHomePage extends StatefulWidget {
  const ElderlyHomePage({super.key});

  @override
  State<ElderlyHomePage> createState() => _ElderlyHomePageState();
}

class _ElderlyHomePageState extends State<ElderlyHomePage> {
  int _selectedIndex = 2; 

  final List<Widget> _pages = [
    const ElderlyMedicationListPage(), // Index 0
    const AppointmentPage(),           // Index 1
    const Center(child: Text("Home Dashboard")), // Index 2
    const Center(child: Text("Steps Tracker")),  // Index 3
    const Center(child: Text("Profile Page")),   // Index 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elderly Dashboard'),
      ),
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