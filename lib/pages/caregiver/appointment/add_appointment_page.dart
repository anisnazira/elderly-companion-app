import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firestore_service.dart';
import '../../../services/notification_service.dart';

class AddEditAppointmentPage extends StatefulWidget {
  final Map<String, dynamic> appointmentData;
  final String docId;

  const AddEditAppointmentPage({
    super.key,
    this.appointmentData = const {},
    this.docId = '',
  });

  @override
  State<AddEditAppointmentPage> createState() => _AddEditAppointmentPageState();
}

class _AddEditAppointmentPageState extends State<AddEditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _clinicCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _selectedDateTime;

  final FirestoreService _fs = FirestoreService();
  final NotificationService _ns = NotificationService();
  final String elderId = 'elder_001';

  bool get isEditing => widget.docId != null && widget.docId.isNotEmpty;

  @override
  void initState() {
    super.initState();
    
    // ✅ Initialize with a fallback to avoid the error
    try {
      initializeDateFormatting();
    } catch (e) {
      // Ignore initialization errors
    }
    
    if (isEditing && widget.appointmentData.isNotEmpty) {
      _clinicCtrl.text = widget.appointmentData['clinic'] ?? '';
      _notesCtrl.text = widget.appointmentData['notes'] ?? '';
    
      final datetime = widget.appointmentData['datetime'];
      if (datetime is Timestamp) {
        _selectedDateTime = datetime.toDate();
      }
    }
  }

  @override
  void dispose() {
    _clinicCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: DateTime(now.year, now.month, now.day + 1), // ✅ tomorrow only
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    // ✅ Extra safety: future-date validation
    if (_selectedDateTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment must be in the future')),
      );
      return;
    }

    final data = {
      'clinic': _clinicCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'datetime': _selectedDateTime,
      'attended': widget.appointmentData?['attended'] ?? false,  // ✅ Preserve attended status
      'elderId': elderId,
      'updatedAt': DateTime.now(),  // ✅ Add updated timestamp
    };

    try {
      if (isEditing) {
        // Update existing appointment
        await _fs.updateAppointment(elderId, widget.docId!, data);
      } else {
        // Add new appointment
        data['createdAt'] = DateTime.now();  // ✅ Only add createdAt for new
        await _fs.addAppointment(elderId, data);
      }

      // Schedule reminders (same code as before)
      final id = (data['clinic'] as String).hashCode & 0x7fffffff;
      
      final oneDayBefore = _selectedDateTime!.subtract(const Duration(days: 1));
      final halfHourBefore = _selectedDateTime!.subtract(const Duration(minutes: 30));

      if (oneDayBefore.isAfter(DateTime.now())) {
        await _ns.scheduleNotification(
          id: id,
          title: 'Appointment Reminder',
          body: 'Tomorrow: ${_clinicCtrl.text}',
          scheduledDate: oneDayBefore,
        );
      }

      if (halfHourBefore.isAfter(DateTime.now())) {
        await _ns.scheduleNotification(
          id: id + 1,
          title: 'Appointment Reminder',
          body: 'In 30 minutes: ${_clinicCtrl.text}',
          scheduledDate: halfHourBefore,
        );
      }

      if (!mounted) return;
      
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDateTime != null
        ? DateFormat.yMMMd().add_jm().format(_selectedDateTime!)
        : 'Pick Date & Time';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Appointment' : 'Add Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _clinicCtrl,
                decoration: const InputDecoration(labelText: 'Hospital / Clinic'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter clinic' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dateText),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAppointment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
