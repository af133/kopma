import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/sale.dart';

class SaleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'sales';

  // Mendapatkan stream semua penjualan
  Stream<List<Sale>> getSales({DateTime? startDate, DateTime? endDate}) {
    Query query = _db.collection(_collectionName).orderBy('createdAt', descending: true);

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      // Add 1 day to endDate to include the entire day
      final adjustedEndDate = endDate.add(const Duration(days: 1));
      query = query.where('createdAt', isLessThan: Timestamp.fromDate(adjustedEndDate));
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList());
  }


  // Mendapatkan satu data penjualan berdasarkan ID
  Future<Sale> getSale(String id) async {
    DocumentSnapshot doc = await _db.collection(_collectionName).doc(id).get();
    return Sale.fromFirestore(doc);
  }

  // Membuat penjualan baru
  Future<void> createSale(Sale sale) async {
    WriteBatch batch = _db.batch();

    // 1. Buat dokumen penjualan baru
    DocumentReference saleRef = _db.collection(_collectionName).doc();
    batch.set(saleRef, sale.toFirestore());

    // 2. Jika ada ID produk, kurangi stoknya
    if (sale.productId != null) {
      DocumentReference productRef = _db.collection('products').doc(sale.productId!);
      batch.update(productRef, {'stock': FieldValue.increment(-sale.quantity)});
    }

    await batch.commit();
  }

  // Memperbarui penjualan yang ada
  Future<void> updateSale(Sale sale, int oldQuantity) async {
    WriteBatch batch = _db.batch();

    // 1. Perbarui dokumen penjualan
    DocumentReference saleRef = _db.collection(_collectionName).doc(sale.id);
    batch.update(saleRef, sale.toFirestore());

    // 2. Sesuaikan stok produk jika ada ID produk
    if (sale.productId != null) {
      final quantityDifference = oldQuantity - sale.quantity;
      DocumentReference productRef = _db.collection('products').doc(sale.productId!);
      batch.update(productRef, {'stock': FieldValue.increment(quantityDifference)});
    }

    await batch.commit();
  }

  // Menghapus penjualan
  Future<void> deleteSale(String id) async {
    DocumentReference saleRef = _db.collection(_collectionName).doc(id);

    await _db.runTransaction((transaction) async {
      DocumentSnapshot saleSnapshot = await transaction.get(saleRef);
      if (!saleSnapshot.exists) {
        throw Exception("Penjualan tidak ditemukan!");
      }

      Sale sale = Sale.fromFirestore(saleSnapshot);

      // 1. Hapus dokumen penjualan
      transaction.delete(saleRef);

      // 2. Kembalikan stok produk jika ada ID produk
      if (sale.productId != null) {
        DocumentReference productRef = _db.collection('products').doc(sale.productId!);
        transaction.update(productRef, {'stock': FieldValue.increment(sale.quantity)});
      }
    });
  }

  // Helper function to get sales for export
  Future<List<Sale>> getSalesForExport({DateTime? startDate, DateTime? endDate}) async {
    Query query = _db.collection(_collectionName).orderBy('createdAt', descending: true);

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      final adjustedEndDate = endDate.add(const Duration(days: 1));
      query = query.where('createdAt', isLessThan: Timestamp.fromDate(adjustedEndDate));
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();
  }
}
