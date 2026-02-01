import 'package:flutter/material.dart';
import 'profile/profile_caregiver.dart';
import 'appointment/appointment_list.dart';
import 'medication/medication_list.dart';
import '../../widgets/caregiver_bottom_nav_bar.dart';

class CaregiverHomePage extends StatefulWidget {
  const CaregiverHomePage({super.key});
  @override
  State<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  int _selectedIndex = 2;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const MedicationListPage(),    // index 0
      const AppointmentListPage(),   // index 1
      const Center(child: Text('Home Page')), // index 2
      const Center(child: Text('Steps Page')), // index 3
      const ProfileCaregiverPage(),  // index 4
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caregiver Home')),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CaregiverBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}