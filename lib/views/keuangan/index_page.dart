import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/daily_income_summary.dart';
import 'package:myapp/models/financial_event.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/services/financial_service.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/routes/app_router.dart';
import 'dart:async';

class FinancialDashboardPage extends StatefulWidget {
  const FinancialDashboardPage({super.key});

  @override
  State<FinancialDashboardPage> createState() => _FinancialDashboardPageState();
}

class _FinancialDashboardPageState extends State<FinancialDashboardPage> {
  final FinancialService _financialService = FinancialService();
  late final Stream<List<FinancialEvent>> _combinedStream;

  @override
  void initState() {
    super.initState();
    _combinedStream = _createCombinedStream();
  }

  Stream<List<FinancialEvent>> _createCombinedStream() {
    Stream<List<DailyIncomeSummary>> incomeStream =
        _financialService.getDailyIncomeSummaries();
    Stream<List<FinancialRecord>> expenseStream =
        _financialService.getFinancialRecords();

    return StreamZip([incomeStream, expenseStream]).map((streams) {
      final incomes = streams[0] as List<DailyIncomeSummary>;
      final expenses = streams[1] as List<FinancialRecord>;

      final List<FinancialEvent> combinedList = [...incomes, ...expenses];

      combinedList.sort((a, b) => b.date.compareTo(a.date));

      return combinedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<FinancialEvent>>(
        stream: _combinedStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}\nSilakan coba lagi nanti.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Belum ada data keuangan.',
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          final events = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              if (event is DailyIncomeSummary) {
                return _buildIncomeCard(context, event);
              } else if (event is FinancialRecord) {
                return _buildExpenseCard(context, event);
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.keuanganCreate);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Tambah Pengeluaran',
            style: GoogleFonts.poppins(color: Colors.white)),
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
    final dateFormatter = DateFormat('EEEE, d MMMM y', 'id_ID');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showExpenseDetailsDialog(context, record),
        borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(record.cost),
                style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.red[700]),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  dateFormatter.format(record.date),
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

  void _showIncomeDetailsDialog(
      BuildContext context, DailyIncomeSummary summary) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('d MMMM y', 'id_ID');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
      ),
    );
  }

  void _showExpenseDetailsDialog(BuildContext context, FinancialRecord record) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormatter = DateFormat('EEEE, d MMMM y', 'id_ID');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        title: Text(record.title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _buildDetailRow('Jumlah:', currencyFormatter.format(record.cost)),
              if (record.description.isNotEmpty)
                _buildDetailRow('Deskripsi:', record.description),
              _buildDetailRow('Tanggal:', dateFormatter.format(record.date)),
              const SizedBox(height: 15),
              if (record.notaImg != null && record.notaImg!.isNotEmpty)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Lihat Nota'),
                    onPressed: () {
                      Navigator.of(ctx).pop(); // Close this dialog first
                      _showImageDialog(context,
                          record.notaImg!); // Then open the image dialog
                    },
                  ),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueGrey),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('${AppRoutes.keuanganUpdate}/${record.id}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmDelete(context, record.id);
            },
          ),
          const Spacer(),
          TextButton(
              child: const Text('Tutup'),
              onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
                text: '$title ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/logo_aplikasi.png',
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                      onPressed: () => Navigator.of(context).pop(),
                    ))
              ],
            ),
          );
        });
  }

  void _confirmDelete(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
              'Apakah Anda yakin ingin menghapus catatan pengeluaran ini?'),
          actions: <Widget>[
            TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.of(ctx).pop()),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _financialService.deleteFinancialRecord(recordId);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }
}