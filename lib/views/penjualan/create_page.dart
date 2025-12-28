import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/models/sale.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/services/sale_service.dart';
import 'package:myapp/widgets/custom_app_bar.dart';

class SaleCreatePage extends StatefulWidget {
  const SaleCreatePage({super.key});

  @override
  SaleCreatePageState createState() => SaleCreatePageState();
}

class SaleCreatePageState extends State<SaleCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _manualNameController = TextEditingController();
  final _priceController = TextEditingController();

  Product? _selectedProduct;
  bool _showManualEntry = false;
  double _totalPrice = 0.0;

  final Product _otherProduct = Product(
    id: 'other',
    name: 'Lainnya',
    price: 0,
    stock: 0,
    imageUrl: '',
  );

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateTotalPrice);
    _priceController.addListener(_calculateTotalPrice);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _manualNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _calculateTotalPrice() {
    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    final double price = double.tryParse(_priceController.text) ?? 0;

    setState(() {
      _totalPrice = price * quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Buat Penjualan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProductDropdown(),
              const SizedBox(height: 16),
              if (_showManualEntry) _buildManualNameField(),
              
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga Jual per Unit'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Masukkan harga jual';
                  if (double.tryParse(value) == null) return 'Harga tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Jumlah Terjual'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Masukkan jumlah';
                  if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Jumlah tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _buildTotalPriceDisplay(),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveSale,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Penjualan', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDropdown() {
    return StreamBuilder<List<Product>>(
      stream: ProductService().getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final products = snapshot.data!;
        final items = [...products, _otherProduct];

        return DropdownButtonFormField<Product>(
          items: items.map((product) {
            return DropdownMenuItem<Product>(
              value: product,
              child: Text(product.name, style: GoogleFonts.lato()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedProduct = value;
              _showManualEntry = (value?.id == 'other');
              if (!_showManualEntry && value != null) {
                _priceController.text = value.price.toString();
              } else {
                _priceController.clear();
              }
              _calculateTotalPrice();
            });
          },
          decoration: const InputDecoration(labelText: 'Pilih Produk'),
          validator: (value) => value == null ? 'Pilih produk' : null,
        );
      },
    );
  }

  Widget _buildManualNameField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _manualNameController,
        decoration: const InputDecoration(labelText: 'Nama Produk Manual'),
        validator: (value) {
          if (_showManualEntry && (value == null || value.isEmpty)) return 'Masukkan nama produk';
          return null;
        },
      ),
    );
  }

  Widget _buildTotalPriceDisplay() {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text('Total Pendapatan', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(_totalPrice),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    try {
      final int quantity = int.parse(_quantityController.text);
      final double price = double.parse(_priceController.text);
      final String productName;
      final String? productId;

      if (_showManualEntry) {
        productName = _manualNameController.text;
        productId = null; 
      } else {
        productName = _selectedProduct!.name;
        productId = _selectedProduct!.id;
      }

      final newSale = Sale(
        id: '',
        name: productName,
        price: price,
        quantity: quantity,
        total: price * quantity,
        createdAt: Timestamp.now(),
        productId: productId,
      );

      await SaleService().createSale(newSale);
      
      if (!mounted) return;
      context.pop();

    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $error')),
      );
    }
  }
}
