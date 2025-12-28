import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/auth/auth_wrapper.dart';
import 'package:myapp/views/main_page.dart';
import 'package:myapp/views/jadwal/create_page.dart' as jadwal_create;
import 'package:myapp/views/jadwal/update_page.dart' as jadwal_update;
import 'package:myapp/views/keuangan/create_page.dart' as keuangan_create;
import 'package:myapp/views/keuangan/update_page.dart' as keuangan_update;
import 'package:myapp/views/penjualan/create_page.dart' as penjualan_create;
import 'package:myapp/views/penjualan/update_page.dart' as penjualan_update;
import 'package:myapp/views/produk/create_page.dart' as produk_create;
import 'package:myapp/views/produk/index_page.dart' as produk_index;
import 'package:myapp/views/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String auth = '/auth';
  static const String main = '/main';
  static const String scheduleCreate = '/jadwal/create';
  static const String scheduleUpdate = '/jadwal/update';
  static const String keuanganCreate = '/keuangan/create';
  static const String keuanganUpdate = '/keuangan/update';
  static const String penjualanCreate = '/penjualan/create';
  static const String penjualanUpdate = '/penjualan/update';
  static const String produk = '/produk';
  static const String produkCreate = '/produk/create';
  static const String produkUpdate = '/produk/update';

  static GoRouter getRouter(FirebaseAuth authInstance) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (BuildContext context, GoRouterState state) {
        final bool loggedIn = authInstance.currentUser != null;
        final bool loggingIn = state.matchedLocation == AppRoutes.auth;

        if (loggedIn && loggingIn) {
          return AppRoutes.main;
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
          path: AppRoutes.main,
          builder: (context, state) => const MainPage(),
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
          path: AppRoutes.produk,
          builder: (context, state) => const produk_index.ProductListPage(),
        ),
        GoRoute(
          path: AppRoutes.produkCreate,
          builder: (context, state) => const produk_create.ProductCreatePage(),
        ),
      ],
    );
  }
}
