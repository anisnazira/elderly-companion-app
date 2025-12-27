import 'package:flutter/material.dart';
import '../../../auth/sign_in.dart';
import '../../elderly/elderly_home.dart';

class ProfileCaregiverPage extends StatefulWidget {
  const ProfileCaregiverPage({super.key});

  @override
  State<ProfileCaregiverPage> createState() => _ProfileCaregiverPageState();
}

class _ProfileCaregiverPageState extends State<ProfileCaregiverPage> {
  String userName = "Jane Doe";
  int age = 35;
  String role = "Caregiver";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.06),

          /// TITLE
          Text(
            "Caregiver Profile",
            style: TextStyle(
              fontSize: size.width * 0.07,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: size.height * 0.03),

          /// INFO
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
                    value: "Caregiver",
                    child: Text("Caregiver"),
                  ),
                  DropdownMenuItem(
                    value: "Elderly",
                    child: Text("Elderly"),
                  ),
                ],
                onChanged: (value) {
                  if (value == null || value == role) return;

                  setState(() => role = value);

                  /// 🔁 SWITCH BACK TO ELDERLY FLOW
                  if (value == "Elderly") {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ElderlyHomePage(
                          selectedRole: "Elderly",
                        ),
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
