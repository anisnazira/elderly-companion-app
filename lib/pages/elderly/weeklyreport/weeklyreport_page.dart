import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'weeklyshow.dart';

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

  Future<void> _showWeeklyReport() async {
    setState(() {
      statusMessage = "Preparing weekly report...";
    });

    try {
      await WeeklyFamilyUpdate.sendIfNeeded();

      setState(() {
        statusMessage = "Weekly report ready ✅";
      });

      _loadLastSentDate();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WeeklyShowPage(),
        ),
      );
    } catch (e) {
      setState(() {
        statusMessage = "Failed to load weekly report ❌";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weekly Family Update",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
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
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            /// ✅ WHITE TEXT + WHITE ICON BUTTON
            ElevatedButton.icon(
              onPressed: _showWeeklyReport,
              icon: const Icon(
                Icons.bar_chart,
                color: Colors.white,
              ),
              label: const Text(
                "Show Weekly Report",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyFamilyUpdate {
  static Future<void> sendIfNeeded() async {
    final box = Hive.box('stepsBox');

    final lastSent = box.get('lastWeeklyReport');

    if (lastSent != null) {
      final lastDate = DateTime.parse(lastSent);
      if (DateTime.now().difference(lastDate).inDays < 7) {
        return;
      }
    }

    final weeklySteps =
        Map<String, int>.from(box.get('weekly', defaultValue: {}));

    int totalSteps = weeklySteps.values.fold(0, (a, b) => a + b);

    final medsTaken = box.get('medsTaken', defaultValue: 0);
    final medsMissed = box.get('medsMissed', defaultValue: 0);
    final appointments = box.get('appointments', defaultValue: 0);
    final emergencies = box.get('emergencies', defaultValue: 0);

    await FirebaseFirestore.instance.collection('weekly_reports').add({
      'familyEmail': 'family@email.com',
      'steps': totalSteps,
      'medsTaken': medsTaken,
      'medsMissed': medsMissed,
      'appointments': appointments,
      'emergencies': emergencies,
      'createdAt': FieldValue.serverTimestamp(),
    });

    box.put('lastWeeklyReport', DateTime.now().toIso8601String());
  }
}