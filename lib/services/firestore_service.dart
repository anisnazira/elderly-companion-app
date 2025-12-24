import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections: medications, appointments
  CollectionReference get medications => _db.collection('medications');
  CollectionReference get appointments => _db.collection('appointments');

  // Medication CRUD
  Future<DocumentReference> addMedication(Map<String, dynamic> data) async {
    return await medications.add(data);
  }

  Future<void> updateMedication(String id, Map<String, dynamic> data) async {
    await medications.doc(id).update(data);
  }

  Stream<QuerySnapshot> getMedicationsStream(String elderId) {
    return medications.where('elderId', isEqualTo: elderId).snapshots();
  }

  // Appointment CRUD
  Future<DocumentReference> addAppointment(Map<String, dynamic> data) async {
    return await appointments.add(data);
  }

  Future<void> updateAppointment(String id, Map<String, dynamic> data) async {
    await appointments.doc(id).update(data);
  }

  Stream<QuerySnapshot> getAppointmentsStream(String elderId) {
    return appointments.where('elderId', isEqualTo: elderId).snapshots();
  }
}
