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
  final _instructionCtrl = TextEditingController();
  final _prescribedByCtrl = TextEditingController();

  DateTime? _startTime;

  String _frequencyType = 'Every X hours';
  int _frequencyValue = 8;

  final FirestoreService _fs = FirestoreService();
  final NotificationService _ns = NotificationService();

  final String elderId = 'elder_001'; // replace with auth later

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _instructionCtrl.dispose();
    _prescribedByCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      setState(() {
        _startTime = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  List<DateTime> _generateTimes(DateTime start) {
    final List<DateTime> times = [];

    if (_frequencyType == 'Every X hours') {
      final count = 24 ~/ _frequencyValue;
      for (int i = 0; i < count; i++) {
        times.add(start.add(Duration(hours: i * _frequencyValue)));
      }
    } else {
      final interval = (24 / _frequencyValue).round();
      for (int i = 0; i < _frequencyValue; i++) {
        times.add(start.add(Duration(hours: i * interval)));
      }
    }

    return times;
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate() || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    final times = _generateTimes(_startTime!);

    final data = {
      'name': _nameCtrl.text.trim(),
      'dose': _doseCtrl.text.trim(),
      'instructions': _instructionCtrl.text.trim(),
      'prescribedBy': _prescribedByCtrl.text.trim(),
      'frequencyType': _frequencyType,
      'frequencyValue': _frequencyValue,
      'times': times,
      'taken': false,
      'elderId': elderId,
      'createdAt': DateTime.now(),
    };

    final docRef = await _fs.addMedication(data);

    for (int i = 0; i < times.length; i++) {
      final id = '${docRef.id}_$i'.hashCode & 0x7fffffff;
      await _ns.scheduleNotification(
        id: id,
        title: 'Medication Reminder',
        body: 'Time to take ${_nameCtrl.text}',
        scheduledDate: times[i],
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final startTimeText =
        _startTime != null ? DateFormat.jm().format(_startTime!) : 'Pick start time';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Medicine name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _doseCtrl,
                decoration: const InputDecoration(labelText: 'Dose (e.g. 1 tablet)'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter dose' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _frequencyType,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: const [
                  DropdownMenuItem(
                    value: 'Every X hours',
                    child: Text('Every X hours'),
                  ),
                  DropdownMenuItem(
                    value: 'Times per day',
                    child: Text('Times per day'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _frequencyType = value!;
                  });
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _frequencyType == 'Every X hours'
                      ? 'Every how many hours?'
                      : 'How many times per day?',
                ),
                initialValue: _frequencyValue.toString(),
                onChanged: (v) => _frequencyValue = int.tryParse(v) ?? _frequencyValue,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickStartTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(startTimeText),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _instructionCtrl,
                decoration: const InputDecoration(labelText: 'Instructions'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _prescribedByCtrl,
                decoration: const InputDecoration(labelText: 'Prescribed by'),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveMedication,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Save Medication'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
