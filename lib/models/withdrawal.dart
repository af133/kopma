import 'package:cloud_firestore/cloud_firestore.dart';

class Withdrawal {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  Withdrawal({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  factory Withdrawal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Withdrawal(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'amount': amount,
      'createdAt': Timestamp.fromDate(date),
    };
  }
}
