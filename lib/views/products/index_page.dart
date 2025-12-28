import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Import package intl
import 'package:myapp/models/product.dart';
import 'package:myapp/routes/app_router.dart';
import 'dart:async'; 

class ProductIndexPage extends StatefulWidget {
  const ProductIndexPage({super.key});

  @override
  State<ProductIndexPage> createState() => _ProductIndexPageState();
}

class _ProductIndexPageState extends State<ProductIndexPage> {
  late StreamSubscription<QuerySnapshot> _productSubscription;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _productSubscription = FirebaseFirestore.instance.collection('products').snapshots().listen(
      (snapshot) {
        if (mounted) {
          final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
          setState(() {
            _allProducts = products;
            _filterProducts(); 
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal memuat produk: $error")),
          );
        }
      },
    );

    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _productSubscription.cancel();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Belum ada produk.'
                                : 'Produk tidak ditemukan.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl ?? '',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image, color: Colors.grey),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.error, color: Colors.red),
                                    ),
                                  ),
                                ),
                                title: Text(product.name,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                // --- PERUBAHAN DI SINI ---
                                subtitle: Text(
                                  currencyFormatter.format(product.price), // Format harga
                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                                ),
                                // --- AKHIR PERUBAHAN ---
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    context.push('${AppRoutes.productUpdate}/${product.id}');
                                  },
                                ),
                                onTap: () {
                                  context.push('${AppRoutes.productUpdate}/${product.id}');
                                },
                              ),
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
