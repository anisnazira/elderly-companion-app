import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/sign_in.dart';
import '../../caregiver/caregiver_home.dart';

const Color brightPurpleColor = Color(0xFF7F00FF);
const Color lightGreenColor = Color(0xFFD9FD6D);

class ProfilePage extends StatefulWidget {
  final String? initialRole;

  const ProfilePage({super.key, this.initialRole});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  late String role;

  // User info
  String name = '';
  String email = '';
  String phone = '';
  String age = '';

  // Controllers for editing (email will be read-only)
  TextEditingController phoneController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    role = widget.initialRole ?? "Elderly";

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _populateUserData(user);
    } else {
      // Listen for auth changes
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) _populateUserData(user);
      });
    }
  }

  void _populateUserData(User user) {
    setState(() {
      name = user.displayName ?? "Unknown Name";
      email = user.email ?? "No Email";
      phone = '+1234567890';
      age = '63';

      phoneController.text = phone;
      ageController.text = age;
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() {
      phone = phoneController.text;
      age = ageController.text;
      isEditing = false;
    });

    // TODO: Update Firestore if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top right settings
            Padding(
              padding: const EdgeInsets.only(top: 50.0, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton(
                    icon: const Icon(Icons.settings),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => SignInPage()),
                          (route) => false,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'logout',
                        child: Text('Log Out'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // Avatar
            const CircleAvatar(
              backgroundImage: AssetImage('assets/elderlyimage.png'),
              radius: 50,
            ),
            const SizedBox(height: 10),

            // Name & XP
            Text(
              name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text('Razak Misbun'),
            const SizedBox(height: 20),

            // Role selector
            Container(
              width: 300,
              height: 60,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10.0,
                      offset: Offset(4.0, 4.0),
                      spreadRadius: 1.0)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (role != 'Elderly') setState(() => role = 'Elderly');
                    },
                    child: Text(
                      'Elderly',
                      style: TextStyle(
                        color: role == 'Elderly'
                            ? Colors.indigo[900]
                            : Colors.grey[600],
                        fontWeight: role == 'Elderly'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (role != 'Caregiver') {
                        setState(() => role = 'Caregiver');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CaregiverHomePage()),
                          (route) => false,
                        );
                      }
                    },
                    child: Text(
                      'Caregiver',
                      style: TextStyle(
                        color: role == 'Caregiver'
                            ? Colors.indigo[900]
                            : Colors.grey[600],
                        fontWeight: role == 'Caregiver'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User info box (Age -> Phone -> Email)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 10.0,
                        offset: Offset(4.0, 4.0),
                        spreadRadius: 1.0)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Age
                    isEditing
                        ? _buildTextField("Age", ageController)
                        : _buildDisplayTile(Icons.cake, "Age", age),
                    const SizedBox(height: 10),
                    // Phone
                    isEditing
                        ? _buildTextField("Phone", phoneController)
                        : _buildDisplayTile(Icons.phone, "Phone", phone),
                    const SizedBox(height: 10),
                    // Email (read-only)
                    _buildDisplayTile(Icons.email, "Email", email),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Edit / Save button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isEditing ? brightPurpleColor : brightPurpleColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                if (isEditing) {
                  _saveProfile();
                } else {
                  setState(() => isEditing = true);
                }
              },
              child: Text(
                isEditing ? "Save" : "Edit Profile",
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value.isNotEmpty ? value : "Loading..."),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
