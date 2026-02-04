import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class WeeklyShowPage extends StatelessWidget {
  const WeeklyShowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'elder_001';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        title: const Text("Weekly Report"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('weekly_reports')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No weekly report available"),
            );
          }

          final data = snapshot.data!.docs.first;
          final createdAt = (data['createdAt'] as Timestamp).toDate();

          final formattedDate = DateFormat(
            "d MMMM yyyy 'at' HH:mm:ss"
          ).format(createdAt);

          Widget buildRow(String label, String value) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildRow("Family Email", data['familyEmail'] ?? 'N/A'),
                  buildRow("Steps", data['steps'].toString()),
                  buildRow("Meds Taken", data['medsTaken'].toString()),
                  buildRow("Missed Meds", data['medsMissed'].toString()),
                  buildRow("Appointments", data['appointments'].toString()),
                  buildRow("Emergencies", data['emergencies'].toString()),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    "Created at:\n$formattedDate UTC+8",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}