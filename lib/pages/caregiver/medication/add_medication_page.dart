import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/notification_service.dart';

class AddEditMedicationPage extends StatefulWidget {
  final Map<String, dynamic>? medicationData;
  final String? docId;

  const AddEditMedicationPage({
    super.key,
    this.medicationData,
    this.docId,
  });

  @override
  State<AddEditMedicationPage> createState() => _AddEditMedicationPageState();
}

class _AddEditMedicationPageState extends State<AddEditMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _prescribedByCtrl = TextEditingController();
  
  // Frequency settings
  int _timesPerDay = 1;
  int _hoursBetween = 8;
  DateTime? _firstDoseTime;
  
  final FirestoreService _fs = FirestoreService();
  final NotificationService _ns = NotificationService();
  final String elderId = 'elder_001';

  bool get isEditing => widget.docId != null;

  @override
  void initState() {
    super.initState();

    initializeDateFormatting();

    if (isEditing && widget.medicationData != null) {
      _nameCtrl.text = widget.medicationData!['name'] ?? '';
      _doseCtrl.text = widget.medicationData!['dose'] ?? '';
      _instructionsCtrl.text = widget.medicationData!['instructions'] ?? '';
      _prescribedByCtrl.text = widget.medicationData!['prescribedBy'] ?? '';
      _timesPerDay = widget.medicationData!['timesPerDay'] ?? 1;
      _hoursBetween = widget.medicationData!['hoursBetween'] ?? 8;
      
      final time = widget.medicationData!['firstDoseTime'];
      if (time is Timestamp) {
        _firstDoseTime = time.toDate();
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _instructionsCtrl.dispose();
    _prescribedByCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFirstDoseTime() async {
    final now = _firstDoseTime != null
        ? TimeOfDay.fromDateTime(_firstDoseTime!)
        : TimeOfDay.now();
    
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      helpText: 'Select first dose time',
    );
    
    if (picked != null) {
      final nowDate = DateTime.now();
      setState(() {
        _firstDoseTime = DateTime(
          nowDate.year,
          nowDate.month,
          nowDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  List<DateTime> _calculateDoseTimes() {
    if (_firstDoseTime == null) return [];
    
    List<DateTime> times = [];
    DateTime currentTime = _firstDoseTime!;
    
    for (int i = 0; i < _timesPerDay; i++) {
      times.add(currentTime);
      currentTime = currentTime.add(Duration(hours: _hoursBetween));
    }
    
    return times;
  }

  Future<void> _saveMedication() async {
  if (!_formKey.currentState!.validate() || _firstDoseTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all required fields and select first dose time')),
    );
    return;
  }

  final doseTimes = _calculateDoseTimes();
  
  final data = {
    'name': _nameCtrl.text.trim(),
    'dose': _doseCtrl.text.trim(),
    'instructions': _instructionsCtrl.text.trim(),
    'prescribedBy': _prescribedByCtrl.text.trim(),
    'timesPerDay': _timesPerDay,
    'hoursBetween': _hoursBetween,
    'firstDoseTime': _firstDoseTime,
    'doseTimes': doseTimes.map((t) => t.toIso8601String()).toList(),
    'taken': widget.medicationData?['taken'] ?? false,
    'takenAt': widget.medicationData?['takenAt'],
    'elderId': elderId,
    'updatedAt': DateTime.now(),
  };

  try {
    String documentId;
    
    if (isEditing) {
      // Update existing medication
      await _fs.updateMedication(elderId, widget.docId!, data);
      documentId = widget.docId!;
      
      // Cancel old notifications
      for (int i = 0; i < 10; i++) {
        final oldId = (documentId.hashCode + i) & 0x7fffffff;
        await _ns.cancelNotification(oldId);
      }
    } else {
      // Add new medication
      data['createdAt'] = DateTime.now();
      
      // Get document reference and extract ID
      await _fs.addMedication(elderId, data);
      documentId = (data['name'] as String).hashCode.toString();
    }

    // Schedule notifications for each dose time
    final baseId = documentId.hashCode & 0x7fffffff;
    for (int i = 0; i < doseTimes.length; i++) {
      await _ns.scheduleNotification(
        id: baseId + i,
        title: 'Medication Reminder',
        body: 'Time to take ${_nameCtrl.text} - ${_doseCtrl.text}',
        scheduledDate: doseTimes[i],
      );
    }

    if (!mounted) return;
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Medication updated successfully' : 'Medication saved successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Go back to list page
    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final doseTimes = _calculateDoseTimes();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medication' : 'Add Medication'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Medicine Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Medicine Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter medicine name' : null,
            ),
            const SizedBox(height: 16),
            
            // Dose
            TextFormField(
              controller: _doseCtrl,
              decoration: const InputDecoration(
                labelText: 'Dose *',
                hintText: 'e.g., 1 tablet, 5ml',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_pharmacy),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter dose' : null,
            ),
            const SizedBox(height: 16),

            // Prescribed By
            TextFormField(
              controller: _prescribedByCtrl,
              decoration: const InputDecoration(
                labelText: 'Prescribed By',
                hintText: 'e.g., Dr. Smith',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            TextFormField(
              controller: _instructionsCtrl,
              decoration: const InputDecoration(
                labelText: 'Instructions/Details',
                hintText: 'e.g., Take with food, avoid alcohol',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Frequency Section Header
            Text(
              'Medication Schedule',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Times Per Day
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.repeat),
                        const SizedBox(width: 12),
                        Text(
                          'Times per day: $_timesPerDay',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Slider(
                      value: _timesPerDay.toDouble(),
                      min: 1,
                      max: 6,
                      divisions: 5,
                      label: '$_timesPerDay times',
                      onChanged: (value) {
                        setState(() {
                          _timesPerDay = value.toInt();
                          // Auto-calculate hours between
                          _hoursBetween = (24 / _timesPerDay).round();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Hours Between Doses
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule),
                        const SizedBox(width: 12),
                        Text(
                          'Hours between doses: $_hoursBetween',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Slider(
                      value: _hoursBetween.toDouble(),
                      min: 1,
                      max: 24,
                      divisions: 23,
                      label: '$_hoursBetween hours',
                      onChanged: (value) {
                        setState(() {
                          _hoursBetween = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // First Dose Time
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('First dose time *'),
                subtitle: Text(
                  _firstDoseTime != null
                      ? DateFormat.jm().format(_firstDoseTime!)
                      : 'Tap to select',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _pickFirstDoseTime,
              ),
            ),

            // Show calculated dose times
            if (doseTimes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.alarm, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Scheduled Times',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...doseTimes.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
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
                      }),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveMedication,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(isEditing ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}