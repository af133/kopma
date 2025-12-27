import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/product.dart';

class ProductService {
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  Stream<List<Product>> getProducts() {
    return _productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Future<List<Product>> getProductsList() async {
    final snapshot = await _productsCollection.get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  Future<void> addProduct(Product product) {
    return _productsCollection.add(product.toFirestore());
  }

  Future<void> updateProduct(Product product) {
    return _productsCollection.doc(product.id).update(product.toFirestore());
  }

  Future<void> deleteProduct(String id) {
    return _productsCollection.doc(id).delete();
  }
}
