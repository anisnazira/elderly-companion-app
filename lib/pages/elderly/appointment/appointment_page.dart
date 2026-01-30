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
    await _fs.updateAppointment(docId, {'attended': !currentStatus});
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['datetime'] as Timestamp?)?.toDate();
              final dateStr = date != null ? DateFormat.yMMMd().format(date) : 'No Date';
              final timeStr = date != null ? DateFormat.jm().format(date) : '';
              final attended = data['attended'] ?? false;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () => _navigateToDetail(data),
                  leading: Container(
                    width: 50, // Fix the width so it looks neat
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // ✅ FIX: Tells column to shrink to fit
                      children: [
                        Text(
                          date != null ? DateFormat.d().format(date) : '?',
                          style: const TextStyle(
                            fontSize: 20, // ✅ FIX: Reduced from 24 to 20 to prevent overflow
                            fontWeight: FontWeight.bold, 
                            color: Colors.blue
                          ),
                        ),
                        Text(
                          date != null ? DateFormat.MMM().format(date) : '',
                          style: const TextStyle(
                            fontSize: 12, // ✅ FIX: Slightly smaller month text
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
            },
          );
        },
      ),
    );
  }
}