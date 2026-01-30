import 'package:flutter/material.dart';

class ElderlyMedicationDetailPage extends StatelessWidget {
  final Map<String, dynamic> medicationData;

  const ElderlyMedicationDetailPage({super.key, required this.medicationData});

  @override
  Widget build(BuildContext context) {
    final name = medicationData['name'] ?? 'Unknown';
    final instructions = medicationData['instructions'] ?? 'No special instructions.';
    final prescribedBy = medicationData['prescribedBy'] ?? 'Not listed';

    return Scaffold(
      appBar: AppBar(title: const Text('Medication Details')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Icon Header
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medication, size: 60, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            // Instructions
            _buildInfoTile(Icons.info_outline, "Instructions", instructions),
            const SizedBox(height: 16),
            _buildInfoTile(Icons.person_outline, "Prescribed By", prescribedBy),
            const SizedBox(height: 16),
            _buildInfoTile(Icons.local_pharmacy_outlined, "Dose", medicationData['dose'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
      ),
    );
  }
}