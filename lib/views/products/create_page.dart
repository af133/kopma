import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/cloudinary_service.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/widgets/custom_app_bar.dart';
import 'package:uuid/uuid.dart';

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key});

  @override
  ProductCreatePageState createState() => ProductCreatePageState();
}

class ProductCreatePageState extends State<ProductCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _isLoading = false;

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
      appBar: const CustomAppBar(title: 'Tambah Produk'),
      body: Padding(
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
              _imageFile == null
                  ? Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.outline),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          'Belum ada gambar dipilih',
                          style: GoogleFonts.lato(
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        File(_imageFile!.path),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                onPressed: _pickImage,
                label: const Text('Pilih Gambar'),
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
                          if (_imageFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan pilih gambar.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          if(mounted) {
                            setState(() {
                              _isLoading = true;
                            });
                          }

                          try {
                            final response =
                                await _cloudinaryService.uploadImage(_imageFile!);
                            final imageUrl = response.secureUrl;

                            final newProduct = Product(
                              id: const Uuid().v4(),
                              name: _nameController.text,
                              price: double.parse(_priceController.text),
                              stock: int.parse(_stockController.text),
                              imageUrl: imageUrl,
                            );

                            await ProductService().createProduct(newProduct);
                            
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Produk berhasil ditambahkan!'),
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
                            if(mounted) {
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
                      child: const Text('Simpan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
