import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/financial_record.dart';

class FinancialService {
  final CollectionReference _recordsCollection = 
      FirebaseFirestore.instance.collection('financial_records');

  // Add a new financial record
  Future<void> addRecord(FinancialRecord record) {
    return _recordsCollection.add(record.toFirestore());
  }

  // Update an existing financial record
  Future<void> updateRecord(String docId, FinancialRecord record) {
    return _recordsCollection.doc(docId).update(record.toFirestore());
  }

  // Delete a financial record
  Future<void> deleteRecord(String docId) {
    return _recordsCollection.doc(docId).delete();
  }

  // Stream for real-time updates
  Stream<QuerySnapshot> getRecordsStream() {
    return _recordsCollection.orderBy('createdAt', descending: true).snapshots();
  }
}
