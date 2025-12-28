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
  String? _selectedDay;
  final List<TextEditingController> _nameControllers = [TextEditingController()];
  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNameField() {
    setState(() {
      _nameControllers.add(TextEditingController());
    });
  }

  void _removeNameField(TextEditingController controller) {
    setState(() {
      _nameControllers.remove(controller);
      controller.dispose();
    });
  }

  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      final names = _nameControllers
          .map((controller) => controller.text.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      if (_selectedDay != null && names.isNotEmpty) {
        await ScheduleService().addSchedule(_selectedDay!, names);
        if (mounted) {
          context.pop();
        }
      } else {
        // Show an error if day is not selected or no names are provided
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih hari dan masukkan setidaknya satu nama.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(title: 'Buat Jadwal'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedDay,
                decoration: InputDecoration(
                  labelText: 'Hari',
                  labelStyle: GoogleFonts.lato(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _days.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDay = newValue;
                  });
                },
                validator: (value) => value == null ? 'Pilih hari' : null,
              ),
              const SizedBox(height: 20),
              Text('Daftar Nama:', style: Theme.of(context).textTheme.titleMedium),
              ..._nameControllers.map((controller) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: 'Nama',
                            labelStyle: GoogleFonts.lato(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_nameControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removeNameField(controller),
                        ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _addNameField,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Nama'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSchedule,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Simpan Jadwal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
