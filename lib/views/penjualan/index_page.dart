import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/sale.dart';
import 'package:myapp/routes/app_router.dart';
import 'package:myapp/services/sale_service.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mempersiapkan file Excel...')),
    );

    final sales = await _saleService.getSalesForExport(
      startDate: _startDate,
      endDate: _endDate,
    );

    if (sales.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tidak ada data untuk diekspor.'),
              backgroundColor: Colors.orange),
        );
      }
      return;
    }

    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet()!];

    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final headerTexts = [
      'Tanggal Transaksi',
      'Nama Produk',
      'Harga Satuan',
      'Jumlah Terjual',
      'Total Harga',
    ];

    sheet.appendRow(headerTexts.map((text) => TextCellValue(text)).toList());

    for (var i = 0; i < headerTexts.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .cellStyle = headerStyle;
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateTimeFormatter = DateFormat('dd MMM yyyy, HH:mm');
    num totalQuantity = 0;
    num totalRevenue = 0;

    for (final sale in sales) {
      sheet.appendRow([
        TextCellValue(dateTimeFormatter.format(sale.createdAt.toDate())),
        TextCellValue(sale.name),
        TextCellValue(currencyFormatter.format(sale.price)),
        IntCellValue(sale.quantity),
        IntCellValue(sale.total.toInt()),
      ]);
      totalQuantity += sale.quantity;
      totalRevenue += sale.total;
    }

    sheet.appendRow([]);

    final totalLabelStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Right,
    );
    final totalValueStyle = CellStyle(bold: true);
    final currencyFormatForTotal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    int rowIndex = sheet.maxRows;
    sheet.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('Total Kuantitas:'),
      IntCellValue(totalQuantity.toInt()),
    ]);
    sheet
        .cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
        )
        .cellStyle = totalLabelStyle;
    sheet
        .cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
        )
        .cellStyle = totalValueStyle;

    rowIndex = sheet.maxRows;
    sheet.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('Total Pendapatan:'),
      TextCellValue(currencyFormatForTotal.format(totalRevenue)),
    ]);
    sheet
        .cell(
          CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
        )
        .cellStyle = totalLabelStyle;
    sheet
        .cell(
          CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
        )
        .cellStyle = totalValueStyle;

    final fileBytes = excel.encode();
    if (fileBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal membuat file Excel.'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);
      final fileName = 'Laporan_Penjualan_$formattedDate.xlsx';

      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(fileBytes),
        mimeType: MimeType.microsoftExcel,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil diunduh! Silakan cek folder Downloads Anda.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                      child: CircularProgressIndicator.adaptive());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada data penjualan.',
                      style: GoogleFonts.lato(
                          fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }
                final sales = snapshot.data!;
                return ListView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 88.0), // Padding di bawah
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
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateTimeFormatter.format(sale.createdAt.toDate()),
                              style: GoogleFonts.lato(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic),
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
          _buildDatePickerField(dateFormatter, 'Mulai', _startDate,
              (date) => setState(() => _startDate = date)),
          _buildDatePickerField(dateFormatter, 'Akhir', _endDate,
              (date) => setState(() => _endDate = date)),
          ElevatedButton.icon(
            onPressed: _applyFilter,
            icon: const Icon(Icons.filter_list, size: 20),
            label: const Text('Filter'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _exportToExcel,
            icon: const Icon(Icons.download_outlined, size: 20),
            label: const Text('Unduh'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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

  Widget _buildDatePickerField(DateFormat formatter, String label, DateTime? date,
      Function(DateTime) onDateChanged) {
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon:
                  const Icon(Icons.calendar_today_outlined, size: 20)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
              child: Text('Hapus', style: TextStyle(color: Colors.red.shade600)),
            ),
          ],
        );
      },
    );
  }
}
