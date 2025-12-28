import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  String id;
  String name;
  int price;
  int quantity;
  int total;
  Timestamp createdAt;
  String? productId;
  String? financialRecordId; // Added this field

  Sale({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    required this.createdAt,
    this.productId,
    this.financialRecordId, // Added to constructor
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 0,
      total: data['total'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      productId: data['productId'],
      financialRecordId: data['financialRecordId'], // Added this line
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
      'createdAt': createdAt,
      'productId': productId,
      'financialRecordId': financialRecordId, // Added this line
    };
  }
}
