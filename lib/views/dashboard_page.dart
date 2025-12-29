import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/schedule.dart';
import 'package:myapp/models/sold_product.dart';
import 'package:myapp/services/financial_service.dart';
import 'package:myapp/services/schedule_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FinancialSummary(),
            SizedBox(height: 24),
            WeeklySalesChart(),
            SizedBox(height: 24),
            TopSellingProducts(),
            SizedBox(height: 24),
            ModernScheduleView(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class FinancialSummary extends StatelessWidget {
  const FinancialSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final FinancialService financialService = FinancialService();
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return StreamBuilder<Map<String, double>>(
      stream: financialService.getFinancialSummary(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Keuangan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _SummaryBox(
              label: 'Penghasilan (1 Thn)',
              amount: currencyFormatter.format(summary['annualIncome']),
              icon: Icons.trending_up,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 12),
            _SummaryBox(
              label: 'Pengeluaran (1 Thn)',
              amount: currencyFormatter.format(summary['annualExpense']),
              icon: Icons.trending_down,
              color: Colors.red.shade600,
            ),
            const SizedBox(height: 12),
            _SummaryBox(
              label: 'Sisa Saldo',
              amount: currencyFormatter.format(summary['totalBalance']),
              icon: Icons.account_balance_wallet_outlined,
              color: Colors.blue.shade700,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryBox({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(
                amount,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WeeklySalesChart extends StatelessWidget {
  const WeeklySalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    final financialService = FinancialService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Grafik Penjualan (7 Hari Terakhir)',
          style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: StreamBuilder<Map<String, double>>(
            stream: financialService.getWeeklySalesData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Belum ada data penjualan minggu ini.'));
              }

              final salesData = snapshot.data!;
              final today = DateTime.now();
              final chartData = <int, double>{};
              double maxY = 0;

              for (int i = 6; i >= 0; i--) {
                final date = today.subtract(Duration(days: i));
                final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                final value = salesData[dayKey] ?? 0;
                chartData[6-i] = value;
                if(value > maxY) maxY = value;
              }
              
              maxY = maxY == 0 ? 100000 : (maxY * 1.2);

              return BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final day = DateFormat.E('id_ID').format(today.subtract(Duration(days: 6 - group.x.toInt())));
                        final amount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(rod.toY);
                        return BarTooltipItem(
                          '$day\n$amount',
                          GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final day = DateFormat.E('id_ID').format(today.subtract(Duration(days: 6 - value.toInt()))).substring(0,3);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(day, style: GoogleFonts.lato(fontSize: 12)),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                     leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                         getTitlesWidget: (value, meta) {
                           if (value == 0 || value >= maxY) return const SizedBox();
                          return Text(
                            '${(value / 1000).toStringAsFixed(0)}k', 
                             style: GoogleFonts.lato(fontSize: 11),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: chartData.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Theme.of(context).colorScheme.primary,
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          )
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TopSellingProducts extends StatelessWidget {
  const TopSellingProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final financialService = FinancialService();

    return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produk Terlaris (30 Hari Terakhir)',
          style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: StreamBuilder<List<SoldProduct>>(
            stream: financialService.getTopSellingProducts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text('Belum ada produk yang terjual.'));
              }
              
              final products = snapshot.data!;

              return Column(
                children: products.asMap().entries.map((entry) {
                  final index = entry.key;
                  final product = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(50),
                          child: Text('${index + 1}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(product.productName, style: GoogleFonts.lato(fontSize: 16), overflow: TextOverflow.ellipsis,),
                        ),
                        const SizedBox(width: 8),
                        Text('${product.quantity}x', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}


class ModernScheduleView extends StatefulWidget {
  const ModernScheduleView({super.key});

  @override
  State<ModernScheduleView> createState() => _ModernScheduleViewState();
}

class _ModernScheduleViewState extends State<ModernScheduleView> {
  final ScheduleService _scheduleService = ScheduleService();
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDays = _getWeekDays(_selectedDate);
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Piket',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        DateStrip(
            weekDays: _weekDays,
            selectedDate: _selectedDate,
            onDateSelected: _onDateSelected),
        const SizedBox(height: 16),
        StreamBuilder<List<Schedule>>(
          stream: _scheduleService.getSchedulesForDay(
              DateFormat('EEEE', 'id_ID').format(_selectedDate)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Text(
                    'Tidak ada jadwal untuk hari ini.',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final schedule = snapshot.data![index];
                return ScheduleCard(schedule: schedule);
              },
            );
          },
        ),
      ],
    );
  }
}

class DateStrip extends StatelessWidget {
  final List<DateTime> weekDays;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateStrip({
    super.key,
    required this.weekDays,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((date) {
          final isSelected = DateUtils.isSameDay(date, selectedDate);
          return InkWell(
            onTap: () => onDateSelected(date),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).colorScheme.primary.withAlpha(128),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    )
                  : null,
              child: Column(
                children: [
                  Text(
                    DateFormat.E('id_ID').format(date).substring(0, 3).toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;

  const ScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Petugas Hari ${schedule.day}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Divider(
                height: 24, thickness: 1, color: Theme.of(context).dividerColor),
            ...schedule.names.map(
              (name) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Icon(Icons.person_outline,
                        color: Theme.of(context).colorScheme.secondary, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
