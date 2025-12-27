import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProduct;
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  double _total = 0.0;

  List<DropdownMenuItem<String>> _productItems = [];
  bool _isOther = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _quantityController.addListener(_calculateTotal);
    _priceController.addListener(_calculateTotal);
  }

  Future<void> _loadProducts() async {
    final products = await FirebaseFirestore.instance.collection('products').get();
    final items = products.docs.map((doc) {
      return DropdownMenuItem(
        value: doc.id,
        child: Text(doc['name']),
      );
    }).toList();

    setState(() {
      _productItems = items;
      _productItems.add(const DropdownMenuItem(
        value: 'other',
        child: Text('Lainnya'),
      ));
    });
  }

  void _onProductSelected(String? newValue) {
    if (newValue == 'other') {
      setState(() {
        _isOther = true;
        _selectedProduct = newValue;
        _productNameController.clear();
        _priceController.clear();
      });
    } else {
      FirebaseFirestore.instance
          .collection('products')
          .doc(newValue)
          .get()
          .then((doc) {
        setState(() {
          _isOther = false;
          _selectedProduct = newValue;
          _productNameController.text = doc['name'];
          _priceController.text = doc['price'].toString();
          _calculateTotal();
        });
      });
    }
  }

  void _calculateTotal() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _total = price * quantity;
    });
  }

  Future<void> _saveSale() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('sales').add({
        'productName': _productNameController.text,
        'price': double.parse(_priceController.text),
        'quantity': int.parse(_quantityController.text),
        'total': _total,
        'date': Timestamp.now(),
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedProduct,
                items: _productItems,
                onChanged: _onProductSelected,
                decoration: const InputDecoration(labelText: 'Product'),
                validator: (value) => value == null ? 'Please select a product' : null,
              ),
              if (_isOther)
                TextFormField(
                  controller: _productNameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a product name' : null,
                ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                readOnly: !_isOther,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a price' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a quantity' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(_total)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveSale,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
