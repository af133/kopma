import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:myapp/models/withdrawal.dart';

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
    final sheet = excel['Financials'];

    // Add header row
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Type'),
      TextCellValue('Title'),
      TextCellValue('Amount'),
    ]);

    // Get sales data
    Query salesQuery = FirebaseFirestore.instance.collection('sales');
    if (_startDate != null && _endDate != null) {
      salesQuery = salesQuery
          .where('date', isGreaterThanOrEqualTo: _startDate)
          .where('date', isLessThanOrEqualTo: _endDate);
    }
    final sales = await salesQuery.get();
    for (final sale in sales.docs) {
      final data = sale.data() as Map<String, dynamic>;
      sheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd').format((data['date'] as Timestamp).toDate())),
        TextCellValue('Income'),
        TextCellValue(data['productName']),
        DoubleCellValue(data['total']),
      ]);
    }

    // Get withdrawal data
    Query withdrawalsQuery = FirebaseFirestore.instance.collection('withdrawals');
    if (_startDate != null && _endDate != null) {
      withdrawalsQuery = withdrawalsQuery
          .where('createdAt', isGreaterThanOrEqualTo: _startDate)
          .where('createdAt', isLessThanOrEqualTo: _endDate);
    }
    final withdrawals = await withdrawalsQuery.get();
    for (final withdrawal in withdrawals.docs) {
      final data = withdrawal.data() as Map<String, dynamic>;
      sheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd').format((data['createdAt'] as Timestamp).toDate())),
        TextCellValue('Expense'),
        TextCellValue(data['title']),
        DoubleCellValue(data['amount']),
      ]);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/financials.xlsx');
    await file.writeAsBytes(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel file saved to ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financials'),
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
          _buildIncomeCard(),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildWithdrawalsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/keuangan/create');
        },
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildIncomeCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sales').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final sales = snapshot.data!.docs;
        final salesByDay = <DateTime, List<DocumentSnapshot>>{};

        for (final sale in sales) {
          final saleDate = (sale['date'] as Timestamp).toDate();
          final day = DateTime(saleDate.year, saleDate.month, saleDate.day);
          if (salesByDay[day] == null) {
            salesByDay[day] = [];
          }
          salesByDay[day]!.add(sale);
        }

        final today = DateTime.now();
        final todayDay = DateTime(today.year, today.month, today.day);
        final todaySales = salesByDay[todayDay] ?? [];
        final totalTodayIncome = todaySales.fold<double>(
            0.0, (sum, sale) => sum + (sale['total'] as double));

        return Card(
          child: ListTile(
            title: const Text('Pemasukan Hari Ini'),
            subtitle: Text(DateFormat('yyyy-MM-dd').format(today)),
            trailing: Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(totalTodayIncome),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () => _showSalesDetails(context, todaySales),
          ),
        );
      },
    );
  }

  void _showSalesDetails(BuildContext context, List<DocumentSnapshot> sales) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Penjualan'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return ListTile(
                title: Text(sale['productName']),
                trailing: Text(
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(sale['total']),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalsList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: () {
          Query query = FirebaseFirestore.instance.collection('withdrawals');
          if (_startDate != null && _endDate != null) {
            query = query
                .where('createdAt', isGreaterThanOrEqualTo: _startDate)
                .where('createdAt', isLessThanOrEqualTo: _endDate);
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

          final withdrawals = snapshot.data!.docs
              .map((doc) => Withdrawal.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: withdrawals.length,
            itemBuilder: (context, index) {
              final withdrawal = withdrawals[index];
              return ListTile(
                title: Text(withdrawal.title),
                subtitle: Text(
                    '${DateFormat('yyyy-MM-dd').format(withdrawal.createdAt.toDate())} - ${withdrawal.description}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(withdrawal.amount),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/keuangan/update',
                        arguments: withdrawal,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteWithdrawal(context, withdrawal.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _deleteWithdrawal(BuildContext context, String id) {
    FirebaseFirestore.instance.collection('withdrawals').doc(id).delete();
  }
}
