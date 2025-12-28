import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/services/financial_service.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/routes/app_router.dart';

class FinancialRecordListPage extends StatelessWidget {
  const FinancialRecordListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FinancialRecord>>(
      stream: FinancialService().getFinancialRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text('Tidak ada catatan keuangan.',
                  style: GoogleFonts.lato()));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            FinancialRecord record = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(record.description, style: GoogleFonts.poppins()),
                subtitle: Text(
                    'Jumlah: ${record.amount} - Jenis: ${record.type}',
                    style: GoogleFonts.lato()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        context.push(
                            '${AppRoutes.keuanganUpdate}/${record.id}');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        FinancialService().deleteFinancialRecord(record.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
