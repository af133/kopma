import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final String productId;
  final String name;
  final int price;
  final int quantity;
  final int total;
  final Timestamp createdAt;

  Sale({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    required this.createdAt,
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle price and total which might be int or double from Firestore
    final priceNum = data['price'] ?? 0;
    final totalNum = data['total'] ?? 0;

    return Sale(
      id: doc.id,
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: priceNum is double ? priceNum.toInt() : priceNum as int,
      quantity: data['quantity'] ?? 0,
      total: totalNum is double ? totalNum.toInt() : totalNum as int,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
