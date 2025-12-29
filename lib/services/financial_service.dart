import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/daily_income_summary.dart';
import 'package:myapp/models/financial_event.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/models/sold_product.dart';
import 'package:rxdart/rxdart.dart';

class FinancialService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

   Stream<Map<String, double>> getWeeklySalesData() {
    return _db
        .collection('sales')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))))
        .snapshots()
        .map((snapshot) {
      final salesByDay = <String, double>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['createdAt'] as Timestamp;
        final date = timestamp.toDate();
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final total = _parseDouble(data['total']);

        salesByDay.update(dayKey, (value) => value + total, ifAbsent: () => total);
      }
      return salesByDay;
    });
  }

  Stream<List<SoldProduct>> getTopSellingProducts() {
  return _db
      .collection('sales')
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))))
      .snapshots()
      .map((snapshot) {
    final Map<String, SoldProduct> productSales = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
        final productName = data['name'] as String?;
        final quantity = _parseInt(data['quantity']);
        final revenue = _parseDouble(data['total']);

        if (productName == null || quantity <= 0) continue;

        productSales.update(
          productName,
          (existing) => SoldProduct(
            productName: productName,
            quantity: existing.quantity + quantity,
            totalRevenue: existing.totalRevenue + revenue,
          ),
          ifAbsent: () => SoldProduct(
            productName: productName,
            quantity: quantity,
            totalRevenue: revenue,
          ),
        );
    }

    final sortedProducts = productSales.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    return sortedProducts.take(5).toList();
  });
}


  Stream<List<FinancialEvent>> getFinancialEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Stream<List<DailyIncomeSummary>> incomeStream = getDailyIncomeSummaries(
      startDate: startDate,
      endDate: endDate,
    );
    Stream<List<FinancialRecord>> expenseStream = getFinancialRecords(
      startDate: startDate,
      endDate: endDate,
    );

    return Rx.combineLatest2(
      incomeStream,
      expenseStream,
      (List<DailyIncomeSummary> incomes, List<FinancialRecord> expenses) {
        final List<FinancialEvent> combined = [ ...incomes, ...expenses ];
        combined.sort((a, b) => b.date.compareTo(a.date));
        return combined;
      },
    );
  }

    Stream<Map<String, double>> getFinancialSummary() {
    return getFinancialEvents().map((events) {
      double annualIncome = 0;
      double annualExpense = 0;

      for (var event in events) {
        if (event is DailyIncomeSummary) {
          annualIncome += event.totalIncome;
        } else if (event is FinancialRecord) {
          annualExpense += event.cost;
        }
      }
      
      double totalBalance = annualIncome - annualExpense;

      return {
        'annualIncome': annualIncome,
        'annualExpense': annualExpense,
        'totalBalance': totalBalance,
      };
    });
  }


  Future<void> createFinancialRecord(FinancialRecord record) {
    return _db.collection('expense').add(record.toFirestore());
  }

  Stream<List<FinancialRecord>> getFinancialRecords({DateTime? startDate, DateTime? endDate}) {
    Query query = _db.collection('expense').orderBy('date', descending: true);
    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: endDate.add(const Duration(days: 1)));
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => FinancialRecord.fromFirestore(doc))
        .toList());
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

  Stream<List<DailyIncomeSummary>> getDailyIncomeSummaries({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _db.collection('sales').orderBy('createdAt', descending: true);
    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate.add(const Duration(days: 1))));
    }

    return query.snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }

      final Map<String, List<QueryDocumentSnapshot>> salesByDay = {};
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          if (data is! Map<String, dynamic> || data['createdAt'] is! Timestamp) continue;
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
}
