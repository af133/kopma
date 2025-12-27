import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/views/products/create_page.dart';
import 'package:myapp/views/products/update_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductIndex extends StatefulWidget {
  const ProductIndex({super.key});

  @override
  State<ProductIndex> createState() => _ProductIndexState();
}

class _ProductIndexState extends State<ProductIndex> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProductsList();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = _productService.getProductsList();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _navigateTo(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    if (result == true) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Produk', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown[700]!, Colors.brown[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama produk...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.brown[700]!, width: 2.0),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.brown[50],
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada produk. Tambahkan satu!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          _allProducts = snapshot.data!;
          _filteredProducts = _allProducts.where((product) {
            return product.name.toLowerCase().contains(_searchController.text.toLowerCase());
          }).toList();


          return RefreshIndicator(
            onRefresh: () async => _loadProducts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                Product product = _filteredProducts[index];
                return _buildProductCard(product);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateTo(const CreateProductPage()),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Produk', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[700],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            _buildProductImage(product.imageUrl),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Harga: ${formatCurrency.format(product.price)}',
                    style: GoogleFonts.lato(color: Colors.green[700]),
                  ),
                  Text(
                    'Stok: ${product.stock}',
                    style: GoogleFonts.lato(color: product.stock < 10 ? Colors.orange : Colors.grey[600]),
                  ),
                ],
              ),
            ),
            _buildActionButtons(product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: CachedNetworkImage(
        imageUrl: imageUrl ?? '',
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 70,
          height: 70,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: 70,
          height: 70,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Product product) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_note, color: Colors.blueAccent),
          tooltip: 'Edit Produk',
          onPressed: () => _navigateTo(UpdateProductPage(product: product)),
        ),
        IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
          tooltip: 'Hapus Produk',
          onPressed: () => _confirmDelete(product),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi Hapus', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        content: Text('Anda yakin ingin menghapus produk "${product.name}"?', style: GoogleFonts.lato()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal', style: GoogleFonts.lato(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Hapus', style: GoogleFonts.lato(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk berhasil dihapus', style: GoogleFonts.lato()),
            backgroundColor: Colors.green,
          ),
        );
        _loadProducts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus produk: ${e.toString()}', style: GoogleFonts.lato()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
