import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/models/withdrawal.dart';

class FinancialService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'financial_records';

  // Create
  Future<void> createFinancialRecord(FinancialRecord record) {
    return _db.collection(_collectionName).add(record.toFirestore());
  }

  // Read
  Stream<List<FinancialRecord>> getFinancialRecords() {
    return _db.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FinancialRecord.fromFirestore(doc))
          .toList();
    });
  }

  // Read by id
  Future<FinancialRecord> getFinancialRecord(String id) async {
    final doc = await _db.collection(_collectionName).doc(id).get();
    return FinancialRecord.fromFirestore(doc);
  }

  // Update
  Future<void> updateFinancialRecord(FinancialRecord record) {
    return _db
        .collection(_collectionName)
        .doc(record.id)
        .update(record.toFirestore());
  }

  // Delete
  Future<void> deleteFinancialRecord(String id) {
    return _db.collection(_collectionName).doc(id).delete();
  }

  Future<void> addWithdrawal(Withdrawal withdrawal) {
    WriteBatch batch = _db.batch();

    DocumentReference withdrawalRef = _db.collection('withdrawals').doc();
    batch.set(withdrawalRef, withdrawal.toFirestore());

    DocumentReference financialRecordRef = _db.collection(_collectionName).doc();
    batch.set(financialRecordRef, {
      'type': 'withdrawal',
      'amount': -withdrawal.amount, // Store as negative for expense
      'description': withdrawal.description,
      'date': withdrawal.date, // Use 'date' to be consistent
      'createdAt': FieldValue.serverTimestamp(),
    });

    return batch.commit();
  }

  Future<void> updateWithdrawal(Withdrawal withdrawal) async {
    WriteBatch batch = _db.batch();

    // Update the original withdrawal document
    DocumentReference withdrawalRef = _db.collection('withdrawals').doc(withdrawal.id);
    batch.update(withdrawalRef, withdrawal.toFirestore());

    // Find and update the corresponding financial record
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
        'date': withdrawal.date,
      });
    } else {
      developer.log(
        'Corresponding financial record not found for withdrawal update.',
        name: 'financial_service',
      );
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
        
        // Check for 'type' field before accessing it
        if (data.containsKey('type')) {
            final recordType = data['type'];
            if (recordType == 'sale' || recordType == 'income') { // 'income' might be legacy
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
