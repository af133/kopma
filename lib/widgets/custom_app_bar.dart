import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:myapp/routes/app_router.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  // Menghapus `showBackButton` dari konstruktor
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final canGoBack = context.canPop();

    final List<Widget> allActions = [];
    if (actions != null) {
      allActions.addAll(actions!);
    }
    allActions.addAll([
      IconButton(
        icon: Icon(
          Theme.of(context).brightness == Brightness.dark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined,
          color: theme.appBarTheme.foregroundColor,
        ),
        onPressed: () {
          themeProvider.toggleTheme(context);
        },
        tooltip: 'Toggle Theme',
      ),
      // Hanya tampilkan tombol logout jika tidak ada tombol kembali
      // Ini mencegah AppBar menjadi terlalu ramai di halaman detail
      if (!canGoBack)
        IconButton(
          icon: Icon(Icons.logout_rounded, color: theme.appBarTheme.foregroundColor),
          onPressed: () async {
            // Reset tema sebelum logout
            themeProvider.resetToLightMode();

            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              context.go(AppRoutes.auth);
            }
          },
          tooltip: 'Logout',
        ),
    ]);

    return AppBar(
      // Menggunakan `context.canPop()` untuk secara otomatis menampilkan tombol kembali
      leading: canGoBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: theme.appBarTheme.foregroundColor),
              onPressed: () => context.pop(),
              tooltip: 'Kembali',
            )
          : null,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: theme.appBarTheme.foregroundColor,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 4,
      shadowColor: theme.shadowColor.withOpacity(0.3),
      actions: allActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
