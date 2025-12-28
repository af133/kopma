import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/financial_event.dart';

// PERBAIKAN: Jadikan class ini turunan dari FinancialEvent untuk konsistensi
class Withdrawal extends FinancialEvent {
  final String id;
  final String description;
  final double amount;
  // Field 'date' sekarang diwarisi dari FinancialEvent

  Withdrawal({
    required this.id,
    required this.description,
    required this.amount,
    required DateTime date, // Terima DateTime untuk super constructor
  }) : super(date); // Panggil super constructor dengan date

  factory Withdrawal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // PERBAIKAN: Konversi Timestamp dari Firestore menjadi DateTime
    DateTime parsedDate;
    if (data['createdAt'] is Timestamp) {
      parsedDate = (data['createdAt'] as Timestamp).toDate();
    } else {
      // Fallback jika data tidak dalam format yang diharapkan
      parsedDate = DateTime.now();
    }

    return Withdrawal(
      id: doc.id,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: parsedDate, // Teruskan DateTime yang sudah dikonversi ke constructor
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'amount': amount,
      // Gunakan 'date' yang diwarisi untuk menulis Timestamp ke Firestore
      'createdAt': Timestamp.fromDate(date),
    };
  }
}
