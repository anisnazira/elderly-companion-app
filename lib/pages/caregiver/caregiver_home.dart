import 'package:flutter/material.dart';
import '../caregiver/profile/profile_caregiver.dart';
import '../caregiver/appointment/add_appointment_page.dart';
import '../caregiver/medication/add_medication_page.dart';

class CaregiverHomePage extends StatefulWidget {
  const CaregiverHomePage({super.key});

  @override
  State<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  int _currentIndex = 2;

  
  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const AddMedicationPage(); // Medication page
      case 1:
        return const AddAppointmentPage(); // Appointment page
      case 2:
        return _homeContent(); // Home
      case 3:
        return const ProfileCaregiverPage(); // Profile
      default:
        return _homeContent();
    }
  }

  Widget _homeContent() {
    return const Center(
      child: Text(
        "Caregiver Home",
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Medication',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
