import 'package:flutter/material.dart';

class ProductCreatePage extends StatelessWidget {
  const ProductCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: const Center(
        child: Text('Halaman Tambah Produk'),
      ),
    );
  }
}
