import 'package:flutter/material.dart';

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buddi Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Buddi!'),
            ElevatedButton(
              onPressed: () {
                // Navigate to another page
              },
              child: const Text('Go to Next Page'),
            ),
          ],
        ),
      ),
    );
  }
}
