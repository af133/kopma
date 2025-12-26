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

  void _pickImage() async {
    final image = await _productService.pickImage();
    setState(() {
      _image = image;
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _image != null) {
      _formKey.currentState!.save();
      final newProduct = Product(
        name: _name,
        price: _price,
        stock: _stock,
        imageUrl: '', // Placeholder
      );
      await _productService.addProduct(newProduct, _image!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Price is required' : null,
                onSaved: (value) => _price = int.parse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Stock is required' : null,
                onSaved: (value) => _stock = int.parse(value!),
              ),
              const SizedBox(height: 20),
              _image == null
                  ? const Text('No image selected.')
                  : Image.file(File(_image!.path), height: 150),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
