import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/services/financial_service.dart';
import 'package:myapp/widgets/custom_app_bar.dart';

class FinancialRecordUpdatePage extends StatefulWidget {
  final String recordId;

  const FinancialRecordUpdatePage({super.key, required this.recordId});

  @override
  FinancialRecordUpdatePageState createState() =>
      FinancialRecordUpdatePageState();
}

class FinancialRecordUpdatePageState extends State<FinancialRecordUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = true;
  late FinancialRecord _record;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    try {
      final record = await FinancialService().getFinancialRecord(widget.recordId);
      if (mounted) {
        setState(() {
          _record = record;
          _descriptionController.text = record.description;
          // Convert negative amount to positive for display
          _amountController.text = record.amount.abs().toStringAsFixed(0);
          _selectedDate = record.date;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error, e.g., show a snackbar or navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data pengeluaran.')),
        );
        context.pop();
      }
    }
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
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(title: 'Perbarui Pengeluaran'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Pengeluaran',
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
                          if (!mounted) return;
                          final amount = double.parse(_amountController.text);

                          FinancialService().updateFinancialRecord(
                            FinancialRecord(
                              id: widget.recordId,
                              description: _descriptionController.text,
                              amount: -amount, // Simpan sebagai nilai negatif
                              type: 'expense', // Tetap sebagai 'expense'
                              date: _selectedDate ?? _record.date,
                              createdAt: _record.createdAt,
                            ),
                          );
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: GoogleFonts.lato(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
