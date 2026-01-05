import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pedometer_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive (still OK to keep for your project)
  await Hive.initFlutter();
  await Hive.openBox('buddi_data');

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

      // 👇 App opens directly to the pedometer page
      home: const HomePage(),
    );
  }
}
