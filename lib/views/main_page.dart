import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/routes/app_router.dart';
import 'package:myapp/views/dashboard_page.dart';
import 'package:myapp/views/jadwal/index_page.dart';
import 'package:myapp/views/keuangan/index_page.dart';
import 'package:myapp/views/penjualan/index_page.dart';
import 'package:myapp/views/products/index_page.dart';
import 'package:myapp/widgets/custom_app_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const ScheduleListPage(),
    const FinancialRecordListPage(),
    const SaleListPage(),
    const ProductIndexPage(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Jadwal Piket',
    'Keuangan',
    'Penjualan',
    'Produk',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateAndCreate() {
    switch (_selectedIndex) {
      case 1:
        context.go(AppRoutes.scheduleCreate);
        break;
      case 2:
        context.go(AppRoutes.keuanganCreate);
        break;
      case 3:
        context.go(AppRoutes.penjualanCreate);
        break;
      case 4:
        context.go(AppRoutes.produkCreate);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: _titles[_selectedIndex]),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Keuangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Penjualan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produk',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        backgroundColor: theme.colorScheme.surface,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: _selectedIndex > 0
          ? FloatingActionButton(
              onPressed: _navigateAndCreate,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
