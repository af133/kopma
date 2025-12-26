import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/product_service.dart';

class UpdatePage extends StatefulWidget {
  final Product product;

  const UpdatePage({super.key, required this.product});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  late String _name;
  late int _price;
  late int _stock;
  XFile? _image;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _price = widget.product.price;
    _stock = widget.product.stock;
  }

  void _pickImage() async {
    final image = await _productService.pickImage();
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        price: _price,
        stock: _stock,
        imageUrl: widget.product.imageUrl,
      );

      try {
        await _productService.updateProduct(updatedProduct, image: _image);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui produk: $e')),
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
        title: const Text('Ubah Produk', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: inputDecoration.copyWith(labelText: 'Nama Produk'),
                validator: (value) => value!.isEmpty ? 'Nama produk harus diisi' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _price.toString(),
                decoration: inputDecoration.copyWith(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Harga harus diisi' : null,
                onSaved: (value) => _price = int.tryParse(value!) ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: inputDecoration.copyWith(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Stok harus diisi' : null,
                onSaved: (value) => _stock = int.tryParse(value!) ?? 0,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown[300]!),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: _image == null
                          ? Image.network(
                              widget.product.imageUrl, 
                              height: 150, 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 80, color: Colors.grey),
                            )
                          : Image.file(File(_image!.path), height: 150, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                      ),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Ganti Gambar'),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
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
