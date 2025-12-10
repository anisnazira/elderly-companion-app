import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart'; // Import the nav bar

class ElderlyHomePage extends StatefulWidget {
  const ElderlyHomePage({super.key});

  @override
  State<ElderlyHomePage> createState() => _ElderlyHomePageState();
}

class _ElderlyHomePageState extends State<ElderlyHomePage> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    Center(child: Text('Medication Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Hospital Page', style: TextStyle(fontSize: 24))),
    HomeButtonsGrid(), // Home page with big buttons
    Center(child: Text('Steps Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elderly Home')),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Big buttons for home page
class HomeButtonsGrid extends StatelessWidget {
  const HomeButtonsGrid({super.key});

  void _onButtonPressed(String action) {
    print('$action button pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 120),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.blue,
            ),
            icon: const Icon(Icons.call, size: 50),
            label: const Text('Call', style: TextStyle(fontSize: 20)),
            onPressed: () => _onButtonPressed('Call'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 120),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.green,
            ),
            icon: const Icon(Icons.message, size: 50),
            label: const Text('WhatsApp', style: TextStyle(fontSize: 20)),
            onPressed: () => _onButtonPressed('WhatsApp'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 120),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.orange,
            ),
            icon: const Icon(Icons.camera_alt, size: 50),
            label: const Text('Camera', style: TextStyle(fontSize: 20)),
            onPressed: () => _onButtonPressed('Camera'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 120),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.purple,
            ),
            icon: const Icon(Icons.calendar_today, size: 50),
            label: const Text('Calendar', style: TextStyle(fontSize: 20)),
            onPressed: () => _onButtonPressed('Calendar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 120),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              backgroundColor: Colors.red,
            ),
            icon: const Icon(Icons.warning, size: 50),
            label: const Text('Emergency', style: TextStyle(fontSize: 20)),
            onPressed: () => _onButtonPressed('Emergency'),
          ),
        ],
      ),
    );
  }
}
