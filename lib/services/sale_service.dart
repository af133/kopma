import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/sale.dart';

class SaleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'sales';

  // Create
  Future<void> createSale(Sale sale) async {
    WriteBatch batch = _db.batch();

    // Create a new financial record and get its ID
    DocumentReference financialRecordRef = _db.collection('financial_records').doc();
    batch.set(financialRecordRef, {
      'type': 'sale',
      'amount': sale.total,
      'description': 'Penjualan ${sale.name}',
      'createdAt': sale.createdAt,
    });
    
    // Set the financialRecordId in the sale object
    sale.financialRecordId = financialRecordRef.id;

    DocumentReference saleRef = _db.collection(_collectionName).doc();
    batch.set(saleRef, sale.toFirestore());

    if (sale.productId != null) {
      DocumentReference productRef = _db.collection('products').doc(sale.productId);
      batch.update(productRef, {'stock': FieldValue.increment(-sale.quantity)});
    }

    await batch.commit();
  }

  // Read
  Stream<List<Sale>> getSales() {
    return _db
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }

  // Read by id
  Future<Sale> getSale(String id) async {
    final doc = await _db.collection(_collectionName).doc(id).get();
    return Sale.fromFirestore(doc);
  }

  // Update
  Future<void> updateSale(Sale sale, int oldQuantity) async {
    WriteBatch batch = _db.batch();

    DocumentReference saleRef = _db.collection(_collectionName).doc(sale.id);
    batch.update(saleRef, sale.toFirestore());

    if (sale.productId != null) {
      DocumentReference productRef = _db.collection('products').doc(sale.productId);
      int stockDifference = sale.quantity - oldQuantity;
      batch.update(productRef, {'stock': FieldValue.increment(-stockDifference)});
    }

    // Find and update the corresponding financial record
    if(sale.financialRecordId != null){
      DocumentReference financialRecordRef = _db.collection('financial_records').doc(sale.financialRecordId);
      batch.update(financialRecordRef, {'amount': sale.total});
    }
    
    await batch.commit();
  }

  // Delete
  Future<void> deleteSale(String id) async {
    DocumentReference saleRef = _db.collection(_collectionName).doc(id);
    DocumentSnapshot saleDoc = await saleRef.get();
    Sale sale = Sale.fromFirestore(saleDoc);

    WriteBatch batch = _db.batch();

    batch.delete(saleRef);

    if (sale.productId != null) {
      DocumentReference productRef = _db.collection('products').doc(sale.productId);
      batch.update(productRef, {'stock': FieldValue.increment(sale.quantity)});
    }

    if(sale.financialRecordId != null){
      DocumentReference financialRecordRef = _db.collection('financial_records').doc(sale.financialRecordId);
      batch.delete(financialRecordRef);
    }

    await batch.commit();
  }
}
