import 'package:flutter/material.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/services/financial_service.dart';

class FinancialProvider with ChangeNotifier {
  final FinancialService _financialService = FinancialService();

  List<FinancialRecord> _records = [];
  List<FinancialRecord> get records => _records;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  FinancialProvider() {
    fetchRecords();
  }

  // REFACTORED: Correctly fetches a Future<List<FinancialRecord>>
  Future<void> fetchRecords() async {
    _isLoading = true;
    _errorMessage = null;
    // Notify listeners at the start of the fetch
    notifyListeners();

    try {
      _records = await _financialService.getFinancialRecords();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      // Notify listeners at the end of the fetch
      notifyListeners();
    }
  }

  Future<void> createFinancialRecord(FinancialRecord record) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _financialService.createFinancialRecord(record);
      // After creating, fetch the updated list
      await fetchRecords();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      // Re-throw the error to be caught in the UI if needed
      rethrow;
    } finally {
       _isLoading = false;
      notifyListeners();
    }
  }

  // NEW: Method to delete a record
  Future<void> deleteFinancialRecord(String recordId) async {
     _isLoading = true;
    notifyListeners();
    try {
      await _financialService.deleteFinancialRecord(recordId);
      // After deleting, fetch the updated list
      await fetchRecords();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
       _isLoading = false;
      notifyListeners();
    }
  }

  // NEW: Method to update a record
  Future<void> updateFinancialRecord(FinancialRecord record) async {
     _isLoading = true;
    notifyListeners();
    try {
      await _financialService.updateFinancialRecord(record);
      // After updating, fetch the updated list
      await fetchRecords();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
       _isLoading = false;
      notifyListeners();
    }
  }
}
