import 'package:flutter/material.dart';
import '../auth/sign_in.dart';
import '../pages/elderly/elderly_home.dart';
import '../pages/caregiver/caregiver_home.dart';

enum UserRole { elderly, caregiver }

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with TickerProviderStateMixin {
  UserRole selectedRole = UserRole.elderly;

  late AnimationController _elderlyController;
  late AnimationController _caregiverController;

  late Animation<double> _elderlyScale;
  late Animation<double> _caregiverScale;

  final Duration _animationDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();

    // Animation controllers
    _elderlyController = AnimationController(
      vsync: this,
      duration: _animationDuration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _caregiverController = AnimationController(
      vsync: this,
      duration: _animationDuration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    // Tween scale animations (1.0 → 1.2 for visible effect)
    _elderlyScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _elderlyController, curve: Curves.easeOut),
    );
    _caregiverScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _caregiverController, curve: Curves.easeOut),
    );

    // Start with controllers at 0
    _elderlyController.value = 0.0;
    _caregiverController.value = 0.0;
  }

  @override
  void dispose() {
    _elderlyController.dispose();
    _caregiverController.dispose();
    super.dispose();
  }

  // Animate selected role and navigate
  Future<void> selectRole(UserRole role) async {
    setState(() {
      selectedRole = role;
    });

    if (role == UserRole.elderly) {
      await _elderlyController.forward();
      await _elderlyController.reverse();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ElderlyHomePage(selectedRole: "Elderly"),
        ),
      );
    } else {
      await _caregiverController.forward();
      await _caregiverController.reverse();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CaregiverHomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.08,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.grey[800],
                iconSize: size.width * 0.08,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Who Are You?',
              style: TextStyle(
                fontSize: size.width * 0.065,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose how you want to use the app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 320,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: ScaleTransition(
                      scale: _elderlyScale,
                      child: RoleCard(
                        text: 'Elderly',
                        imagePath: 'assets/elderly.png',
                        isSelected: selectedRole == UserRole.elderly,
                        onTap: () => selectRole(UserRole.elderly),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ScaleTransition(
                      scale: _caregiverScale,
                      child: RoleCard(
                        text: 'Caregiver',
                        imagePath: 'assets/caregiver.png',
                        isSelected: selectedRole == UserRole.caregiver,
                        onTap: () => selectRole(UserRole.caregiver),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String text;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.text,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 260,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const Spacer(),
            Image.asset(
              imagePath,
              height: 120,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
