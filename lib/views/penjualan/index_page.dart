import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/sale.dart';
import 'package:myapp/routes/app_router.dart';
import 'package:myapp/services/sale_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
class SaleListPage extends StatefulWidget {
  const SaleListPage({super.key});

  @override
  State<SaleListPage> createState() => _SaleListPageState();
}

class _SaleListPageState extends State<SaleListPage> {
  final SaleService _saleService = SaleService();
  Stream<List<Sale>>? _salesStream;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _salesStream = _saleService.getSales();
  }

  void _applyFilter() {
    setState(() {
      _salesStream = _saleService.getSales(
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  void _resetFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _salesStream = _saleService.getSales();
    });
  }

  Future<void> _exportToExcel() async {
  setState(() => _isExporting = true);

  try {
    final sales = await _saleService.getSalesForExport(
      startDate: _startDate,
      endDate: _endDate,
    );

    if (sales.isEmpty) {
      throw 'Tidak ada data untuk diekspor';
    }

    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];

    sheet.appendRow([
      TextCellValue('Tanggal'),
      TextCellValue('Produk'),
      TextCellValue('Harga'),
      TextCellValue('Jumlah'),
      TextCellValue('Total'),
    ]);

    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    for (final sale in sales) {
      sheet.appendRow([
        TextCellValue(dateFormat.format(sale.createdAt.toDate())),
        TextCellValue(sale.name),
        IntCellValue(sale.price.toInt()),
        IntCellValue(sale.quantity),
        IntCellValue(sale.total.toInt()),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) throw 'Gagal membuat file Excel';

    final directory = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();

    final fileName =
        'Laporan_Penjualan_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';

    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('File berhasil diunduh ke folder Download'),
        action: SnackBarAction(
          label: 'Buka',
          onPressed: () => OpenFilex.open(file.path),
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal export: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => _isExporting = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateTimeFormatter = DateFormat('dd MMM yyyy, HH:mm');
    final dateFormatter = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          _buildFilterSection(dateFormatter),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Sale>>(
              stream: _salesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data penjualan.',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }
                final sales = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    8.0,
                    8.0,
                    8.0,
                    88.0,
                  ), // Padding di bawah
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        title: Text(
                          sale.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              '${sale.quantity} item | Total: ${currencyFormatter.format(sale.total)}',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateTimeFormatter.format(sale.createdAt.toDate()),
                              style: GoogleFonts.lato(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_note_rounded,
                                color: Colors.blue.shade700,
                                size: 26,
                              ),
                              onPressed: () => context.push(
                                '${AppRoutes.penjualanUpdate}/${sale.id}',
                              ),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_sweep_rounded,
                                color: Colors.red.shade700,
                                size: 26,
                              ),
                              onPressed: () => _confirmDelete(context, sale.id),
                              tooltip: 'Hapus',
                            ),
                          ],
                        ),
                        onTap: () => context.push(
                          '${AppRoutes.penjualanUpdate}/${sale.id}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(DateFormat dateFormatter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildDatePickerField(
            dateFormatter,
            'Mulai',
            _startDate,
            (date) => setState(() => _startDate = date),
          ),
          _buildDatePickerField(
            dateFormatter,
            'Akhir',
            _endDate,
            (date) => setState(() => _endDate = date),
          ),
          ElevatedButton.icon(
            onPressed: _applyFilter,
            icon: const Icon(Icons.filter_list, size: 20),
            label: const Text('Filter'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _isExporting ? null : _exportToExcel,
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined, size: 20),
            label: Text(_isExporting ? 'Mengekspor...' : 'Unduh'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          IconButton(
            onPressed: _resetFilter,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Filter',
            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade200),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(
    DateFormat formatter,
    String label,
    DateTime? date,
    Function(DateTime) onDateChanged,
  ) {
    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            onDateChanged(pickedDate);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
          ),
          child: Text(
            date != null ? formatter.format(date) : 'Pilih Tanggal',
            style: GoogleFonts.lato(fontSize: 14),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String saleId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus penjualan ini? Stok produk terkait akan dikembalikan.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _saleService.deleteSale(saleId);
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Penjualan berhasil dihapus."),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Gagal menghapus: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Hapus',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
          ],
        );
      },
    );
  }
}
