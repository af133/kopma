
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/models/sale.dart';

class SaleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Sale>> getSales() {
    return _db.collection('sales').orderBy('createdAt', descending: true).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }

  Future<void> addSale(Sale sale, Product product) async {
    WriteBatch batch = _db.batch();

    DocumentReference saleRef = _db.collection('sales').doc();
    batch.set(saleRef, {
      'productId': sale.productId,
      'name': sale.name,
      'price': sale.price,
      'quantity': sale.quantity,
      'total': sale.total,
      'createdAt': sale.createdAt,
    });

    DocumentReference productRef = _db.collection('products').doc(product.id);
    batch.update(productRef, {'stock': product.stock - sale.quantity});

    await batch.commit();
  }

  Future<void> updateSale(Sale sale, int oldQuantity) async {
    WriteBatch batch = _db.batch();

    DocumentReference saleRef = _db.collection('sales').doc(sale.id);
    batch.update(saleRef, {
      'quantity': sale.quantity,
      'total': sale.price * sale.quantity,
    });

    DocumentReference productRef = _db.collection('products').doc(sale.productId);
    int stockDifference = sale.quantity - oldQuantity;
    batch.update(productRef, {'stock': FieldValue.increment(-stockDifference)});

    await batch.commit();
  }
}
