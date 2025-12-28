import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/auth/auth_wrapper.dart';
import 'package:myapp/views/dashboard_page.dart';
import 'package:myapp/views/jadwal/create_page.dart' as jadwal_create;
import 'package:myapp/views/jadwal/index_page.dart' as jadwal_index;
import 'package:myapp/views/jadwal/update_page.dart' as jadwal_update;
import 'package:myapp/views/keuangan/create_page.dart' as keuangan_create;
import 'package:myapp/views/keuangan/index_page.dart' as keuangan_index;
import 'package:myapp/views/keuangan/update_page.dart' as keuangan_update;
import 'package:myapp/views/penjualan/create_page.dart' as penjualan_create;
import 'package:myapp/views/penjualan/index_page.dart' as penjualan_index;
import 'package:myapp/views/penjualan/update_page.dart' as penjualan_update;
import 'package:myapp/views/products/create_page.dart' as product_create;
import 'package:myapp/views/products/index_page.dart' as product_index;
import 'package:myapp/views/products/update_page.dart' as product_update;
import 'package:myapp/views/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String scheduleIndex = '/jadwal';
  static const String scheduleCreate = '/jadwal/create';
  static const String scheduleUpdate = '/jadwal/update';
  static const String keuangan = '/keuangan';
  static const String keuanganCreate = '/keuangan/create';
  static const String keuanganUpdate = '/keuangan/update';
  static const String penjualan = '/penjualan';
  static const String penjualanCreate = '/penjualan/create';
  static const String penjualanUpdate = '/penjualan/update';
  static const String product = '/products';
  static const String productCreate = '/products/create';
  static const String productUpdate = '/products/update';

  static GoRouter getRouter(FirebaseAuth authInstance) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = authInstance.currentUser != null;
        final bool loggingIn = state.matchedLocation == AppRoutes.auth;

        if (loggedIn && loggingIn) {
          return AppRoutes.dashboard;
        } 

        return null;
      },
      routes: [
         GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.auth,
          builder: (context, state) => const AuthWrapper(),
        ),
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.scheduleIndex,
          builder: (context, state) => const jadwal_index.ScheduleListPage(),
        ),
        GoRoute(
            path: AppRoutes.scheduleCreate,
            builder: (context, state) =>
                const jadwal_create.ScheduleCreatePage()),
        GoRoute(
          path: '${AppRoutes.scheduleUpdate}/:id',
          builder: (context, state) {
            final String id = state.pathParameters['id']!;
            return jadwal_update.ScheduleUpdatePage(scheduleId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.keuangan,
          builder: (context, state) =>
              const keuangan_index.FinancialRecordListPage(),
        ),
        GoRoute(
          path: AppRoutes.keuanganCreate,
          builder: (context, state) =>
              const keuangan_create.FinancialRecordCreatePage(),
        ),
        GoRoute(
          path: '${AppRoutes.keuanganUpdate}/:id',
          builder: (context, state) {
            final String id = state.pathParameters['id']!;
            return keuangan_update.FinancialRecordUpdatePage(recordId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.penjualan,
          builder: (context, state) => const penjualan_index.SaleListPage(),
        ),
        GoRoute(
          path: AppRoutes.penjualanCreate,
          builder: (context, state) => const penjualan_create.SaleCreatePage(),
        ),
        GoRoute(
          path: '${AppRoutes.penjualanUpdate}/:id',
          builder: (context, state) {
            final String id = state.pathParameters['id']!;
            return penjualan_update.SaleUpdatePage(saleId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.product,
          builder: (context, state) => const product_index.ProductIndexPage(),
        ),
        GoRoute(
          path: AppRoutes.productCreate,
          builder: (context, state) => const product_create.ProductCreatePage(),
        ),
        GoRoute(
          path: '${AppRoutes.productUpdate}/:id',
          builder: (context, state) {
            final String id = state.pathParameters['id']!;
            return product_update.ProductUpdatePage(productId: id);
          },
        ),
      ],
    );
  }
}
