import 'package:cloud_firestore/cloud_firestore.dart';

class Withdrawal {
  final String id;
  final String title;
  final String description;
  final double amount;
  final Timestamp createdAt;
  final String? notaImg;
  final String? publicId;

  Withdrawal({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.createdAt,
    this.notaImg,
    this.publicId,
  });

  factory Withdrawal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Withdrawal(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      notaImg: data['nota_img'],
      publicId: data['publicId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'amount': amount,
      'createdAt': createdAt,
      'nota_img': notaImg,
      'publicId': publicId,
    };
  }
}
