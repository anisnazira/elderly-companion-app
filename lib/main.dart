import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart'; // For launching other apps

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 2; // Default to Home tab
  final List<int> _navigationHistory = []; // Track tab history

  // Pages for each tab
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Center(child: Text('Medication Page')),
      Center(child: Text('Hospital Page')),
      _homeTab(), // Home tab with quick launch button
      Center(child: Text('Steps Page')),
      Center(child: Text('Profile/Settings Page')),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _navigationHistory.add(_selectedIndex);
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_navigationHistory.isNotEmpty) {
      setState(() {
        _selectedIndex = _navigationHistory.removeLast();
      });
      return false;
    }
    return true;
  }

  static Widget _homeTab() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          const packageName = 'com.example.otherapp'; // Replace with target app package
          bool isInstalled = await DeviceApps.isAppInstalled(packageName);
          if (isInstalled) {
            DeviceApps.openApp(packageName);
          } else {
            print('App not installed');
          }
        },
        child: const Text('Quick Launch Other App'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('Buddi Home')),
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.medical_services), label: 'Medication'),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_hospital), label: 'Hospital'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.directions_walk), label: 'Steps'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
