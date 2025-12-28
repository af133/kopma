import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/product.dart'; // Import model Product

class ProductIndexPage extends StatefulWidget {
  const ProductIndexPage({super.key});

  @override
  State<ProductIndexPage> createState() => _ProductIndexPageState();
}

class _ProductIndexPageState extends State<ProductIndexPage> {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _updateProductList(List<Product> products) {
    setState(() {
      _allProducts = products;
      _filterProducts(); // Terapkan filter yang ada saat daftar diperbarui
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Produk',
                hintText: 'Masukkan nama produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: theme.colorScheme.secondary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Product List from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada produk.'));
                  }

                  // Konversi snapshot ke daftar Product dan perbarui state
                  final products = snapshot.data!.docs
                      .map((doc) => Product.fromFirestore(doc))
                      .toList();
                  _updateProductList(products);

                  return _filteredProducts.isEmpty
                      ? const Center(
                          child: Text('Produk tidak ditemukan.'),
                        )
                      : ListView.builder(
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                leading: product.imageUrl != null
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(product.imageUrl!),
                                        radius: 25,
                                      )
                                    : const CircleAvatar(
                                        radius: 25,
                                        child: Icon(Icons.inventory_2),
                                      ),
                                title: Text(product.name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold)),
                                subtitle: Text('Rp ${product.price.toStringAsFixed(0)} - Stok: ${product.stock}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // Aksi ketika produk di-tap, misalnya navigasi ke halaman detail produk
                                  // context.go('${AppRoutes.productUpdate}/${product.id}');
                                },
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
