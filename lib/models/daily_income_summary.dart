import 'package:myapp/models/financial_event.dart';
import 'package:myapp/models/sold_product.dart';

class DailyIncomeSummary extends FinancialEvent {
  final double totalIncome;
  final List<SoldProduct> products;

  DailyIncomeSummary({
    required DateTime date,
    required this.totalIncome,
    required this.products,
  }) : super(date);
}
