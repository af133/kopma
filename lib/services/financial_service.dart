import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/daily_income_summary.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/models/sold_product.dart';
import 'package:myapp/models/withdrawal.dart';

class FinancialService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'financial_records'; // Legacy collection

  // *************************************************************************
  // Expense CRUD Operations ('expense' collection) - ROBUST PARSING
  // *************************************************************************

  Future<void> createFinancialRecord(FinancialRecord record) {
    return _db.collection('expense').add(record.toFirestore());
  }

  Stream<List<FinancialRecord>> getFinancialRecords() {
    return _db.collection('expense').orderBy('date', descending: true).snapshots().map((snapshot) {
      final records = <FinancialRecord>[];
      for (final doc in snapshot.docs) {
        try {
          records.add(FinancialRecord.fromFirestore(doc));
        } catch (e, s) {
          developer.log(
            'Failed to parse a financial record doc: ${doc.id}', 
            error: e, 
            stackTrace: s, 
            name: 'FinancialService'
          );
          // Skip this corrupted document and continue with the rest
        }
      }
      return records;
    });
  }

  Future<FinancialRecord> getFinancialRecord(String id) async {
    final doc = await _db.collection('expense').doc(id).get();
    return FinancialRecord.fromFirestore(doc);
  }

  Future<void> updateFinancialRecord(FinancialRecord record) {
    return _db.collection('expense').doc(record.id).update(record.toFirestore());
  }

  Future<void> deleteFinancialRecord(String id) {
    return _db.collection('expense').doc(id).delete();
  }

  // *************************************************************************
  // Income Summary from 'sales' collection - REBUILT FOR CORRECT SCHEMA
  // *************************************************************************

  // Helper function for robust parsing of numeric values
  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Stream<List<DailyIncomeSummary>> getDailyIncomeSummaries() {
    return _db.collection('sales').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }

      final Map<String, List<QueryDocumentSnapshot>> salesByDay = {};
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data(); // Cast here
          if (data['createdAt'] is! Timestamp) continue;
          final timestamp = data['createdAt'] as Timestamp;
          final date = timestamp.toDate();
          final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          salesByDay.putIfAbsent(dayKey, () => []).add(doc);
        } catch (e, s) {
            developer.log('Could not process sales document grouping for ${doc.id}', error: e, stackTrace: s, name: 'FinancialService');
        }
      }

      final List<DailyIncomeSummary> summaries = [];
      salesByDay.forEach((dayKey, dailyDocs) {
        final Map<String, SoldProduct> productsSold = {};
        DateTime? saleDate;
        double totalDailyIncome = 0.0;

        for (var doc in dailyDocs) {
          final data = doc.data() as Map<String, dynamic>;
          saleDate ??= (data['createdAt'] as Timestamp).toDate();
          
          try {
             final productName = data['name'] as String?;
             final quantity = _parseInt(data['quantity']);
             final revenue = _parseDouble(data['total']);

             if (productName == null || quantity <= 0) continue;

             totalDailyIncome += revenue;

             productsSold.update(
               productName,
               (existingProduct) => SoldProduct(
                 productName: productName,
                 quantity: existingProduct.quantity + quantity,
                 totalRevenue: existingProduct.totalRevenue + revenue,
               ),
               ifAbsent: () => SoldProduct(
                 productName: productName,
                 quantity: quantity,
                 totalRevenue: revenue,
               ),
             );
          } catch (e, s) {
             developer.log('Could not parse individual sales document ${doc.id}', error: e, stackTrace: s, name: 'FinancialService');
          }
        }
        
        if (saleDate != null && productsSold.isNotEmpty) {
          summaries.add(
            DailyIncomeSummary(
              date: saleDate,
              totalIncome: totalDailyIncome,
              products: productsSold.values.toList()..sort((a, b) => b.quantity.compareTo(a.quantity)),
            ),
          );
        }
      });

      summaries.sort((a, b) => b.date.compareTo(a.date));

      return summaries;
    });
  }


  // *************************************************************************
  // Withdrawal and Legacy Financial Summary Functions - CORRECTED
  // *************************************************************************

  Future<void> addWithdrawal(Withdrawal withdrawal) {
    WriteBatch batch = _db.batch();
    DocumentReference withdrawalRef = _db.collection('withdrawals').doc();
    batch.set(withdrawalRef, withdrawal.toFirestore());
    
    // Legacy support for financial_records
    DocumentReference financialRecordRef = _db.collection(_collectionName).doc();
    batch.set(financialRecordRef, {
      'type': 'withdrawal',
      'amount': -withdrawal.amount,
      'description': withdrawal.description,
      // PERBAIKAN: Gunakan 'date' dari objek withdrawal
      'date': Timestamp.fromDate(withdrawal.date), 
      // 'createdAt' untuk record ini, berbeda dari tanggal penarikan
      'createdAt': FieldValue.serverTimestamp(),
    });
    return batch.commit();
  }

  Future<void> updateWithdrawal(Withdrawal withdrawal) async {
    WriteBatch batch = _db.batch();
    DocumentReference withdrawalRef = _db.collection('withdrawals').doc(withdrawal.id);
    batch.update(withdrawalRef, withdrawal.toFirestore());
    
    // Legacy support for financial_records
    QuerySnapshot financialRecords = await _db
        .collection(_collectionName)
        .where('description', isEqualTo: withdrawal.description) 
        .where('type', isEqualTo: 'withdrawal')
        .limit(1)
        .get();
        
    if (financialRecords.docs.isNotEmpty) {
      DocumentReference financialRecordRef = financialRecords.docs.first.reference;
      batch.update(financialRecordRef, {
        'amount': -withdrawal.amount,
        'description': withdrawal.description,
        // PERBAIKAN: Gunakan 'date' dari objek withdrawal
        'date': Timestamp.fromDate(withdrawal.date),
      });
    }
    await batch.commit();
  }

  Stream<Map<String, double>> getFinancialSummary() {
    return _db.collection(_collectionName).snapshots().map((snapshot) {
      double annualIncome = 0;
      double annualExpense = 0;
      double totalBalance = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num).toDouble();
        totalBalance += amount;
        if (data.containsKey('type')) {
            final recordType = data['type'];
            if (recordType == 'sale' || recordType == 'income') {
              annualIncome += amount;
            } else if (recordType == 'withdrawal' || recordType == 'expense') {
              annualExpense += amount.abs(); 
            }
        }
      }
      return {
        'annualIncome': annualIncome,
        'annualExpense': annualExpense,
        'totalBalance': totalBalance,
      };
    });
  }
}
