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

  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _price = widget.product.price;
    _stock = widget.product.stock;
  }

  void _pickImage() async {
    final image = await _productService.pickImage();
    setState(() {
      _image = image;
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedProduct = Product(
        id: widget.product.id,
        name: _name,
        price: _price,
        stock: _stock,
        imageUrl: widget.product.imageUrl,
      );
      await _productService.updateProduct(updatedProduct, image: _image);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Name is required' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Price is required' : null,
                onSaved: (value) => _price = int.parse(value!),
              ),
              TextFormField(
                initialValue: _stock.toString(),
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Stock is required' : null,
                onSaved: (value) => _stock = int.parse(value!),
              ),
              const SizedBox(height: 20),
              _image == null
                  ? Image.network(widget.product.imageUrl, height: 150)
                  : Image.file(File(_image!.path), height: 150),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Change Image'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Update Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
