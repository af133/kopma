import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _manualPriceController = TextEditingController();

  Product? _selectedProduct;
  bool _showManualEntry = false;

  // Dummy product for the "Lainnya" option
  final Product _otherProduct = Product(
    id: 'other',
    name: 'Lainnya',
    price: 0,
    stock: 0,
    imageUrl: '',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Buat Penjualan'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              StreamBuilder<List<Product>>(
                stream: ProductService().getProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final products = snapshot.data!;
                  // Add the "Lainnya" option to the list
                  final items = [ ...products, _otherProduct ];

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
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Produk',
                      labelStyle: GoogleFonts.lato(),
                    ),
                  );
                },
              ),
              if (_showManualEntry)
                Column(
                  children: [
                    TextFormField(
                      controller: _manualNameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Produk Manual',
                        labelStyle: GoogleFonts.lato(),
                      ),
                      validator: (value) {
                        if (_showManualEntry && (value == null || value.isEmpty)) {
                          return 'Masukkan nama produk';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _manualPriceController,
                      decoration: InputDecoration(
                        labelText: 'Harga Produk Manual',
                        labelStyle: GoogleFonts.lato(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (_showManualEntry && (value == null || value.isEmpty)) {
                          return 'Masukkan harga produk';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  labelStyle: GoogleFonts.lato(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah';
                  }
                  if(int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Jumlah tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSale,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSale() {
    if (_formKey.currentState!.validate() && (_selectedProduct != null)) {
      final int quantity = int.parse(_quantityController.text);
      late Sale saleToCreate;

      if (_showManualEntry) {
        final int manualPrice = int.parse(_manualPriceController.text);
        saleToCreate = Sale(
          id: '', // Firestore will generate it
          name: _manualNameController.text,
          price: manualPrice,
          quantity: quantity,
          total: manualPrice * quantity,
          createdAt: Timestamp.now(),
          // productId is null for manual entries
        );
      } else {
        saleToCreate = Sale(
          id: '', // Firestore will generate it
          name: _selectedProduct!.name,
          price: _selectedProduct!.price.toInt(),
          quantity: quantity,
          total: (_selectedProduct!.price * quantity).toInt(),
          createdAt: Timestamp.now(),
          productId: _selectedProduct!.id,
        );
      }

      SaleService().createSale(saleToCreate).then((_) {
        // ignore: use_build_context_synchronously
        context.pop();
      }).catchError((error) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan penjualan: $error')),
        );
      });
    }
  }
}
