import 'package:flutter/material.dart';
import '../../../auth/sign_in.dart';
import '../../caregiver/caregiver_home.dart';


class ProfilePage extends StatefulWidget {
  final String initialRole;

  const ProfilePage({
    super.key,
    required this.initialRole,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "John Doe";
  int age = 70;
  late String role;

  @override
  void initState() {
    super.initState();
    role = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.06),

          Text(
            "Profile",
            style: TextStyle(
              fontSize: size.width * 0.07,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: size.height * 0.03),

          Text(
            "Name: $userName",
            style: TextStyle(fontSize: size.width * 0.045),
          ),
          SizedBox(height: size.height * 0.015),
          Text(
            "Age: $age",
            style: TextStyle(fontSize: size.width * 0.045),
          ),

          SizedBox(height: size.height * 0.03),

          /// ROLE SWITCH
          Row(
            children: [
              Text(
                "Role: ",
                style: TextStyle(fontSize: size.width * 0.045),
              ),
              DropdownButton<String>(
                value: role,
                items: const [
                  DropdownMenuItem(
                    value: "Elderly",
                    child: Text("Elderly"),
                  ),
                  DropdownMenuItem(
                    value: "Caregiver",
                    child: Text("Caregiver"),
                  ),
                ],
                onChanged: (value) {
                  if (value == null || value == role) return;

                  setState(() => role = value);

                 //switch roles
                  if (value == "Caregiver") {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CaregiverHomePage(),
                      ),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),

          const Spacer(),

          /// LOG OUT
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2735D),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.2,
                  vertical: size.height * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SignInPage()),
                  (route) => false,
                );
              },
              child: Text(
                "Log Out",
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
