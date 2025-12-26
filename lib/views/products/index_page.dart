import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/product_service.dart';
import 'create_page.dart';
import 'update_page.dart';

class ProductIndex extends StatelessWidget {
  const ProductIndex({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductService productService = ProductService();
    
    // Define the color scheme
    final Color primaryColor = Colors.brown[700]!;
    final Color backgroundColor = Colors.brown[50]!;
    final Color cardColor = Colors.white; // Keep cards white for contrast against the brown background
    final Color accentColor = Colors.brown[900]!;
    final Color deleteColor = Colors.red[700]!;

    return Scaffold(
      backgroundColor: backgroundColor, // Set background color
      appBar: AppBar(
        title: const Text('Produk Koperasi', style: TextStyle(color: Colors.white)), // White title for contrast
        backgroundColor: primaryColor, // Dark brown app bar
        iconTheme: const IconThemeData(color: Colors.white), // Make back arrow white if it exists
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white), // White icon
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePage()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor)); // Themed progress indicator
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada produk.'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4, // Add some shadow
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  leading: ClipRRect( // Clip image for rounded corners
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      product.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: Icon(Icons.shopping_bag_outlined, color: Colors.grey[400], size: 30),
                      ),
                    ),
                  ),
                  title: Text(
                    product.name, 
                    style: TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontSize: 16)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(product.price)}',
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                      Text(
                        'Stok: ${product.stock}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: accentColor),
                        tooltip: 'Ubah Produk',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UpdatePage(product: product)),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: deleteColor),
                        tooltip: 'Hapus Produk',
                        onPressed: () {
                          // Show a confirmation dialog before deleting
                          showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                title: const Text('Konfirmasi Hapus'),
                                content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Batal'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(foregroundColor: deleteColor),
                                    child: const Text('Hapus'),
                                    onPressed: () {
                                      productService.deleteProduct(product.id!);
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
