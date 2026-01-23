import 'package:buddi/weeklyReport_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('stepsBox');

  runApp(const BuddiApp());
}

class BuddiApp extends StatelessWidget {
  const BuddiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buddi App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeeklyReportPage(),
    );
  }
}
