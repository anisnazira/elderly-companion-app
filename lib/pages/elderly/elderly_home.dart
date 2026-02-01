import 'dart:async';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart' show Border, BorderRadius, BorderSide, BoxDecoration, BuildContext, Center, Color, Colors, Column, Container, CrossAxisAlignment, EdgeInsets, Expanded, FontWeight, GestureDetector, Icon, IconData, Icons, MainAxisAlignment, MediaQuery, Padding, Row, Scaffold, SizedBox, State, StatefulWidget, StatelessWidget, TargetPlatform, Text, TextStyle, VoidCallback, Widget;
import 'package:intl/intl.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../../widgets/elderly_bottom_nav_bar.dart';
import '../elderly/appointment/appointment_page.dart';
import '../elderly/medication/medication_page.dart';
import '../elderly/steps/steps_page.dart';
import 'package:buddi/pages/elderly/profile/profile_page.dart';

// ---------------- COLOR PALETTE ----------------
const Color blackColor = Color(0xFF000000);
const Color whiteColor = Color(0xFFFDFBFE);
const Color brightPurpleColor = Color(0xFF7F00FF);
const Color lightGreenColor = Color(0xFFD9FD6D);
const Color orangeColor = Color(0xFFE9914E);
const Color blueColor = Color(0xFF52B1FF);
const Color redColor = Color(0xFFFF8C75);

// ---------------- ELDERLY HOME PAGE ----------------
class ElderlyHomePage extends StatefulWidget {
  final String selectedRole;

  const ElderlyHomePage({
    super.key,
    required this.selectedRole,
  });

  @override
  State<ElderlyHomePage> createState() => _ElderlyHomePageState();
}

class _ElderlyHomePageState extends State<ElderlyHomePage> {
  late String _currentTime;
  late String _currentDay;
  int _currentIndex = 2; // Home tab
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    _timer?.cancel();

    final now = DateTime.now();
    _currentTime = DateFormat('hh:mm a').format(now);
    _currentDay = DateFormat('EEEE, MMM d, yyyy').format(now);

    _timer = Timer(
      Duration(seconds: 60 - now.second),
      () {
        if (mounted) {
          setState(_updateTime);
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---------------- PAGE SWITCHING ----------------
  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return const ElderlyMedicationListPage();
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

    final String testPhoneNumber = "0123456789";
    final String testEmergencyNumber = "999";

    // ---------------- BUTTON ACTIONS ----------------
    void _openDialer(String number) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent =
            AndroidIntent(action: 'android.intent.action.DIAL', data: 'tel:$number');
        intent.launch();
      }
    }

    void _openWhatsApp(String number) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent = AndroidIntent(
            action: 'android.intent.action.VIEW', data: 'https://wa.me/$number');
        intent.launch();
      }
    }

    void _openCamera() {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent = AndroidIntent(action: 'android.media.action.IMAGE_CAPTURE');
        intent.launch();
      }
    }

    void _openCalendar() {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent =
            AndroidIntent(action: 'android.intent.action.MAIN', package: 'com.android.calendar');
        intent.launch();
      }
    }

    void _emergencyCall() {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent = AndroidIntent(
          action: 'android.intent.action.DIAL',
          data: 'tel:$testEmergencyNumber',
        );
        intent.launch();
      }
    }

    // ---------------- UI ----------------
    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: size.height * 0.06),

          // TIME
          Text(
            _currentTime,
            style: TextStyle(
              fontSize: size.width * 0.12,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),

          SizedBox(height: size.height * 0.005),

          // DAY
          Text(
            _currentDay,
            style: TextStyle(
              fontSize: size.width * 0.045,
              color: blackColor.withOpacity(0.7),
            ),
          ),

          SizedBox(height: size.height * 0.02),

          // Steps & Medication info
          Text(
            "Steps Taken: 3450 | Next Med: 10:30 AM",
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: blackColor,
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // ---------------- BUTTON GRID ----------------
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ColoredActionButton(
                        label: "Call",
                        icon: Icons.phone,
                        color: blueColor,
                        onTap: () => _openDialer(testPhoneNumber),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: ColoredActionButton(
                        label: "WhatsApp",
                        icon: Icons.message,
                        color: orangeColor,
                        onTap: () => _openWhatsApp(testPhoneNumber),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.025),
                Row(
                  children: [
                    Expanded(
                      child: ColoredActionButton(
                        label: "Camera",
                        icon: Icons.camera_alt,
                        color: brightPurpleColor,
                        onTap: _openCamera,
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: ColoredActionButton(
                        label: "Calendar",
                        icon: Icons.calendar_today,
                        color: lightGreenColor,
                        onTap: _openCalendar,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.025),
                // Emergency button spans full width
                ColoredActionButton(
                  label: "Emergency",
                  icon: Icons.warning,
                  color: redColor,
                  onTap: _emergencyCall,
                  fullWidth: true,
                ),
              ],
            ),
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
      bottomNavigationBar: ElderlyBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ---------------- GOOGLE-STYLE BOTTOM-LINE BUTTON ----------------
class ColoredActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color; // background
  final VoidCallback onTap;
  final bool fullWidth;

  const ColoredActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.color = Colors.white,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size.height * 0.12,
        width: fullWidth ? double.infinity : null,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            bottom: BorderSide(
              color: blackColor, // thick bottom line
              width: 4,          // thickness
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: size.width * 0.12,
              color: blackColor, // icon black
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              label,
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: blackColor, // text black
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}