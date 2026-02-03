import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import 'appointment_detail_page.dart'; // We create this next

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final FirestoreService _fs = FirestoreService();
  final String elderId = 'elder_001'; 

  Future<void> _markAttended(String docId, bool currentStatus) async {
    await _fs.updateAppointment(elderId, docId, {'attended': !currentStatus});
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Attendance status updated")),
    );
  }

  void _navigateToDetail(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElderlyAppointmentDetailPage(appointmentData: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fs.getAppointmentsStream(elderId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming appointments.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Separate appointments into upcoming and past
          final now = DateTime.now();
          final upcomingAppointments = [];
          final pastAppointments = [];

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['datetime'] as Timestamp?)?.toDate();
            final attended = data['attended'] ?? false;

            if (date != null) {
              if (date.isAfter(now) && !attended) {
                upcomingAppointments.add((doc, data));
              } else {
                pastAppointments.add((doc, data));
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Upcoming Section
              if (upcomingAppointments.isNotEmpty) ...[
                Text(
                  'Upcoming',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...upcomingAppointments.map((item) => _buildAppointmentCard(item.$2, item.$1)).toList(),
              ],

              // Past Section
              if (pastAppointments.isNotEmpty) ...[
                if (upcomingAppointments.isNotEmpty) const SizedBox(height: 24),
                Text(
                  'Past',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...pastAppointments.map((item) => _buildAppointmentCard(item.$2, item.$1)).toList(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> data, QueryDocumentSnapshot doc) {
    final date = (data['datetime'] as Timestamp?)?.toDate();
    final timeStr = date != null ? DateFormat.jm().format(date) : '';
    final attended = data['attended'] ?? false;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () => _navigateToDetail(data),
        leading: Container(
          width: 50,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                date != null ? DateFormat.d().format(date) : '?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold, 
                  color: Colors.blue
                ),
              ),
              Text(
                date != null ? DateFormat.MMM().format(date) : '',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
        title: Text(
          data['clinic'] ?? 'Clinic',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          '$timeStr\n${data['doctor'] ?? ''}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: ElevatedButton(
          onPressed: () => _markAttended(doc.id, attended),
          style: ElevatedButton.styleFrom(
            backgroundColor: attended ? Colors.green : Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text(attended ? 'Done' : 'Confirm'),
        ),
      ),
    );
  }
}