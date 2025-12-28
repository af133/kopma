class SoldProduct {
  final String productName;
  final int quantity;
  final double totalRevenue;

  SoldProduct({
    required this.productName,
    required this.quantity,
    required this.totalRevenue,
  });

  factory SoldProduct.fromMap(Map<String, dynamic> map) {
    return SoldProduct(
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      totalRevenue: (map['totalRevenue'] as num).toDouble(),
    );
  }
}
