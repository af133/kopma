import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/services/cloudinary_service.dart';
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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  DateTime? _selectedDate;
  XFile? _imageFile;
  bool _isUploading = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('id', 'ID'),
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
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  hintText: 'Contoh: Beli Peralatan Kebersihan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Contoh: Sapu, pel, dan ember',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Biaya (Rp)',
                  hintText: 'Contoh: 50000',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Biaya tidak boleh kosong.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(8.0),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Pengeluaran',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isUploading ? null : _saveRecord,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Pengeluaran'),
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
        Text(
          'Foto Nota (Opsional)',
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
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
                    child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo_aplikasi.png',
                          height: 80,
                          width: 80,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        const Text('Ketuk untuk memilih gambar',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = (await _cloudinaryService.uploadImage(_imageFile!)) as String?;
      }

      final cost = double.parse(_costController.text);
      final newRecord = FinancialRecord(
        id: '', 
        title: _titleController.text,
        description: _descriptionController.text,
        cost: cost,
        date: _selectedDate ??
            DateTime.now(), 
        notaImg: imageUrl,
      );

      await FinancialService().createFinancialRecord(newRecord);

      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        context.pop();
      }
    }
  }
}
