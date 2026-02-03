import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firestore_service.dart';
import 'add_medication_page.dart';
import 'medication_detail_page.dart';

class MedicationListPage extends StatefulWidget {
  const MedicationListPage({super.key});

  @override
  State<MedicationListPage> createState() => _MedicationListPageState();
}

class _MedicationListPageState extends State<MedicationListPage> {
  final FirestoreService _fs = FirestoreService();
  final String elderId = 'elder_001'; // Replace with actual auth

  // Get the next scheduled dose time
  String _getNextDoseTime(List<dynamic>? doseTimes) {
    if (doseTimes == null || doseTimes.isEmpty) return 'Anytime';
    
    final now = DateTime.now();
    DateTime? nextDose;
    
    for (final timeStr in doseTimes) {
      if (timeStr is String) {
        try {
          final doseTime = DateTime.parse(timeStr);
          if (doseTime.isAfter(now)) {
            if (nextDose == null || doseTime.isBefore(nextDose)) {
              nextDose = doseTime;
            }
          }
        } catch (e) {
          continue;
        }
      }
    }
    
    if (nextDose != null) {
      return DateFormat('h:mm a').format(nextDose);
    }
    
    // If no future dose today, check first dose tomorrow
    if (doseTimes.isNotEmpty && doseTimes[0] is String) {
      try {
        final firstDose = DateTime.parse(doseTimes[0]);
        final tomorrow = firstDose.add(const Duration(days: 1));
        return '${DateFormat('h:mm a').format(tomorrow)} (tomorrow)';
      } catch (e) {
        return 'Later';
      }
    }
    
    return 'Later';
  }

  void _navigateToAddEdit({Map<String, dynamic>? medicationData, String? docId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMedicationPage(
          medicationData: medicationData,
          docId: docId,
        ),
      ),
    );

    // Refresh list if medication was saved
    if (result == true) {
      setState(() {});
    }
  }

  void _navigateToDetail(Map<String, dynamic> data, String docId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationDetailPage(
          medicationData: data,
          docId: docId,
        ),
      ),
    );

    // Refresh if changes were made
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        centerTitle: true,
        automaticallyImplyLeading: false,
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

          // Empty state
          if (medications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No medications yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a medication to get started',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddEdit(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Medication'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          // List of medications
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final doc = medications[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'No name';
              final dose = data['dose'] ?? '';
              final timesPerDay = data['timesPerDay'] ?? 1;
              final hoursBetween = data['hoursBetween'] ?? 8;
              final firstDoseTime = (data['firstDoseTime'] as Timestamp?)?.toDate();
              final taken = data['taken'] ?? false;
              final takenAt = (data['takenAt'] as Timestamp?)?.toDate();
              final doseTimes = data['doseTimes'] as List<dynamic>?;
              final nextDose = _getNextDoseTime(doseTimes);

              return Dismissible(
                key: Key(doc.id),
                background: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    // Swipe left to delete
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Medication'),
                        content: Text('Delete "$name"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Swipe right to edit
                    _navigateToAddEdit(medicationData: data, docId: doc.id);
                    return false; // Don't dismiss
                  }
                },
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    _fs.deleteMedication(elderId, doc.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$name deleted'),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            // Re-add medication (simplified - you may want to store deleted data)
                            _fs.addMedication(elderId, data);
                          },
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: taken ? Colors.green : Colors.orange,
                      child: Icon(
                        taken ? Icons.check : Icons.medication,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dose: $dose'),
                        Text('$timesPerDay times/day, every $hoursBetween hours'),
                        if (firstDoseTime != null)
                          Text('First dose: ${DateFormat.jm().format(firstDoseTime)}'),
                        if (taken && takenAt != null)
                          Text(
                            'Taken at ${DateFormat.jm().format(takenAt)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          Text(
                            'Next dose: $nextDose',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    trailing: Icon(
                      taken ? Icons.check_circle : Icons.schedule,
                      color: taken ? Colors.green : Colors.grey,
                    ),
                    onTap: () => _navigateToDetail(data, doc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      // Floating action button as alternative to app bar button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(),
        tooltip: 'Add Medication',
        child: const Icon(Icons.add),
      ),
    );
  }
}