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

  Future<Product> getProduct(String id) async {
    final doc = await _productsCollection.doc(id).get();
    return Product.fromFirestore(doc);
  }

  Future<void> createProduct(Product product) {
    return _productsCollection.add(product.toFirestore());
  }

  Future<void> updateProduct(String id, Product product) {
    return _productsCollection.doc(id).update(product.toFirestore());
  }

  Future<void> deleteProduct(String id) {
    return _productsCollection.doc(id).delete();
  }
}
