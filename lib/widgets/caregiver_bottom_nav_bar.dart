import 'package:flutter/material.dart';

<<<<<<< HEAD
class CaregiverBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CaregiverBottomNavBar({
=======
class CaregiverBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CaregiverBottomNav({
>>>>>>> 5ef03ddbde6d850746c576d3510e8d107cb6b130
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
<<<<<<< HEAD
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.medication),
=======
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black45,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
>>>>>>> 5ef03ddbde6d850746c576d3510e8d107cb6b130
          label: 'Medication',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Appointment',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
<<<<<<< HEAD
          icon: Icon(Icons.directions_walk),
          label: 'Steps',
        ),
        BottomNavigationBarItem(
=======
>>>>>>> 5ef03ddbde6d850746c576d3510e8d107cb6b130
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 5ef03ddbde6d850746c576d3510e8d107cb6b130
