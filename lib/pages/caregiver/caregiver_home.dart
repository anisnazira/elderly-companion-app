import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../caregiver/profile/profile_caregiver.dart';
import '../caregiver/appointment/add_appointment_page.dart';
import '../caregiver/medication/add_medication_page.dart';
import 'package:buddi/animated_action_button.dart';
import 'package:buddi/widgets/caregiver_bottom_nav_bar.dart';

const Color whiteColor = Color(0xFFFDFBFE);

class CaregiverHomePage extends StatefulWidget {
  const CaregiverHomePage({super.key});

  @override
  State<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  int _currentIndex = 2; // default Home

  // ---------------- PAGE SWITCH ----------------
  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const AddMedicationPage();
      case 1:
        return const AddAppointmentPage();
      case 2:
        return _homeContent();
      case 3:
        return const ProfileCaregiverPage();
      default:
        return _homeContent();
    }
  }

  // ---------------- HOME CONTENT ----------------
  Widget _homeContent() {
    final size = MediaQuery.of(context).size;

    final hour = int.parse(DateFormat('kk').format(DateTime.now()));
    String greeting = 'Good Evening';
    if (hour >= 5 && hour < 12) greeting = 'Good Morning';
    if (hour >= 12 && hour < 18) greeting = 'Good Afternoon';

    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.04),

          // Greeting
          Center(
            child: Text(
              greeting,
              style: TextStyle(
                fontSize: size.width * 0.05,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(height: 100),

          Text(
            "Hello Caregiver,",
            style: TextStyle(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 25),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: AnimatedActionButton(
                  label: "Add Medication",
                  icon: Icons.medical_services,
                  gradientColors: const [Color(0xFF7F00FF), Color(0xFFE100FF)],
                  onTap: () => setState(() => _currentIndex = 0),
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: AnimatedActionButton(
                  label: "Add Appointment",
                  icon: Icons.calendar_today,
                  gradientColors: const [Color(0xFF36D1DC), Color(0xFF5B86E5)],
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- SCAFFOLD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: _getBody(),
      bottomNavigationBar: CaregiverBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
