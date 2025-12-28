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

class FinancialRecordUpdatePage extends StatefulWidget {
  final String recordId;

  const FinancialRecordUpdatePage({super.key, required this.recordId});

  @override
  FinancialRecordUpdatePageState createState() =>
      FinancialRecordUpdatePageState();
}

class FinancialRecordUpdatePageState extends State<FinancialRecordUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = true;
  XFile? _imageFile;
  String? _existingImageUrl;
  bool _isUploading = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();

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
          _titleController.text = record.title;
          _descriptionController.text = record.description;
          _costController.text = record.cost.toStringAsFixed(0);
          _selectedDate = record.date; // record.date sudah menjadi DateTime
          _existingImageUrl = record.notaImg;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data pengeluaran.')),
        );
        context.pop();
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
      if (image != null) {
        _existingImageUrl = null;
      }
    });
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _existingImageUrl = null;
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
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
                      controller: _titleController,
                      decoration: const InputDecoration(
                          labelText: 'Judul', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Judul tidak boleh kosong.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                          labelText: 'Deskripsi', border: OutlineInputBorder()),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Deskripsi tidak boleh kosong.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _costController,
                      decoration: const InputDecoration(
                          labelText: 'Biaya (Rp)',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp '),
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
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
                      onPressed: _isUploading ? null : _updateRecord,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: GoogleFonts.lato(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
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
        Text('Foto Nota', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: _pickImage,
            child: (_imageFile == null && _existingImageUrl == null)
                ? const Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
                    Text('Tambah Gambar Nota', style: TextStyle(color: Colors.grey))
                  ]))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _imageFile != null
                        ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                        : Image.network(_existingImageUrl!, fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                            return progress == null
                                ? child
                                : const Center(
                                    child: CircularProgressIndicator());
                          }),
                  ),
          ),
        ),
        if (_imageFile != null || _existingImageUrl != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                  icon: const Icon(Icons.image_search),
                  label: const Text('Ganti Gambar'),
                  onPressed: _pickImage),
              TextButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Hapus Gambar', style: TextStyle(color: Colors.red)),
                  onPressed: _removeImage),
            ],
          )
      ],
    );
  }

  Future<void> _updateRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) {
        // Perbaikan: uploadImage sekarang menerima XFile secara langsung
        imageUrl = (await _cloudinaryService.uploadImage(_imageFile!)) as String?;
      } else if (_existingImageUrl == null) {
        imageUrl = null; 
      }

      final cost = double.parse(_costController.text);
      
      // Perbaikan: Pastikan _selectedDate (sebuah DateTime) yang diteruskan
      final updatedRecord = FinancialRecord(
        id: widget.recordId,
        title: _titleController.text,
        description: _descriptionController.text,
        cost: cost,
        date: _selectedDate ?? DateTime.now(), // Ini sudah benar, meneruskan DateTime
        notaImg: imageUrl,
      );

      await FinancialService().updateFinancialRecord(updatedRecord);

      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil diperbarui!')));
        context.pop();
      }
    }
  }
}
