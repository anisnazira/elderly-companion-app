import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import '../../../services/notification_service.dart';
import '../../caregiver/medication/add_medication_page.dart';
import 'package:intl/intl.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final FirestoreService _fs = FirestoreService();
  final String elderId = 'elder_001'; // change when using auth

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _fs.getMedicationsStream(elderId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading medications'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No medications found.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddMedicationPage()),
                    ),
                    child: const Text('Add Medication'),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (var doc in docs) medicationCard(doc),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMedicationPage()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Medication'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget medicationCard(QueryDocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';
    final dose = data['dose'] ?? '';
    final timestamp = data['time'] != null ? (data['time'] as Timestamp).toDate() : null;
    final isTaken = data['taken'] ?? false;
    final id = doc.id;

    final timeString = timestamp != null ? DateFormat.jm().format(timestamp) : 'No time';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontSize: 20)),
        subtitle: Text('Dose: $dose\nTime: $timeString'),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () async {
            // Toggle taken status (elderly confirm)
            await _fs.updateMedication(id, {'taken': !isTaken});
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            textStyle: const TextStyle(fontSize: 16),
          ),
          child: Text(isTaken ? 'Taken' : 'Mark Taken'),
        ),
      ),
    );
  }
}
