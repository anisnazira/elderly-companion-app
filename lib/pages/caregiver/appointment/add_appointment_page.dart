import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/firestore_service.dart';
import '../../../services/notification_service.dart';

class AddAppointmentPage extends StatefulWidget {
  const AddAppointmentPage({super.key});

  @override
  State<AddAppointmentPage> createState() => _AddAppointmentPageState();
}

class _AddAppointmentPageState extends State<AddAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _clinicCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _selectedDateTime;
  final FirestoreService _fs = FirestoreService();
  final NotificationService _ns = NotificationService();

  final String elderId = 'elder_001';

  @override
  void dispose() {
    _clinicCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete fields')));
      return;
    }

    final data = {
      'clinic': _clinicCtrl.text.trim(),
      'notes': _notesCtrl.text.trim(),
      'datetime': _selectedDateTime,
      'attended': false,
      'elderId': elderId,
      'createdAt': DateTime.now(),
    };

    final docRef = await _fs.addAppointment(data);
    final id = docRef.id.hashCode & 0x7fffffff;

    // schedule reminder 1 day before and 30 minutes before (if in future)
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDateTime != null ? DateFormat.yMMMd().add_jm().format(_selectedDateTime!) : 'Pick Date & Time';
    return Scaffold(
      appBar: AppBar(title: const Text('Add Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _clinicCtrl,
                decoration: const InputDecoration(labelText: 'Hospital/Clinic'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter clinic' : null,
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
              ElevatedButton(
                onPressed: _saveAppointment,
                child: const Text('Save Appointment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
