import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'modules/pedometer/pedometer_page.dart';
import 'modules/weekly_report/heart_rate_page.dart';
import 'modules/weekly_report/weekly_report_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await Hive.initFlutter();
  await Hive.openBox('buddi_data');

  runApp(const BuddiApp());
}

class BuddiApp extends StatelessWidget {
  const BuddiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buddi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(), 
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddi Home'),
        backgroundColor: const Color(0xFF4F46E5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Buddi!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Pedometer Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PedometerPage(),
                  ),
                );
              },
              icon: const Icon(Icons.directions_walk, size: 28),
              label: const Text(
                'Pedometer',
                style: TextStyle(fontSize: 22),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),

            const SizedBox(height: 20),

            // Heart Rate Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HeartRatePage(),
                  ),
                );
              },
              icon: const Icon(Icons.favorite, size: 28),
              label: const Text(
                'Heart Rate',
                style: TextStyle(fontSize: 22),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),

            const SizedBox(height: 20),

            // Weekly Report Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WeeklyReportPage(),
                  ),
                );
              },
              icon: const Icon(Icons.assessment, size: 28),
              label: const Text(
                'Weekly Report',
                style: TextStyle(fontSize: 22),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9333EA),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}