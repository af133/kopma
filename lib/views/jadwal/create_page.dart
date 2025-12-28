import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/services/schedule_service.dart';
import 'package:myapp/widgets/custom_app_bar.dart';

class ScheduleCreatePage extends StatefulWidget {
  const ScheduleCreatePage({super.key});

  @override
  ScheduleCreatePageState createState() => ScheduleCreatePageState();
}

class ScheduleCreatePageState extends State<ScheduleCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _dayController = TextEditingController();
  final List<TextEditingController> _nameControllers = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(title: 'Buat Jadwal'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _dayController,
                decoration: InputDecoration(
                  labelText: 'Hari',
                  labelStyle: GoogleFonts.lato(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan hari';
                  }
                  return null;
                },
              ),
              ..._nameControllers.map((controller) {
                return TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    labelStyle: GoogleFonts.lato(),
                  ),
                );
              }),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _nameControllers.add(TextEditingController());
                  });
                },
                child: const Text('Tambah Nama'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScheduleService().addSchedule(
                      _dayController.text,
                      _nameControllers
                          .map((controller) => controller.text)
                          .toList(),
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
