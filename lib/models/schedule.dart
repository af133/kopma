
import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String day;
  final List<String> names;

  Schedule({required this.id, required this.day, required this.names});

  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: doc.id,
      day: data['day'] ?? '',
      names: List<String>.from(data['names'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'names': names,
    };
  }
}
