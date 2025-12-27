import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/views/products/index_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<Map<String, double>> _getFinancialSummary() async {
    final salesRef = FirebaseFirestore.instance.collection('sales');
    final withdrawalsRef = FirebaseFirestore.instance.collection('withdrawals');
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));

    final salesSnapshot = await salesRef.get();
    final withdrawalsSnapshot = await withdrawalsRef.get();

    double yearlyIncome = 0;
    double allTimeIncome = 0;
    for (var doc in salesSnapshot.docs) {
      final data = doc.data();
      final total = (data['total'] ?? 0).toDouble();
      allTimeIncome += total;
      if (data['createdAt'] != null &&
          (data['createdAt'] as Timestamp).toDate().isAfter(oneYearAgo)) {
        yearlyIncome += total;
      }
    }

    double yearlyExpenses = 0;
    double allTimeExpenses = 0;
    for (var doc in withdrawalsSnapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      allTimeExpenses += amount;
      if (data['createdAt'] != null &&
          (data['createdAt'] as Timestamp).toDate().isAfter(oneYearAgo)) {
        yearlyExpenses += amount;
      }
    }

    final balance = allTimeIncome - allTimeExpenses;

    return {
      'yearlyIncome': yearlyIncome,
      'yearlyExpenses': yearlyExpenses,
      'balance': balance,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Koperasi',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown[700]!, Colors.brown[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Logout',
          )
        ],
      ),
      backgroundColor: Colors.brown[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Calendar(),
              const SizedBox(height: 32),
              Text(
                'Ringkasan Keuangan',
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<Map<String, double>>(
                future: _getFinancialSummary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading data'));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No data available'));
                  }

                  final data = snapshot.data!;
                  final formatCurrency = NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

                  return Column(
                    children: [
                      _InfoBox(
                          title: 'Pemasukan (1 Tahun)',
                          value: formatCurrency.format(data['yearlyIncome']),
                          icon: Icons.arrow_circle_up,
                          iconColor: Colors.green),
                      const SizedBox(height: 16),
                      _InfoBox(
                          title: 'Pengeluaran (1 Tahun)',
                          value: formatCurrency.format(data['yearlyExpenses']),
                          icon: Icons.arrow_circle_down,
                          iconColor: Colors.red),
                      const SizedBox(height: 16),
                      _InfoBox(
                          title: 'Sisa Uang (Total)',
                          value: formatCurrency.format(data['balance']),
                          icon: Icons.account_balance_wallet,
                          iconColor: Colors.blue),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Aksi Cepat',
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _ActionButton(
                    icon: Icons.receipt_long,
                    label: 'Keuangan',
                    onTap: () {
                      // Navigate to finance page
                    },
                  ),
                  _ActionButton(
                    icon: Icons.shopping_cart_checkout,
                    label: 'Penjualan',
                    onTap: () {
                      // Navigate to sales page
                    },
                  ),
                  _ActionButton(
                    icon: Icons.inventory_2,
                    label: 'Produk',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProductIndex()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _InfoBox(
      {required this.title,
      required this.value,
      required this.icon,
      required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        color: Colors.brown[800],
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[900],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.brown[600]!, Colors.brown[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.brown[800]!.withAlpha(76),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _Calendar extends StatefulWidget {
  const _Calendar();

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<_Calendar> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final month = DateFormat.MMMM('id_ID').format(_focusedDay);
    final year = _focusedDay.year;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (Month and Year)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(
                          _focusedDay.year, _focusedDay.month - 1, 1);
                    });
                  },
                ),
                Text(
                  '$month $year',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(
                          _focusedDay.year, _focusedDay.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
          ),
          // Calendar Grid
          TableCalendar(
            locale: 'id_ID',
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            headerVisible: false, // Hide default header
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown[600]),
              weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[800]),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.brown[300],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.brown[600],
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red[800]),
            ),
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
        ],
      ),
    );
  }
}
