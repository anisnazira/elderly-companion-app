import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import 'medication_detail_page.dart';

class ElderlyMedicationListPage extends StatefulWidget {
  const ElderlyMedicationListPage({super.key});

  @override
  State<ElderlyMedicationListPage> createState() => _ElderlyMedicationListPageState();
}

class _ElderlyMedicationListPageState extends State<ElderlyMedicationListPage> {
  final FirestoreService _fs = FirestoreService();
  
  // Constants
  static const int doseWindowMinutes = 30;
  static const int defaultHoursBetween = 8;

  // Hardcoded elderly ID - matches what's used in caregiver views
  // TODO: Replace with actual auth when proper user linking is implemented
  final String elderId = 'elder_001';

  // Check if current time is within 30 minutes of a scheduled dose time
  bool _isWithinDoseWindow(List<dynamic>? doseTimes) {
    if (doseTimes == null || doseTimes.isEmpty) return true; // Allow anytime if no schedule
    
    final now = DateTime.now();
    
    for (final time in doseTimes) {
      try {
        final doseTime = time is Timestamp ? time.toDate() : DateTime.parse(time.toString());
        final difference = now.difference(doseTime).inMinutes.abs();
        if (difference <= doseWindowMinutes) {
          return true; // Within the window
        }
      } catch (e) {
        continue;
      }
    }
    
    return false; // Not within any window
  }

  // Get the next scheduled dose time
  String _getNextDoseTime(List<dynamic>? doseTimes) {
    if (doseTimes == null || doseTimes.isEmpty) return 'Anytime';
    
    final now = DateTime.now();
    DateTime? nextDose;
    
    for (final time in doseTimes) {
      try {
        final doseTime = time is Timestamp ? time.toDate() : DateTime.parse(time.toString());
        if (doseTime.isAfter(now)) {
          if (nextDose == null || doseTime.isBefore(nextDose)) {
            nextDose = doseTime;
          }
        }
      } catch (e) {
        continue;
      }
    }
    
    if (nextDose != null) {
      return DateFormat('h:mm a').format(nextDose);
    }
    
    // If no future dose today, check first dose tomorrow
    if (doseTimes.isNotEmpty) {
      try {
        final firstDose = doseTimes[0] is Timestamp 
            ? (doseTimes[0] as Timestamp).toDate() 
            : DateTime.parse(doseTimes[0].toString());
        final tomorrow = firstDose.add(const Duration(days: 1));
        return '${DateFormat('h:mm a').format(tomorrow)} (tomorrow)';
      } catch (e) {
        return 'Later';
      }
    }
    
    return 'Later';
  }

  Future<void> _markAsTaken(String docId, bool currentStatus, bool isWithinWindow) async {
    final newStatus = !currentStatus;
    
    // Optimistic UI update handled by StreamBuilder, but we show a snackbar
    await _fs.updateMedication(elderId, docId, {
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

  String _formatTakenTime(dynamic takenAt) {
    try {
      if (takenAt is Timestamp) {
        return DateFormat('h:mm a').format(takenAt.toDate());
      } else if (takenAt != null) {
        return DateFormat('h:mm a').format(DateTime.parse(takenAt.toString()));
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return DateFormat('h:mm a').format(DateTime.now());
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
                    Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No medications yet.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: docs.map((doc) {
              final isTaken = doc.get('taken') ?? false;
              final doseTimes = doc.get('doseTimes') as List<dynamic>?;
              final isWithinWindow = _isWithinDoseWindow(doseTimes);
              return _buildMedCard(doc, isTaken: isTaken, isWithinWindow: isWithinWindow, doseTimes: doseTimes);
            }).toList(),
          );
        },
      )
    );
  }

  Widget _buildMedCard(QueryDocumentSnapshot doc, {required bool isTaken, required bool isWithinWindow, required List<dynamic>? doseTimes}) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Medication';
    final dose = data['dose'] ?? '';
    final timeData = data['firstDoseTime'] as Timestamp?;
    final firstDoseString = timeData != null ? DateFormat('h:mm a').format(timeData.toDate()) : 'Anytime';
    final timesPerDay = data['timesPerDay'] ?? 1;
    final hoursBetween = data['hoursBetween'] ?? defaultHoursBetween;
    
    final scheduleString = timesPerDay == 1 
        ? '$firstDoseString daily'
        : '$timesPerDay times/day, every $hoursBetween hours';
    
    final nextDose = _getNextDoseTime(doseTimes);

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
                  color: isTaken ? Colors.green.shade50 : (isWithinWindow ? Colors.blue.shade50 : Colors.grey.shade50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication,
                  color: isTaken ? Colors.green : (isWithinWindow ? Colors.blue : Colors.grey),
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
                      '$dose • $scheduleString',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    if (isTaken)
                      Text(
                        'Taken at ${_formatTakenTime(data['takenAt'])}',
                        style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                      )
                    else if (isWithinWindow)
                      Text(
                        'Ready to take now',
                        style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w500),
                      )
                    else
                      Text(
                        'Next dose: $nextDose',
                        style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
              ),

              // Action Checkbox/Button
              Transform.scale(
                scale: 1.3,
                child: isWithinWindow || isTaken
                    ? Checkbox(
                        value: isTaken,
                        activeColor: Colors.green,
                        shape: const CircleBorder(),
                        onChanged: (val) => _markAsTaken(doc.id, isTaken, isWithinWindow),
                      )
                    : Tooltip(
                        message: 'Not time yet. Next dose: $nextDose',
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Not time yet. Next dose: $nextDose'),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Opacity(
                            opacity: 0.5,
                            child: Checkbox(
                              value: false,
                              activeColor: Colors.green,
                              shape: const CircleBorder(),
                              onChanged: null,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}