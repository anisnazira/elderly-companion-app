import 'package:flutter/material.dart';

class StepsPage extends StatelessWidget {
  const StepsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.directions_walk, size: 80, color: Colors.blue),
          SizedBox(height: 20),
          Text(
            'Steps Tracker',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Today: 3,450 steps',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
