import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firestore_service.dart';
import 'add_appointment_page.dart';
import 'appointment_detail_page.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  final FirestoreService _fs = FirestoreService();
  final String elderId = 'elder_001';

  // ✅ Custom date/time formatters
  String _formatDate(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    return '$month $day, $year';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _navigateToAddEdit({Map<String, dynamic>? appointmentData, String? docId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAppointmentPage(
          appointmentData: appointmentData ?? {},
          docId: docId ?? '',
        ),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _navigateToDetail(Map<String, dynamic> data, String docId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailPage(
          appointmentData: data,
          docId: docId,
        ),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fs.getAppointmentsStream(elderId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final appointments = snapshot.data?.docs ?? [];
          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No appointments yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add an appointment to get started',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddEdit(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Appointment'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          // Separate appointments into upcoming and past
          final now = DateTime.now();
          final upcomingAppointments = [];
          final pastAppointments = [];

          for (final doc in appointments) {
            final data = doc.data() as Map<String, dynamic>;
            final datetime = (data['datetime'] as Timestamp?)?.toDate();
            final attended = data['attended'] ?? false;

            if (datetime != null) {
              if (datetime.isAfter(now) && !attended) {
                upcomingAppointments.add((doc, data));
              } else {
                pastAppointments.add((doc, data));
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Upcoming Section
              if (upcomingAppointments.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Upcoming',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...upcomingAppointments.map((item) => _buildAppointmentCard(item.$2, item.$1)).toList(),
              ],

              // Past Section
              if (pastAppointments.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Past',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...pastAppointments.map((item) => _buildAppointmentCard(item.$2, item.$1)).toList(),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addAppointmentFAB',
        onPressed: () => _navigateToAddEdit(),
        tooltip: 'Add Appointment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> data, QueryDocumentSnapshot doc) {
    final clinic = data['clinic'] ?? 'No clinic';
    final notes = data['notes'] ?? '';
    final datetime = (data['datetime'] as Timestamp?)?.toDate();
    final attended = data['attended'] ?? false;
    final isUpcoming = datetime != null && datetime.isAfter(DateTime.now());

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
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Appointment'),
              content: Text('Delete appointment at "$clinic"?'),
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
          _navigateToAddEdit(appointmentData: data, docId: doc.id);
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _fs.deleteAppointment(elderId, doc.id);
          if (!mounted) return;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Appointment at ${clinic.isNotEmpty ? clinic : "clinic"} deleted'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  _fs.addAppointment(elderId, data);
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
            backgroundColor: attended 
                ? Colors.green 
                : (isUpcoming ? Colors.blue : Colors.grey),
            child: Icon(
              attended 
                  ? Icons.check 
                  : (isUpcoming ? Icons.event : Icons.event_busy),
              color: Colors.white,
            ),
          ),
          title: Text(
            clinic,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (datetime != null) ...[
                Text('${_formatDate(datetime)} at ${_formatTime(datetime)}'),
                if (isUpcoming && !attended)
                  Text(
                    'Upcoming',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (!isUpcoming && !attended)
                  Text(
                    'Past',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
              if (attended)
                const Text(
                  'Attended',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (notes.isNotEmpty)
                Text(
                  notes,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
            ],
          ),
          trailing: Icon(
            attended 
                ? Icons.check_circle 
                : (isUpcoming ? Icons.schedule : Icons.history),
            color: attended 
                ? Colors.green 
                : (isUpcoming ? Colors.blue : Colors.grey),
          ),
          onTap: () => _navigateToDetail(data, doc.id),
        ),
      ),
    );
  }
}