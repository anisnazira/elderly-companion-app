import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import 'medication_detail_page.dart'; // We will create this read-only detail page next

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
    
    // Optimistic UI update handled by StreamBuilder, but we show a snackbar
    await _fs.updateMedication(docId, {
      'taken': newStatus,
      'takenAt': newStatus ? DateTime.now() : null,
    });

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newStatus ? 'Great job! Medication marked as taken.' : 'Marked as not taken.'),
        backgroundColor: newStatus ? Colors.green : Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElderlyMedicationDetailPage(medicationData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fs.getMedicationsStream(elderId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final medications = snapshot.data?.docs ?? [];

          if (medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No medications for today.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Separate lists
          final pending = medications.where((doc) => doc['taken'] == false).toList();
          final completed = medications.where((doc) => doc['taken'] == true).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "To Take",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
                ...pending.map((doc) => _buildMedCard(doc, isTaken: false)),
                const SizedBox(height: 24),
              ],

              if (completed.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "Completed",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
                ...completed.map((doc) => _buildMedCard(doc, isTaken: true)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildMedCard(QueryDocumentSnapshot doc, {required bool isTaken}) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Medication';
    final dose = data['dose'] ?? '';
    final timeData = data['time'] as Timestamp?; // Use the specific dose time if available
    final timeString = timeData != null ? DateFormat.jm().format(timeData.toDate()) : 'Anytime';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(data), // Tap card to see details
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isTaken ? Colors.green.shade50 : Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication,
                  color: isTaken ? Colors.green : Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$dose • $timeString',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

              // Action Checkbox/Button
              Transform.scale(
                scale: 1.3,
                child: Checkbox(
                  value: isTaken,
                  activeColor: Colors.green,
                  shape: const CircleBorder(),
                  onChanged: (val) => _markAsTaken(doc.id, isTaken),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}