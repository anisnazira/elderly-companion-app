import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'appointmentforElderly/appointment_list.dart';
import 'medicationforElderly/medication_list.dart';
import '../widgets/home_page_content.dart';
import '../widgets/steps_page.dart';
import '../widgets/profile_page.dart';

class CaregiverHomePage extends StatefulWidget {
  const CaregiverHomePage({super.key});
  
  @override
  State<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    const MedicationListPage(),      // index 0 - Updated to list page
    const AppointmentListPage(),     // index 1 - You'll need to create this similar to medication
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
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
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