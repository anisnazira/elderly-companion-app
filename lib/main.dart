import 'package:flutter/material.dart';
import 'pages/elderly/elderly_home.dart';

void main() {
  runApp(const BuddiApp());
}

class BuddiApp extends StatelessWidget {
  const BuddiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buddi App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const ElderlyHomePage(),
    );
  }
}
