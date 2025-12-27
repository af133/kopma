import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/withdrawal.dart';

class UpdatePage extends StatefulWidget {
  final Withdrawal withdrawal;

  const UpdatePage({super.key, required this.withdrawal});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  File? _image;
  final picker = ImagePicker();
  final cloudinary = CloudinaryPublic('YOUR_CLOUD_NAME', 'YOUR_UPLOAD_PRESET', cache: false);


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.withdrawal.title);
    _descriptionController = TextEditingController(text: widget.withdrawal.description);
    _amountController = TextEditingController(text: widget.withdrawal.amount.toString());
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _updateWithdrawal() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl = widget.withdrawal.notaImg;
      String? publicId = widget.withdrawal.publicId;

      if (_image != null) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_image!.path, resourceType: CloudinaryResourceType.Image),
        );
        imageUrl = response.secureUrl;
        publicId = response.publicId;
      }

      await FirebaseFirestore.instance
          .collection('withdrawals')
          .doc(widget.withdrawal.id)
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'amount': double.parse(_amountController.text),
        'nota_img': imageUrl,
        'publicId': publicId,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter an amount' : null,
              ),
              const SizedBox(height: 20),
              _image == null
                  ? (widget.withdrawal.notaImg != null
                      ? Image.network(widget.withdrawal.notaImg!)
                      : const Text('No image available.'))
                  : Image.file(_image!),
              ElevatedButton(
                onPressed: _getImage,
                child: const Text('Change Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateWithdrawal,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
