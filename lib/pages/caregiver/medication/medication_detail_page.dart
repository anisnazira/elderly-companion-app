import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firestore_service.dart';
import 'add_medication_page.dart';

class MedicationDetailPage extends StatelessWidget {
  final Map<String, dynamic> medicationData;
  final String docId;

  const MedicationDetailPage({
    super.key,
    required this.medicationData,
    required this.docId,
  });

  Future<void> _deleteMedication(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete "${medicationData['name']}"?'),
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

    if (confirm == true) {
      final elderId = medicationData['elderId'] ?? 'elder_001';
      await FirestoreService().deleteMedication(elderId, docId);
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medication deleted'),
          duration: Duration(seconds: 3),
        ),
      );
      
      Navigator.pop(context, true);
    }
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMedicationPage(
          medicationData: medicationData,
          docId: docId,
        ),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = medicationData['name'] ?? 'No name';
    final dose = medicationData['dose'] ?? 'No dose';
    final instructions = medicationData['instructions'] ?? '';
    final prescribedBy = medicationData['prescribedBy'] ?? '';
    final timesPerDay = medicationData['timesPerDay'] ?? 1;
    final hoursBetween = medicationData['hoursBetween'] ?? 8;
    final firstDoseTime = (medicationData['firstDoseTime'] as Timestamp?)?.toDate();
    final taken = medicationData['taken'] ?? false;
    final takenAt = (medicationData['takenAt'] as Timestamp?)?.toDate();
    final createdAt = (medicationData['createdAt'] as Timestamp?)?.toDate();
    
    // Get dose times list
    final doseTimesList = medicationData['doseTimes'] as List<dynamic>?;
    List<DateTime> doseTimes = [];
    if (doseTimesList != null) {
      doseTimes = doseTimesList
          .map((t) => DateTime.parse(t.toString()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMedication(context),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: taken ? Colors.green.shade50 : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      taken ? Icons.check_circle : Icons.schedule,
                      size: 48,
                      color: taken ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            taken ? 'Taken' : 'Pending',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: taken ? Colors.green : Colors.orange,
                            ),
                          ),
                          if (taken && takenAt != null)
                            Text(
                              'at ${DateFormat.jm().format(takenAt)}',
                              style: TextStyle(
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Medication Info
            _buildInfoSection(
              context,
              'Medication Information',
              [
                _buildInfoRow(Icons.medication, 'Name', name),
                _buildInfoRow(Icons.local_pharmacy, 'Dose', dose),
                if (prescribedBy.isNotEmpty)
                  _buildInfoRow(Icons.person, 'Prescribed By', prescribedBy),
                if (instructions.isNotEmpty)
                  _buildInfoRow(Icons.notes, 'Instructions', instructions),
              ],
            ),
            const SizedBox(height: 16),

            // Schedule Info
            _buildInfoSection(
              context,
              'Schedule',
              [
                _buildInfoRow(Icons.repeat, 'Frequency', '$timesPerDay times per day'),
                _buildInfoRow(Icons.schedule, 'Interval', 'Every $hoursBetween hours'),
                if (firstDoseTime != null)
                  _buildInfoRow(
                    Icons.access_time,
                    'First Dose',
                    DateFormat.jm().format(firstDoseTime),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Dose Times
            if (doseTimes.isNotEmpty) ...[
              Text(
                'Daily Schedule',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: doseTimes.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat.jm().format(entry.value),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Additional Info
            if (createdAt != null)
              _buildInfoSection(
                context,
                'Additional Information',
                [
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Added on',
                    DateFormat.yMMMd().format(createdAt),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToEdit(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteMedication(context),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}