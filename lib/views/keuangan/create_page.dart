import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/services/financial_service.dart';
import 'package:myapp/widgets/custom_app_bar.dart';

class FinancialRecordCreatePage extends StatefulWidget {
  const FinancialRecordCreatePage({super.key});

  @override
  FinancialRecordCreatePageState createState() =>
      FinancialRecordCreatePageState();
}

class FinancialRecordCreatePageState extends State<FinancialRecordCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(title: 'Catat Pengeluaran'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Formulir Pengeluaran',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Judul Pengeluaran',
                  hintText: 'Contoh: Beli sapu ijuk',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul pengeluaran tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Pengeluaran (Rp)',
                  hintText: 'Contoh: 25000',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah pengeluaran tidak boleh kosong.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(8.0),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Pengeluaran',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        _selectedDate == null
                            ? 'Pilih Tanggal'
                            : DateFormat('EEEE, d MMMM y', 'id_ID')
                                .format(_selectedDate!),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final amount = double.parse(_amountController.text);
                    FinancialService().createFinancialRecord(
                      FinancialRecord(
                        id: '', 
                        type: 'expense', // Otomatis sebagai 'expense'
                        amount: -amount, // Simpan sebagai nilai negatif
                        description: _descriptionController.text,
                        date: _selectedDate ?? DateTime.now(),
                        createdAt: Timestamp.now(),
                      ),
                    );
                    context.pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text('Simpan Pengeluaran'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
