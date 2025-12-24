import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import 'package:intl/intl.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final FirestoreService _fs = FirestoreService();
  final String elderId = 'elder_001'; // replace with auth later

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
            return const Center(
              child: Text('No medications found.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: docs.map((doc) => medicationCard(doc)).toList(),
          );
        },
      ),
    );
  }

  Widget medicationCard(QueryDocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';
    final dose = data['dose'] ?? '';
    final isTaken = data['taken'] ?? false;
    final id = doc.id;

    final timestamp = data['time'] != null
        ? (data['time'] as Timestamp).toDate()
        : null;

    final timeString =
        timestamp != null ? DateFormat.jm().format(timestamp) : 'No time';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontSize: 20)),
        subtitle: Text('Dose: $dose\nTime: $timeString'),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () async {
            await _fs.updateMedication(id, {'taken': !isTaken});
          },
          child: Text(isTaken ? 'Taken' : 'Mark Taken'),
        ),
      ),
    );
  }
}
