import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final FirestoreService _fs = FirestoreService();
  final String elderId = 'elder_001'; // replace with auth later

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _fs.getAppointmentsStream(elderId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading appointments'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No appointments found.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: docs.map((doc) => appointmentCard(doc)).toList(),
          );
        },
      ),
    );
  }

  Widget appointmentCard(QueryDocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final clinic = data['clinic'] ?? 'Clinic';
    final notes = data['notes'] ?? '';
    final attended = data['attended'] ?? false;
    final id = doc.id;

    final timestamp = data['datetime'] != null
        ? (data['datetime'] as Timestamp).toDate()
        : null;

    final timeString = timestamp != null
        ? DateFormat.yMMMd().add_jm().format(timestamp)
        : 'No date';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(clinic, style: const TextStyle(fontSize: 20)),
        subtitle: Text('$timeString\n$notes'),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () async {
            await _fs.updateAppointment(id, {'attended': !attended});
          },
          child: Text(attended ? 'Attended' : 'Mark Attended'),
        ),
      ),
    );
  }
}
