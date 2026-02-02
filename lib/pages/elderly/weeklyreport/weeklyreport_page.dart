import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WeeklyReportPage extends StatefulWidget {
  const WeeklyReportPage({super.key});

  @override
  State<WeeklyReportPage> createState() => _WeeklyReportPageState();
}

class _WeeklyReportPageState extends State<WeeklyReportPage> {
  String statusMessage = "Idle";
  String lastSentMessage = "Never sent";

  @override
  void initState() {
    super.initState();
    _loadLastSentDate();
  }

  /// Load last sent date from Hive
  void _loadLastSentDate() {
    final box = Hive.box('stepsBox');
    final lastSent = box.get('lastWeeklyReport');
    if (lastSent != null) {
      final date = DateTime.parse(lastSent);
      setState(() {
        lastSentMessage =
            "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
      });
    }
  }

  /// Send weekly report
  Future<void> _sendWeeklyReport() async {
    setState(() {
      statusMessage = "Sending weekly report...";
    });

    try {
      await WeeklyFamilyUpdate.sendIfNeeded();

      setState(() {
        statusMessage = "Weekly report sent successfully ✅";
      });

      // Update last sent date display
      _loadLastSentDate();

      // --- Removed automatic navigation to Pedometer ---
    } catch (e) {
      setState(() {
        statusMessage = "Failed to send weekly report ❌";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Family Update"),
        backgroundColor: const Color(0xFF6C63FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Last sent: $lastSentMessage",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              statusMessage,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _sendWeeklyReport,
              icon: const Icon(Icons.send),
              label: const Text("Send Now"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// WEEKLY REPORT LOGIC (SERVICE)
/// ===============================
class WeeklyFamilyUpdate {
  static Future<void> sendIfNeeded() async {
    final box = Hive.box('stepsBox');

    // Check last sent date
    final lastSent = box.get('lastWeeklyReport');

    if (lastSent != null) {
      final lastDate = DateTime.parse(lastSent);
      if (DateTime.now().difference(lastDate).inDays < 7) {
        return; // Not time yet
      }
    }

    // --- GET DATA ---
    final weeklySteps =
        Map<String, int>.from(box.get('weekly', defaultValue: {}));

    int totalSteps = weeklySteps.values.fold(0, (a, b) => a + b);

    final medsTaken = box.get('medsTaken', defaultValue: 0);
    final medsMissed = box.get('medsMissed', defaultValue: 0);
    final appointments = box.get('appointments', defaultValue: 0);
    final emergencies = box.get('emergencies', defaultValue: 0);

    // --- SEND TO FIREBASE ---
    await FirebaseFirestore.instance
        .collection('weekly_reports')
        .add({
      'familyEmail': 'family@email.com',
      'steps': totalSteps,
      'medsTaken': medsTaken,
      'medsMissed': medsMissed,
      'appointments': appointments,
      'emergencies': emergencies,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Save sent date
    box.put('lastWeeklyReport', DateTime.now().toIso8601String());
  }
}