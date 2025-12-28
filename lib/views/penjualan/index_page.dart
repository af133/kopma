import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/sale.dart';
import 'package:myapp/routes/app_router.dart';
import 'package:myapp/services/sale_service.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

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
    final sales = await _saleService.getSalesForExport(
      startDate: _startDate,
      endDate: _endDate,
    );

    if (sales.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data untuk diekspor.')),
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
              .cellStyle =
          headerStyle;
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

    // --- PERBAIKAN DI SINI ---
    // Add Total Quantity row and apply style
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
            .cellStyle =
        totalLabelStyle;
    sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
            )
            .cellStyle =
        totalValueStyle;

    // Add Total Revenue row and apply style
    rowIndex = sheet.maxRows; // Update rowIndex to the next new row
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
            .cellStyle =
        totalLabelStyle;
    sheet
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
            )
            .cellStyle =
        totalValueStyle;

    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/Laporan_Penjualan.xlsx';

    final file = File(path);
    await file.writeAsBytes(excel.encode()!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Laporan berhasil diekspor ke $path'),
          action: SnackBarAction(
            label: 'Buka',
            onPressed: () => OpenFile.open(path),
          ),
        ),
      );
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
        title: const Text('Daftar Penjualan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _exportToExcel,
            tooltip: 'Unduh Excel',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(dateFormatter),
          Expanded(
            child: StreamBuilder<List<Sale>>(
              stream: _salesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada penjualan pada rentang tanggal ini.',
                      style: GoogleFonts.lato(),
                    ),
                  );
                }
                final sales = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
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
                            const SizedBox(height: 4),
                            Text(
                              '${sale.quantity} item | Total: ${currencyFormatter.format(sale.total)}',
                              style: GoogleFonts.lato(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateTimeFormatter.format(sale.createdAt.toDate()),
                              style: GoogleFonts.lato(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue[700],
                                size: 22,
                              ),
                              onPressed: () => context.push(
                                '${AppRoutes.penjualanUpdate}/${sale.id}',
                              ),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red[700],
                                size: 22,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _startDate = pickedDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Mulai',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      _startDate != null
                          ? dateFormatter.format(_startDate!)
                          : 'Pilih tanggal',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: _startDate ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _endDate = pickedDate;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Akhir',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      _endDate != null
                          ? dateFormatter.format(_endDate!)
                          : 'Pilih tanggal',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _applyFilter,
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _resetFilter,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String saleId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
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
                } catch (e) {
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menghapus: $e")),
                  );
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
