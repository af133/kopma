
import 'package:flutter/material.dart';
import 'package:myapp/models/sale.dart';
import 'package:myapp/services/sale_service.dart';

class SaleUpdatePage extends StatefulWidget {
  final Sale sale;

  const SaleUpdatePage({super.key, required this.sale});

  @override
  State<SaleUpdatePage> createState() => _SaleUpdatePageState();
}

class _SaleUpdatePageState extends State<SaleUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _saleService = SaleService();
  late int _quantity;
  final int _oldQuantity = 0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.sale.quantity;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final updatedSale = Sale(
        id: widget.sale.id,
        productId: widget.sale.productId,
        name: widget.sale.name,
        price: widget.sale.price,
        quantity: _quantity,
        total: widget.sale.price * _quantity,
        createdAt: widget.sale.createdAt,
      );

      try {
        await _saleService.updateSale(updatedSale, _oldQuantity);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui penjualan: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.brown[700]!;
    final Color backgroundColor = Colors.brown[50]!;
    final Color accentColor = Colors.brown[900]!;

    final inputDecoration = InputDecoration(
      labelStyle: TextStyle(color: Colors.brown[800]),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accentColor, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.brown[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Ubah Penjualan', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Produk: ${widget.sale.name}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: inputDecoration.copyWith(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Jumlah harus diisi' : null,
                onSaved: (value) => _quantity = int.tryParse(value!) ?? 0,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: _submit,
                      child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
