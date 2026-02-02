import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- APPOINTMENTS ---

  // Adds new appointment with 'pending' status
  Future<void> addAppointment(String elderlyId, Map<String, dynamic> data) {
    return _db.collection('users').doc(elderlyId).collection('appointments').add({
      ...data,
      'status': 'pending', // Default status for the 'Attend' button logic
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getAppointments(String elderlyId) {
    return _db.collection('users').doc(elderlyId).collection('appointments')
        .orderBy('appointmentDate', descending: false).snapshots();
  }

  Stream<QuerySnapshot> getAppointmentsStream(String elderlyId) {
    return _db.collection('users').doc(elderlyId).collection('appointments')
        .orderBy('appointmentDate', descending: false).snapshots();
  }

  // Used when the Elderly clicks "ATTEND"
  Future<void> markAppointmentAttended(String elderlyId, String appId) {
    return _db.collection('users').doc(elderlyId).collection('appointments').doc(appId).update({
      'status': 'attended',
      'attendedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAppointment(String elderlyId, String appId, Map<String, dynamic> data) {
    return _db.collection('users').doc(elderlyId).collection('appointments').doc(appId).update(data);
  }

  Future<void> deleteAppointment(String elderlyId, String appId) {
    return _db.collection('users').doc(elderlyId).collection('appointments').doc(appId).delete();
  }

  // --- MEDICATIONS ---

  Future<void> addMedication(String elderlyId, Map<String, dynamic> data) {
    return _db.collection('users').doc(elderlyId).collection('medications').add(data);
  }

  Stream<QuerySnapshot> getMedicationsStream(String elderlyId) {
    return _db.collection('users').doc(elderlyId).collection('medications').snapshots();
  }

  Future<void> updateMedication(String elderlyId, String medId, Map<String, dynamic> data) {
    return _db.collection('users').doc(elderlyId).collection('medications').doc(medId).update(data);
  }

  Future<void> deleteMedication(String elderlyId, String medId) {
    return _db.collection('users').doc(elderlyId).collection('medications').doc(medId).delete();
  }

  // Marks medication as taken in a sub-collection for history
  Future<void> markAsTaken(String elderlyId, String medId, String name) {
    return _db.collection('users').doc(elderlyId).collection('medications').doc(medId)
        .collection('history').add({
      'name': name,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'taken',
    });
  }
}