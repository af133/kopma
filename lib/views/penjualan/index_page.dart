import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models/sale.dart';
import 'package:myapp/routes/app_router.dart';
import 'package:myapp/services/sale_service.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/widgets/custom_app_bar.dart';

class SaleListPage extends StatelessWidget {
  const SaleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const CustomAppBar(title: 'Penjualan'),
      body: StreamBuilder<List<Sale>>(
        stream: SaleService().getSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('Tidak ada penjualan.', style: GoogleFonts.lato()));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Sale sale = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(sale.name, style: GoogleFonts.poppins()),
                  subtitle: Text(
                      'Jumlah: ${sale.quantity} - Total: ${sale.total}', style: GoogleFonts.lato()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          context.push('${AppRoutes.penjualanUpdate}/${sale.id}');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          SaleService().deleteSale(sale.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.penjualanCreate);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
