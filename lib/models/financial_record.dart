import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/financial_event.dart';

class FinancialRecord extends FinancialEvent {
  final String id;
  final String title;
  final String description;
  final double cost;
  final String? notaImg;

  FinancialRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required DateTime date, 
    this.notaImg,
  }) : super(date);

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory FinancialRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // PERBAIKAN: Konversi Timestamp ke DateTime di sini
    DateTime parsedDate;
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now(); 
    }

    return FinancialRecord(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      cost: _parseDouble(data['cost']),
      date: parsedDate, 
      notaImg: data['nota_img'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'cost': cost,
      'date': Timestamp.fromDate(date),
      'nota_img': notaImg,
    };
  }
}
