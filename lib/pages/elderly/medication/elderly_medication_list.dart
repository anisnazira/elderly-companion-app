import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';

/// This page is for elderly users to view and mark medications as taken
class ElderlyMedicationListPage extends StatefulWidget {
  const ElderlyMedicationListPage({super.key});

  @override
  State<ElderlyMedicationListPage> createState() => _ElderlyMedicationListPageState();
}

class _ElderlyMedicationListPageState extends State<ElderlyMedicationListPage> {
  final FirestoreService _fs = FirestoreService();
  final String elderId = 'elder_001'; // Replace with actual auth

  Future<void> _markAsTaken(String docId, bool currentStatus) async {
    final newStatus = !currentStatus;
    
    await _fs.updateMedication(docId, {
      'taken': newStatus,
      'takenAt': newStatus ? DateTime.now() : null,
    });

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newStatus ? 'Marked as taken' : 'Marked as not taken'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fs.getMedicationsStream(elderId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final medications = snapshot.data?.docs ?? [];

          if (medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No medications scheduled',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your caregiver will add medications for you',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Separate into taken and not taken
          final notTaken = <QueryDocumentSnapshot>[];
          final taken = <QueryDocumentSnapshot>[];

          for (final doc in medications) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['taken'] == true) {
              taken.add(doc);
            } else {
              notTaken.add(doc);
            }
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Pending medications
              if (notTaken.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Pending',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...notTaken.map((doc) => _buildMedicationCard(doc, false)),
                const SizedBox(height: 16),
              ],

              // Taken medications
              if (taken.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Completed',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                ...taken.map((doc) => _buildMedicationCard(doc, true)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMedicationCard(QueryDocumentSnapshot doc, bool isTaken) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'No name';
    final dose = data['dose'] ?? '';
    final time = (data['time'] as Timestamp?)?.toDate();
    final takenAt = (data['takenAt'] as Timestamp?)?.toDate();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medication,
                  size: 40,
                  color: isTaken ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dose: $dose',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (time != null)
                        Text(
                          'Time: ${DateFormat.jm().format(time)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (isTaken && takenAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Taken at ${DateFormat.jm().format(takenAt)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Large button to mark as taken/not taken
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _markAsTaken(doc.id, isTaken),
                icon: Icon(isTaken ? Icons.undo : Icons.check),
                label: Text(
                  isTaken ? 'Mark as Not Taken' : 'Mark as Taken',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTaken ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}