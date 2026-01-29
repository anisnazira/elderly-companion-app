import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  CollectionReference get medications => _db.collection('medications');
  CollectionReference get appointments => _db.collection('appointments');

  // ===== MEDICATION METHODS =====
  
  Future<DocumentReference> addMedication(Map<String, dynamic> data) async {
    return await medications.add(data);
  }

  Future<void> updateMedication(String id, Map<String, dynamic> data) async {
    await medications.doc(id).update(data);
  }

  Stream<QuerySnapshot> getMedicationsStream(String elderId) {
    return medications
        .where('elderId', isEqualTo: elderId)
        .orderBy('time')  // ADD THIS - orders by medication time
        .snapshots();
  }

  Future<void> deleteMedication(String docId) async {
    await medications.doc(docId).delete();  // FIX THIS - was empty!
  }

  Future<DocumentSnapshot> getMedication(String docId) async {
    return await medications.doc(docId).get();
  }

  // ===== APPOINTMENT METHODS =====
  
  Future<DocumentReference> addAppointment(Map<String, dynamic> data) async {
    return await appointments.add(data);
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    await appointments.doc(id).update(data);
  }

  Stream<QuerySnapshot> getAppointmentsStream(String elderId) {
    return appointments
        .where('elderId', isEqualTo: elderId)
        .orderBy('datetime')  // ADD THIS - orders by appointment datetime
        .snapshots();
  }

  Future<void> deleteAppointment(String docId) async {
    await appointments.doc(docId).delete();
  }

  Future<DocumentSnapshot> getAppointment(String docId) async {
    return await appointments.doc(docId).get();
  }
}