import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _quantityController = TextEditingController();
  late Sale _sale;
  int _oldQuantity = 0;

  @override
  void initState() {
    super.initState();
    SaleService().getSale(widget.saleId).then((sale) {
      setState(() {
        _sale = sale;
        _oldQuantity = sale.quantity;
        _quantityController.text = sale.quantity.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(title: 'Perbarui Penjualan'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newQuantity = int.parse(_quantityController.text);
                    final newTotal = _sale.price * newQuantity;
                    final updatedSale = Sale(
                      id: _sale.id,
                      name: _sale.name,
                      price: _sale.price,
                      quantity: newQuantity,
                      total: newTotal,
                      createdAt: _sale.createdAt,
                      productId: _sale.productId,
                    );
                    SaleService().updateSale(updatedSale, _oldQuantity);
                    context.pop();
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
