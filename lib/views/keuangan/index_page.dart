import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/daily_income_summary.dart';
import 'package:myapp/models/financial_event.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/providers/financial_provider.dart';
import 'package:myapp/services/financial_service.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/routes/app_router.dart';
import 'package:provider/provider.dart';

class FinancialDashboardPage extends StatefulWidget {
  const FinancialDashboardPage({super.key});

  @override
  State<FinancialDashboardPage> createState() => _FinancialDashboardPageState();
}

class _FinancialDashboardPageState extends State<FinancialDashboardPage> {
  final FinancialService _financialService = FinancialService();
  late final Stream<List<DailyIncomeSummary>> _incomeStream;

  @override
  void initState() {
    super.initState();
    _incomeStream = _financialService.getDailyIncomeSummaries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) { 
        _refreshData(context);
       }
    });
  }

  Future<void> _refreshData(BuildContext context) async {
    final provider = Provider.of<FinancialProvider>(context, listen: false);
    await provider.fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context),
        child: Consumer<FinancialProvider>(
          builder: (context, financialProvider, child) {
            return StreamBuilder<List<DailyIncomeSummary>>(
              stream: _incomeStream,
              builder: (context, incomeSnapshot) {
                if (financialProvider.isLoading && !incomeSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }

                if (financialProvider.errorMessage != null) {
                  return Center(child: Text('Error Provider: ${financialProvider.errorMessage}'));
                }
                if (incomeSnapshot.hasError) {
                  return Center(child: Text('Error Stream: ${incomeSnapshot.error}'));
                }

                final expenses = financialProvider.records;
                final incomes = incomeSnapshot.data ?? [];

                if (expenses.isEmpty && incomes.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada data keuangan.',
                      style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                final List<FinancialEvent> combinedList = [...incomes, ...expenses];
                combinedList.sort((a, b) => b.date.compareTo(a.date));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: combinedList.length,
                  itemBuilder: (context, index) {
                    final event = combinedList[index];
                    if (event is DailyIncomeSummary) {
                      return _buildIncomeCard(context, event);
                    } else if (event is FinancialRecord) {
                      return _buildExpenseCard(context, event);
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.keuanganCreate),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildIncomeCard(BuildContext context, DailyIncomeSummary summary) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('EEEE, d MMMM y', 'id_ID');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showIncomeDetailsDialog(context, summary),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pemasukan',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800]),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(summary.totalIncome),
                style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.green[700]),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  dateFormatter.format(summary.date),
                  style: GoogleFonts.lato(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, FinancialRecord record) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.title,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800]),
              overflow: TextOverflow.ellipsis,
            ),
            if (record.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                record.description,
                style: GoogleFonts.lato(color: Colors.black87, fontSize: 14),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              currencyFormatter.format(record.cost),
              style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.red[700]),
            ),
            if (record.notaImg != null && record.notaImg!.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showImageDialog(context, record.notaImg!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    record.notaImg!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                  tooltip: 'Edit',
                  onPressed: () {
                    context.push('${AppRoutes.keuanganUpdate}/${record.id}');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: 'Hapus',
                  onPressed: () {
                    _confirmDelete(context, record.id);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showIncomeDetailsDialog(
      BuildContext context, DailyIncomeSummary summary) {
    showDialog(
      context: context,
      builder: (ctx) {
          final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('d MMMM y', 'id_ID');

       return AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        title: Text('Detail Pemasukan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateFormatter.format(summary.date),
                  style: GoogleFonts.lato(
                      fontStyle: FontStyle.italic, color: Colors.grey[600])),
              const Divider(thickness: 1, height: 20),
              DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(
                      label: Text('Produk',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Jml',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true),
                  DataColumn(
                      label: Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      numeric: true),
                ],
                rows: summary.products
                    .map((p) => DataRow(
                          cells: [
                            DataCell(Text(p.productName)),
                            DataCell(Text(p.quantity.toString())),
                            DataCell(
                                Text(currencyFormatter.format(p.totalRevenue))),
                          ],
                        ))
                    .toList(),
              ),
              const Divider(thickness: 1, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Pemasukan',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(currencyFormatter.format(summary.totalIncome),
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green[700])),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
              child: const Text('Tutup'),
              onPressed: () => Navigator.of(ctx).pop())
        ],
      );
      }
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog.fullscreen(
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0.85),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.8,
                maxScale: 5,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal memuat gambar',
                            style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 35),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 0, 0, 0.5)
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // REFACTORED: Properly handles BuildContext across async gaps
  void _confirmDelete(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        final navigator = Navigator.of(ctx);
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
              'Apakah Anda yakin ingin menghapus catatan pengeluaran ini?'),
          actions: <Widget>[
            TextButton(
                child: const Text('Batal'),
                onPressed: () => navigator.pop()),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                navigator.pop();
                
                final provider = Provider.of<FinancialProvider>(context, listen: false);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                try {
                  await provider.deleteFinancialRecord(recordId);

                  scaffoldMessenger.showSnackBar(const SnackBar(
                    content: Text('Pengeluaran berhasil dihapus.'),
                    backgroundColor: Colors.green,
                  ));
                } catch (error) {
                  scaffoldMessenger.showSnackBar(SnackBar(
                    content: Text('Gagal menghapus: $error'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
