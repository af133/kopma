import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final String name;
  final double price;         // Harga jual per item
  final int quantity;
  final double total;         // Total harga jual (price * quantity)
  final Timestamp createdAt;
  final String? productId;

  Sale({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    required this.createdAt,
    this.productId,
  });

  // Konversi dari dokumen Firestore ke objek Sale
  factory Sale.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      productId: data['productId'] as String?,
    );
  }

  // Konversi dari objek Sale ke Map untuk disimpan di Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
      'createdAt': createdAt,
      'productId': productId,
    };
  }
}
