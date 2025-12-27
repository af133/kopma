import 'package:cloud_firestore/cloud_firestore.dart';

enum RecordType { income, expense }

class FinancialRecord {
  final String id;
  final String description;
  final double amount;
  final RecordType type;
  final Timestamp createdAt;

  FinancialRecord({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.createdAt,
  });

  factory FinancialRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FinancialRecord(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: (data['type'] == 'income') ? RecordType.income : RecordType.expense,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'amount': amount,
      'type': type == RecordType.income ? 'income' : 'expense',
      'createdAt': createdAt,
    };
  }
}
