import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import 'package:myapp/services/product_service.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  String _name = '';
  int _price = 0;
  int _stock = 0;
  XFile? _image;

  bool _isLoading = false; // To show a loading indicator

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

      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih gambar produk.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final newProduct = Product(
        name: _name,
        price: _price,
        stock: _stock,
        imageUrl: '', // Placeholder, will be replaced by the service
      );

      try {
        await _productService.addProduct(newProduct, _image!);
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan produk: $e')),
        );
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
        title: const Text('Tambah Produk Baru', style: TextStyle(color: Colors.white)),
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
                decoration: inputDecoration.copyWith(labelText: 'Nama Produk'),
                validator: (value) => value!.isEmpty ? 'Nama produk harus diisi' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: inputDecoration.copyWith(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Harga harus diisi' : null,
                onSaved: (value) => _price = int.tryParse(value!) ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
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
                    _image == null
                        ? const Icon(Icons.image, size: 80, color: Colors.grey)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(File(_image!.path), height: 150, fit: BoxFit.cover),
                          ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                      ),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Pilih Gambar'),
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
                      child: const Text('Simpan Produk', style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
