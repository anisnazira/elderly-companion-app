import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/elderly_bottom_nav_bar.dart'; 
import '../elderly/appointment/appointment_page.dart';
import '../elderly/medication/medication_page.dart';
import '../elderly/steps/steps_page.dart';
import '../elderly/profile/profile_page.dart';
import 'package:url_launcher/url_launcher.dart';
// Only import android_intent_plus if running on Android
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:android_intent_plus/android_intent.dart';

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

  // -------------------- TIME UPDATE --------------------
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

  // -------------------- PAGE SWITCHING --------------------
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

  // -------------------- HOME CONTENT --------------------
  Widget _homeContent() {
    final size = MediaQuery.of(context).size;

    // Dummy numbers for testing
    final String testPhoneNumber = "0123456789";
    final String testEmergencyNumber = "999";

    // -------------------- BUTTON ACTIONS --------------------
    
    void _openDialer(String number) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent = AndroidIntent(
          action: 'android.intent.action.DIAL', // DIAL instead of CALL
          data: 'tel:$number',
          );
          intent.launch();
        }
    }


    void _openWhatsApp(String number) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'https://wa.me/$number',
          );
          intent.launch();
         }
    }


    void _openCamera() {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent = AndroidIntent(action: 'android.media.action.IMAGE_CAPTURE');
        intent.launch();
      } else {
        print("Camera intent only works on Android");
      }
    }

    void _openCalendar() {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          package: 'com.android.calendar',
        );
        intent.launch();
      } else {
        print("Calendar intent only works on Android");
      }
    }

    void _emergencyCall() {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final intent = AndroidIntent(
          action: 'android.intent.action.DIAL',  // DIAL instead of CALL
          data: 'tel:$testEmergencyNumber',      // Pre-fill number
          );
          intent.launch();
          } else {
            print("Emergency dialer only works on Android emulator/device");
        }
      }


    // -------------------- UI --------------------
    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: size.height * 0.06),

          // Time
          Text(
            _currentTime,
            style: TextStyle(
              fontSize: size.width * 0.12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: size.height * 0.005),

          // Day
          Text(
            _currentDay,
            style: TextStyle(
              fontSize: size.width * 0.045,
              color: Colors.black54,
            ),
          ),

          SizedBox(height: size.height * 0.02),

          // Steps & Medication info
          Text(
            "Steps Taken: 3450 | Next Med: 10:30 AM",
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: size.height * 0.04),

          // Buttons
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ColoredActionButton(
                        label: "Call",
                        icon: Icons.phone,
                        color: const Color(0xFF345EE9),
                        onTap: () => _openDialer(testPhoneNumber),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: ColoredActionButton(
                        label: "WhatsApp",
                        icon: Icons.message,
                        color: const Color(0xFFF5C853),
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
                        color: const Color(0xFFF5C853),
                        onTap: _openCamera,
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: ColoredActionButton(
                        label: "Calendar",
                        icon: Icons.calendar_today,
                        color: const Color(0xFF345EE9),
                        onTap: _openCalendar,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.025),

                ColoredActionButton(
                  label: "Emergency",
                  icon: Icons.warning,
                  color: const Color(0xFFE2735D),
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

  // -------------------- SCAFFOLD --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

// -------------------- ACTION BUTTON --------------------
class ColoredActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  const ColoredActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
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
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: size.width * 0.1,
              color: Colors.white,
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              label,
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
