import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElderlyAppointmentDetailPage extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const ElderlyAppointmentDetailPage({super.key, required this.appointmentData});

  @override
  Widget build(BuildContext context) {
    final clinic = appointmentData['clinic'] ?? 'Unknown Clinic';
    final notes = appointmentData['notes'] ?? 'No notes provided.';
    final date = (appointmentData['datetime'] as Timestamp?)?.toDate();
    final dateStr = date != null ? DateFormat.yMMMd().add_jm().format(date) : 'No Date';

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Details')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 40, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clinic, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(dateStr, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(notes, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}