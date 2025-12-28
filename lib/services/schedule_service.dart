
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/schedule.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'schedules';

  // Create
  Future<void> addSchedule(String day, List<String> names) {
    return _firestore.collection(_collectionName).add({
      'day': day,
      'names': names,
    });
  }

  // Read
  Stream<List<Schedule>> getSchedules() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList();
    });
  }

  // Read by id
  Future<Schedule> getScheduleById(String id) async {
    final doc = await _firestore.collection(_collectionName).doc(id).get();
    return Schedule.fromFirestore(doc);
  }

  // Read by day
  Stream<List<Schedule>> getSchedulesForDay(String day) {
    return _firestore
        .collection(_collectionName)
        .where('day', isEqualTo: day)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Schedule.fromFirestore(doc)).toList();
    });
  }

  // Update
  Future<void> updateSchedule(String id, String day, List<String> names) {
    return _firestore.collection(_collectionName).doc(id).update({
      'day': day,
      'names': names,
    });
  }

  // Delete
  Future<void> deleteSchedule(String id) {
    return _firestore.collection(_collectionName).doc(id).delete();
  }
}
