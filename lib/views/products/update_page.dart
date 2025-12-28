import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/cloudinary_service.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/widgets/custom_app_bar.dart';

class ProductUpdatePage extends StatefulWidget {
  final String productId;

  const ProductUpdatePage({super.key, required this.productId});

  @override
  ProductUpdatePageState createState() => ProductUpdatePageState();
}

class ProductUpdatePageState extends State<ProductUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  XFile? _imageFile;
  String? _existingImageUrl;

  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ProductService _productService = ProductService();
  bool _isLoading = false;
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProduct(widget.productId);
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (mounted) {
      setState(() {
        _imageFile = selectedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Edit Produk',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Produk'),
                  content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _productService.deleteProduct(widget.productId);
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  context.pop();
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Produk tidak ditemukan.'));
          }

          final product = snapshot.data!;
          _nameController.text = product.name;
          _priceController.text = product.price.toString();
          _stockController.text = product.stock.toString();
          _existingImageUrl = product.imageUrl;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Produk',
                      labelStyle: GoogleFonts.lato(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan nama produk';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Harga',
                      labelStyle: GoogleFonts.lato(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan harga';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Masukkan harga yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      labelText: 'Stok',
                      labelStyle: GoogleFonts.lato(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan stok';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Masukkan stok yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(_imageFile!.path),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _existingImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                _existingImageUrl!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 50),
                              ),
                            )
                          : Container(
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).colorScheme.outline),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Text(
                                  'Tidak ada gambar',
                                  style: GoogleFonts.lato(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                ),
                              ),
                            ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                    label: const Text('Ubah Gambar'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (mounted) {
                                setState(() {
                                  _isLoading = true;
                                });
                              }

                              try {
                                String? imageUrl = _existingImageUrl;
                                if (_imageFile != null) {
                                  final response = await _cloudinaryService
                                      .uploadImage(_imageFile!);
                                  imageUrl = response.secureUrl;
                                }

                                final updatedProduct = Product(
                                  id: widget.productId,
                                  name: _nameController.text,
                                  price: double.parse(_priceController.text),
                                  stock: int.parse(_stockController.text),
                                  imageUrl: imageUrl,
                                );

                                await _productService.updateProduct(
                                    widget.productId, updatedProduct);
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Produk berhasil diperbarui!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  // ignore: use_build_context_synchronously
                                  context.pop();
                                }
                              } catch (e) {
                                if (mounted) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
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
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Simpan Perubahan'),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
