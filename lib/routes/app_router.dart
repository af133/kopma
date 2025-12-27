import 'package:go_router/go_router.dart';
import 'package:myapp/auth/auth_wrapper.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/models/withdrawal.dart';
import 'package:myapp/views/dashboard_page.dart';
import 'package:myapp/views/keuangan/create_page.dart' as KeuanganCreatePage;
import 'package:myapp/views/keuangan/index_page.dart' as KeuanganIndexPage;
import 'package:myapp/views/keuangan/update_page.dart' as KeuanganUpdatePage;
import 'package:myapp/views/penjualan/create_page.dart' as PenjualanCreatePage;
import 'package:myapp/views/penjualan/index_page.dart' as PenjualanIndexPage;
import 'package:myapp/views/products/create_page.dart' as ProductCreatePage;
import 'package:myapp/views/products/index_page.dart' as ProductIndexPage;
import 'package:myapp/views/products/update_page.dart' as ProductUpdatePage;
import 'package:myapp/views/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthWrapper(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/penjualan',
        builder: (context, state) => const PenjualanIndexPage.IndexPage(),
      ),
      GoRoute(
        path: '/penjualan/create',
        builder: (context, state) => const PenjualanCreatePage.CreatePage(),
      ),
      GoRoute(
        path: '/product',
        builder: (context, state) => const ProductIndexPage.ProductIndex(),
      ),
      GoRoute(
        path: '/product/create',
        builder: (context, state) => const ProductCreatePage.CreateProductPage(),
      ),
      GoRoute(
        path: '/product/update',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductUpdatePage.UpdateProductPage(product: product);
        },
      ),
      GoRoute(
        path: '/keuangan',
        builder: (context, state) => const KeuanganIndexPage.IndexPage(),
      ),
      GoRoute(
        path: '/keuangan/create',
        builder: (context, state) => const KeuanganCreatePage.CreatePage(),
      ),
      GoRoute(
        path: '/keuangan/update',
        builder: (context, state) {
          final withdrawal = state.extra as Withdrawal;
          return KeuanganUpdatePage.UpdatePage(withdrawal: withdrawal);
        },
      ),
    ],
  );
}
