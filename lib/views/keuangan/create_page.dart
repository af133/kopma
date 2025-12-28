import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/providers/financial_provider.dart';
import 'package:myapp/services/cloudinary_service.dart';
import 'package:myapp/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class FinancialRecordCreatePage extends StatefulWidget {
  const FinancialRecordCreatePage({super.key});

  @override
  State<FinancialRecordCreatePage> createState() =>
      FinancialRecordCreatePageState();
}

class FinancialRecordCreatePageState
    extends State<FinancialRecordCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  XFile? _imageFile;
  bool _isSaving = false;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateController.text =
        DateFormat('EEEE, d MMMM y', 'id_ID').format(_selectedDate!);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  Future<void> _pickDate() async {
    if (!mounted) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            DateFormat('EEEE, d MMMM y', 'id_ID').format(picked);
      });
    }
  }

  // REFACTORED: Properly handles BuildContext across async gaps
  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Capture context-dependent variables BEFORE the async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = GoRouter.of(context);
    final financialProvider = Provider.of<FinancialProvider>(context, listen: false);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        CloudinaryResponse response = await _cloudinaryService.uploadImage(_imageFile!);
        imageUrl = response.secureUrl;
      }

      final newRecord = FinancialRecord(
        id: '',
        title: _titleController.text,
        description: _descriptionController.text,
        cost: double.parse(_costController.text),
        date: _selectedDate ?? DateTime.now(),
        notaImg: imageUrl,
      );
      
      await financialProvider.createFinancialRecord(newRecord);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Pengeluaran berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop();
      
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(title: 'Catat Pengeluaran'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Formulir Pengeluaran',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Judul wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Biaya',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Biaya wajib diisi';
                  if (double.tryParse(v) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Pengeluaran',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Tanggal wajib dipilih' : null,
              ),

              const SizedBox(height: 16),

              _buildImagePicker(),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _isSaving ? null : _saveRecord,
        child: _isSaving
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Icon(Icons.save),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Nota (Opsional)',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: Colors.grey, size: 50),
                        SizedBox(height: 8),
                        Text('Ketuk untuk memilih gambar',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
