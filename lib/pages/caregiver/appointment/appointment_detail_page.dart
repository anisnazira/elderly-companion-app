import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firestore_service.dart';
import 'add_appointment_page.dart';

class AppointmentDetailPage extends StatelessWidget {
  final Map<String, dynamic> appointmentData;
  final String docId;

  const AppointmentDetailPage({
    super.key,
    required this.appointmentData,
    required this.docId,
  });

  Future<void> _deleteAppointment(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text('Are you sure you want to delete the appointment at "${appointmentData['clinic']}"?'),
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
      final elderId = appointmentData['elderId'] ?? 'elder_001';
      await FirestoreService().deleteAppointment(elderId, docId);
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment deleted'),
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
        builder: (context) => AddEditAppointmentPage(
          appointmentData: appointmentData,
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
    final clinic = appointmentData['clinic'] ?? 'No clinic';
    final notes = appointmentData['notes'] ?? '';
    final location = appointmentData['location'] ?? '';
    final doctor = appointmentData['doctor'] ?? '';
    final datetime = (appointmentData['datetime'] as Timestamp?)?.toDate();
    final attended = appointmentData['attended'] ?? false;
    final createdAt = (appointmentData['createdAt'] as Timestamp?)?.toDate();
    
    // Check if upcoming or past
    final isUpcoming = datetime != null && datetime.isAfter(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteAppointment(context),
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
              color: attended 
                  ? Colors.green.shade50 
                  : (isUpcoming ? Colors.blue.shade50 : Colors.grey.shade50),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      attended 
                          ? Icons.check_circle 
                          : (isUpcoming ? Icons.event : Icons.event_busy),
                      size: 48,
                      color: attended 
                          ? Colors.green 
                          : (isUpcoming ? Colors.blue : Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attended 
                                ? 'Attended' 
                                : (isUpcoming ? 'Upcoming' : 'Past'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: attended 
                                  ? Colors.green 
                                  : (isUpcoming ? Colors.blue : Colors.grey),
                            ),
                          ),
                          if (datetime != null)
                            Text(
                              DateFormat.yMMMd().add_jm().format(datetime),
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

            // Appointment Info
            _buildInfoSection(
              context,
              'Appointment Information',
              [
                _buildInfoRow(Icons.local_hospital, 'Hospital/Clinic', clinic),
                if (doctor.isNotEmpty)
                  _buildInfoRow(Icons.person, 'Doctor', doctor),
                if (location.isNotEmpty)
                  _buildInfoRow(Icons.location_on, 'Location', location),
                if (datetime != null)
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date',
                    DateFormat.yMMMd().format(datetime),
                  ),
                if (datetime != null)
                  _buildInfoRow(
                    Icons.access_time,
                    'Time',
                    DateFormat.jm().format(datetime),
                  ),
                if (notes.isNotEmpty)
                  _buildInfoRow(Icons.notes, 'Notes', notes),
              ],
            ),
            const SizedBox(height: 16),

            // Reminders Info
            if (datetime != null && isUpcoming) ...[
              Text(
                'Reminders',
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
                    children: [
                      Row(
                        children: [
                          Icon(Icons.alarm, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '1 day before appointment',
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.alarm, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '30 minutes before appointment',
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                    onPressed: () => _deleteAppointment(context),
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