import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now(),
      end: _endDate ?? DateTime.now(),
    );
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: initialDateRange,
    );

    if (newDateRange != null) {
      setState(() {
        _startDate = newDateRange.start;
        _endDate = newDateRange.end;
      });
    }
  }

  Future<void> _exportToExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Sales'];

    // Add header row
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Product Name'),
      TextCellValue('Price'),
      TextCellValue('Quantity'),
      TextCellValue('Total')
    ]);

    Query query = FirebaseFirestore.instance.collection('sales');

    if (_startDate != null && _endDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: _startDate)
                   .where('date', isLessThanOrEqualTo: _endDate);
    }

    final sales = await query.get();

    for (final sale in sales.docs) {
      final data = sale.data() as Map<String, dynamic>;
      sheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate())),
        TextCellValue(data['productName']),
        DoubleCellValue(data['price']),
        IntCellValue(data['quantity']),
        DoubleCellValue(data['total'])
      ]);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/sales.xlsx');
    await file.writeAsBytes(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel file saved to ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: const Text('Filter by Date'),
                ),
                if (_startDate != null && _endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: () {
                Query query = FirebaseFirestore.instance.collection('sales');
                if (_startDate != null && _endDate != null) {
                  query = query
                      .where('date', isGreaterThanOrEqualTo: _startDate)
                      .where('date', isLessThanOrEqualTo: _endDate);
                }
                return query.snapshots();
              }(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['productName']),
                      subtitle: Text(
                          '${DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate())} - Qty: ${data['quantity']}'),
                      trailing: Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')
                            .format(data['total']),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/penjualan/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}