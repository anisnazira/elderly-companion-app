import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PedometerPage extends StatefulWidget {
  const PedometerPage({super.key});

  @override
  State<PedometerPage> createState() => _PedometerPageState();
}

class _PedometerPageState extends State<PedometerPage> {
  StreamSubscription<StepCount>? _stepStream;
  int todaySteps = 3000;
  Map<String, int> weeklySteps = {};

  @override
  void initState() {
    super.initState();
    initHive();
    initPedometer();
  }

  Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox('stepsBox');

    final box = Hive.box('stepsBox');

    // load saved weekly data
    final saved = box.get('weekly', defaultValue: {}) as Map?;
    weeklySteps = Map<String, int>.from(saved ?? {});

    // ensure today exists
    final today = _todayKey();
    if (!weeklySteps.containsKey(today)) {
      weeklySteps[today] = 0;
      box.put('weekly', weeklySteps);
    }

    setState(() {});
  }

  Future<void> initPedometer() async {
    final status = await Permission.activityRecognition.request();
    if (!status.isGranted) return;

    _stepStream = Pedometer.stepCountStream.listen((StepCount event) {
      setState(() {
        todaySteps = event.steps;
      });

      _saveTodaySteps(event.steps);
    });
  }

  void _saveTodaySteps(int steps) {
    final box = Hive.box('stepsBox');
    final key = _todayKey();

    weeklySteps[key] = steps;
    box.put('weekly', weeklySteps);
  }

  String _todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  @override
  void dispose() {
    _stepStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text("Pedometer"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Steps Today",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$todaySteps",
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Keep moving — every step matters ❤️"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Weekly Trend",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: weeklySteps.entries.map((entry) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.directions_walk),
                      title: Text(entry.key),
                      trailing: Text("${entry.value} steps"),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}