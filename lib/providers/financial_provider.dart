import 'package:flutter/material.dart';
import 'package:myapp/models/financial_record.dart';
import 'package:myapp/services/financial_service.dart';

class FinancialProvider with ChangeNotifier {
  final FinancialService _financialService = FinancialService();

  Future<void> createFinancialRecord(FinancialRecord record) {
    return _financialService.createFinancialRecord(record);
  }

  Future<void> deleteFinancialRecord(String recordId) {
    return _financialService.deleteFinancialRecord(recordId);
  }

  Future<void> updateFinancialRecord(FinancialRecord record) {
    return _financialService.updateFinancialRecord(record);
  }
  
  // fetchRecords is no longer needed here as the UI will use a direct stream from the service.
  // State management for the list (records, isLoading, errorMessage) is also removed.
}
