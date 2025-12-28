import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _type = 'income';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  late FinancialRecord _record;

  @override
  void initState() {
    super.initState();
    FinancialService().getFinancialRecord(widget.recordId).then((record) {
      _descriptionController.text = record.description;
      _amountController.text = record.amount.toString();
      if (mounted) {
        setState(() {
          _record = record;
          _type = record.type;
          _selectedDate = record.date;
          _isLoading = false;
        });
      }
    });
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
      appBar: const CustomAppBar(title: 'Perbarui Catatan Keuangan'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        labelStyle: GoogleFonts.lato(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan deskripsi';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _amountController,
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
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: InputDecoration(
                        labelText: 'Jenis',
                        labelStyle: GoogleFonts.lato(),
                      ),
                      items: ['income', 'expense']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _type = value!;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: const Text('Pilih Tanggal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                           if (!mounted) return;
                          FinancialService().updateFinancialRecord(
                            FinancialRecord(
                              id: widget.recordId,
                              description: _descriptionController.text,
                              amount: double.parse(_amountController.text),
                              type: _type,
                              date: _selectedDate,
                              createdAt: _record.createdAt, // Keep original creation date
                            ),
                          );
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
