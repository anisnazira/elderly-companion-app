import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/elderly_bottom_nav_bar.dart';
import '../elderly/appointment/appointment_page.dart';
import '../elderly/medication/medication_page.dart';
import '../elderly/steps/steps_page.dart';
import '../elderly/profile/profile_page.dart';

// ---------------- COLORS ----------------
const Color blackColor = Color(0xFF000000);
const Color whiteColor = Color(0xFFFDFBFE);

// ---------------- ELDERLY HOME PAGE ----------------
class ElderlyHomePage extends StatefulWidget {
  final String selectedRole;

  const ElderlyHomePage({super.key, required this.selectedRole});

  @override
  State<ElderlyHomePage> createState() => _ElderlyHomePageState();
}

class _ElderlyHomePageState extends State<ElderlyHomePage> {
  int _currentIndex = 2; // home tab
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  // ---------------- PAGE SWITCH ----------------
  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const MedicationPage();
      case 1:
        return const AppointmentPage();
      case 2:
        return _homeContent();
      case 3:
        return const StepsPage();
      case 4:
        return ProfilePage(initialRole: widget.selectedRole);
      default:
        return _homeContent();
    }
  }

  // ---------------- HOME CONTENT ----------------
  Widget _homeContent() {
    final size = MediaQuery.of(context).size;

    const testPhone = "0123456789";
    const emergencyNumber = "999";

    // ---------- ACTIONS ----------
    void _dial(String number) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        AndroidIntent(action: 'android.intent.action.DIAL', data: 'tel:$number').launch();
      }
    }

    void _whatsapp(String number) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'https://wa.me/$number',
        ).launch();
      }
    }

    void _camera() {
      if (defaultTargetPlatform == TargetPlatform.android) {
        AndroidIntent(action: 'android.media.action.IMAGE_CAPTURE').launch();
      }
    }

    void _calendar() {
      if (defaultTargetPlatform == TargetPlatform.android) {
        AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'content://com.android.calendar/time/', // tells it to open calendar
          ).launch();
      }
    }

    // ---------- GREETING ----------
    final hour = int.parse(DateFormat('kk').format(DateTime.now()));
    String greeting = 'Good Evening';
    if (hour >= 5 && hour < 12) greeting = 'Good Morning';
    if (hour >= 12 && hour < 18) greeting = 'Good Afternoon';

    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: SingleChildScrollView(
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
            SizedBox(height: 50),

            /// Hello User
            Text(
              "Hello ${_user?.displayName ?? 'Darshak'},",
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),

            /// Steps & Next Med
            Text(
              "Steps Taken & Next Medication",
              style: TextStyle(
                fontSize: size.width * 0.07,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),

            /// Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ),
            ),
            SizedBox(height: 30),

            /// ---------------- 5 BUTTONS ----------------
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AnimatedActionButton(
                        label: "Call",
                        icon: Icons.phone,
                        gradient: const [Color(0xFF36D1DC), Color(0xFF5B86E5)],
                        onTap: () => _dial(testPhone),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: AnimatedActionButton(
                        label: "WhatsApp",
                        icon: Icons.message,
                        gradient: const [Color(0xFF56ab2f), Color(0xFFa8e063)],
                        onTap: () => _whatsapp(testPhone),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.025),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedActionButton(
                        label: "Camera",
                        icon: Icons.camera_alt,
                        gradient: const [Color(0xFF7F00FF), Color(0xFFE100FF)],
                        onTap: _camera,
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: AnimatedActionButton(
                        label: "Calendar",
                        icon: Icons.calendar_today,
                        gradient: const [Color(0xFFF7971E), Color(0xFFFFD200)],
                        onTap: _calendar,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.025),
                AnimatedActionButton(
                  label: "Emergency",
                  icon: Icons.warning,
                  fullWidth: true,
                  gradient: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                  onTap: () => _dial(emergencyNumber),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SCAFFOLD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: _getBody(),
      bottomNavigationBar: ElderlyBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
