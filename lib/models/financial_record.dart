import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialRecord {
  final String id;
  final String type;
  final double amount;
  final String description;
  final DateTime date;
  final Timestamp createdAt;

  FinancialRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  factory FinancialRecord.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return FinancialRecord(
      id: doc.id,
      type: data['type'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'amount': amount,
      'description': description,
      'date': date,
      'createdAt': createdAt,
    };
  }
}
