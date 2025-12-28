import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/sale.dart';
import 'package:myapp/services/sale_service.dart';
import 'package:myapp/widgets/custom_app_bar.dart';

class SaleUpdatePage extends StatefulWidget {
  final String saleId;

  const SaleUpdatePage({super.key, required this.saleId});

  @override
  SaleUpdatePageState createState() => SaleUpdatePageState();
}

class SaleUpdatePageState extends State<SaleUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  late Future<Sale> _saleFuture;
  double _totalPrice = 0.0;
  int _initialQuantity = 0;

  @override
  void initState() {
    super.initState();
    _saleFuture = SaleService().getSale(widget.saleId);
    _saleFuture.then((sale) {
      if (mounted) {
        _nameController.text = sale.name;
        _quantityController.text = sale.quantity.toString();
        _priceController.text = sale.price.toString();
        _initialQuantity = sale.quantity;
        _calculateTotalPrice();

        _quantityController.addListener(_calculateTotalPrice);
        _priceController.addListener(_calculateTotalPrice);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
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
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Scaffold(
      appBar: const CustomAppBar(title: 'Perbarui Penjualan'),
      body: FutureBuilder<Sale>(
        future: _saleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Gagal memuat data penjualan.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Produk'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Masukkan nama produk' : null,
                  ),
                  const SizedBox(height: 16),
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
                  Container(
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
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _updateSale,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateSale() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final originalSale = await _saleFuture;
      final updatedSale = Sale(
        id: widget.saleId,
        name: _nameController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        total: _totalPrice,
        createdAt: originalSale.createdAt,
        productId: originalSale.productId,
      );

      await SaleService().updateSale(updatedSale, _initialQuantity);
      
      if (!mounted) return;
      context.pop();

    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui: $error')),
      );
    }
  }
}
