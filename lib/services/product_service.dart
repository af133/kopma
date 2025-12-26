import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _cloudinary = CloudinaryPublic('dcyy8h12d', 'ml_default');
  final _picker = ImagePicker();

  // Get a stream of products
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Add a new product
  Future<void> addProduct(Product product, XFile imageFile) async {
    try {
      // Upload image to Cloudinary
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path,
            resourceType: CloudinaryResourceType.Image),
      );

      String imageUrl = response.secureUrl;

      // Add product to Firestore with the image URL
      await _firestore.collection('products').add({
        'name': product.name,
        'price': product.price,
        'stock': product.stock,
        'imageUrl': imageUrl,
      });
    } catch (e, s) {
      developer.log('Error adding product', name: 'ProductService', error: e, stackTrace: s);
      rethrow;
    }
  }

  // Update an existing product
  Future<void> updateProduct(Product product, {XFile? image}) async {
    try {
      String imageUrl = product.imageUrl;
      if (image != null) {
        // If there's a new image, upload it
        CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(image.path,
              resourceType: CloudinaryResourceType.Image),
        );
        imageUrl = response.secureUrl;
      }

      // Update the product in Firestore
      await _firestore.collection('products').doc(product.id).update({
        'name': product.name,
        'price': product.price,
        'stock': product.stock,
        'imageUrl': imageUrl,
      });
    } catch (e, s) {
      developer.log('Error updating product', name: 'ProductService', error: e, stackTrace: s);
      rethrow;
    }
  }

  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e, s) {
      developer.log('Error deleting product', name: 'ProductService', error: e, stackTrace: s);
      rethrow;
    }
  }

  // Pick an image from gallery
  Future<XFile?> pickImage() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }
}
