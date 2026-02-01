import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../caregiver/profile/profile_caregiver.dart';
import '../caregiver/appointment/add_appointment_page.dart';
import '../caregiver/medication/add_medication_page.dart';

// ---------------- COLORS ----------------
const Color blackColor = Color(0xFF000000);
const Color whiteColor = Color(0xFFFDFBFE);

class CaregiverHomePage extends StatefulWidget {
  const CaregiverHomePage({super.key});

  @override
  State<CaregiverHomePage> createState() => _CaregiverHomePageState();
}

class _CaregiverHomePageState extends State<CaregiverHomePage> {
  int _currentIndex = 2; // default Home tab

  // ---------------- PAGE SWITCH ----------------
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

  // ---------------- HOME CONTENT ----------------
  Widget _homeContent() {
    final size = MediaQuery.of(context).size;

    // ---------- GREETING ----------
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

          /// Greeting
          Center(
            child: Text(
              greeting,
              style: TextStyle(
                fontSize: size.width * 0.05,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 100),

          /// Hello User
          Text(
            "Hello Caregiver,",
            style: TextStyle(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 25),

          /// ---------------- 2 BUTTONS ----------------
          Row(
            children: [
              Expanded(
                child: AnimatedActionButton(
                  label: "Add Medication",
                  icon: Icons.medical_services,
                  gradient: const [Color(0xFF7F00FF), Color(0xFFE100FF)],
                  onTap: () => setState(() => _currentIndex = 0),
                ),
              ),
              SizedBox(width: size.width * 0.04),
              Expanded(
                child: AnimatedActionButton(
                  label: "Add Appointment",
                  icon: Icons.calendar_today,
                  gradient: const [Color(0xFF36D1DC), Color(0xFF5B86E5)],
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
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

// ===================================================================
// ================= ANIMATED ACTION BUTTON ===========================
// ===================================================================
class AnimatedActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradient;
  final bool fullWidth;

  const AnimatedActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.gradient,
    this.fullWidth = false,
  });

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.08,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: scale,
        child: Container(
          height: size.height * 0.12,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 18,
                offset: Offset(0, 12),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: size.width * 0.12, color: Colors.white),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
