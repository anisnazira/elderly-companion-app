import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/notification_service.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  DateTime? _selectedTime;
  final FirestoreService _fs = FirestoreService();
  final NotificationService _ns = NotificationService();
  final String elderId = 'elder_001'; // change when using auth

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      final nowDate = DateTime.now();
      setState(() {
        _selectedTime = DateTime(nowDate.year, nowDate.month, nowDate.day, picked.hour, picked.minute);
      });
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate() || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and time')));
      return;
    }

    final data = {
      'name': _nameCtrl.text.trim(),
      'dose': _doseCtrl.text.trim(),
      'time': _selectedTime,
      'taken': false,
      'elderId': elderId,
      'createdAt': DateTime.now(),
    };

    final docRef = await _fs.addMedication(data);
    // schedule notification (id: use document's hashCode or timestamp-based int)
    final id = docRef.id.hashCode & 0x7fffffff;
    await _ns.scheduleNotification(
      id: id,
      title: 'Medication Reminder',
      body: 'Time to take ${_nameCtrl.text}',
      scheduledDate: _selectedTime!,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _selectedTime != null ? DateFormat.jm().format(_selectedTime!) : 'Pick Time';
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Medicine name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doseCtrl,
                decoration: const InputDecoration(labelText: 'Dose (e.g., 1 tablet)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter dose' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(timeText),
                  ),
                  const SizedBox(width: 12),
                  if (_selectedTime != null)
                    Text(DateFormat.yMMMd().format(_selectedTime!)),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _saveMedication,
                child: const Text('Save Medication'),
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
