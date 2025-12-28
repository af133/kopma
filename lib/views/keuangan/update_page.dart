import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:myapp/models/financial_record.dart';
import 'package:myapp/services/cloudinary_service.dart';
import 'package:myapp/services/financial_service.dart';
import 'package:myapp/widgets/custom_app_bar.dart';

class FinancialRecordUpdatePage extends StatefulWidget {
  final String recordId;

  const FinancialRecordUpdatePage({super.key, required this.recordId});

  @override
  State<FinancialRecordUpdatePage> createState() =>
      FinancialRecordUpdatePageState();
}

class FinancialRecordUpdatePageState
    extends State<FinancialRecordUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool _isLoading = true;
  bool _isSaving = false;

  XFile? _imageFile;
  String? _existingImageUrl;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  // ================= LOAD DATA =================
  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  Future<void> _loadRecord() async {
    try {
      final record =
          await FinancialService().getFinancialRecord(widget.recordId);

      _titleController.text = record.title;
      _descriptionController.text = record.description;
      _costController.text = record.cost.toStringAsFixed(0);
      _selectedDate = record.date;
      _existingImageUrl = record.notaImg;

      _dateController.text =
          DateFormat('EEEE, d MMMM y', 'id_ID').format(record.date);

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data pengeluaran')),
      );
      context.pop();
    }
  }

  // ================= DATE PICKER =================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
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

  // ================= IMAGE =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = image;
        _existingImageUrl = null;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _existingImageUrl = null;
    });
  }

  // ================= UPDATE =================
  Future<void> _updateRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? imageUrl = _existingImageUrl;

      if (_imageFile != null) {
        imageUrl = (await _cloudinaryService.uploadImage(_imageFile!)) as String?;
      }

      final updatedRecord = FinancialRecord(
        id: widget.recordId,
        title: _titleController.text,
        description: _descriptionController.text,
        cost: double.parse(_costController.text),
        date: _selectedDate ?? DateTime.now(),
        notaImg: imageUrl,
      );

      await FinancialService().updateFinancialRecord(updatedRecord);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengeluaran berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ================= CLEAN =================
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Perbarui Pengeluaran'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
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
                          return 'Masukkan angka valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ===== TANGGAL FIX =====
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
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isSaving ? null : _updateRecord,
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text('Simpan Perubahan'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto Nota'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _imageFile != null
                ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                : _existingImageUrl != null
                    ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                    : const Center(child: Text('Ketuk untuk memilih gambar')),
          ),
        ),
        if (_imageFile != null || _existingImageUrl != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Ganti'),
                onPressed: _pickImage,
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Hapus',
                    style: TextStyle(color: Colors.red)),
                onPressed: _removeImage,
              ),
            ],
          ),
      ],
    );
  }
}
