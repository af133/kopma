import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar(
      {super.key, required this.title, this.actions, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final List<Widget> allActions = [];
    if (actions != null) {
      allActions.addAll(actions!);
    }
    allActions.add(
      IconButton(
        icon: Icon(
          themeProvider.themeMode == ThemeMode.dark
              ? Icons.light_mode
              : Icons.dark_mode,
          color: theme.appBarTheme.foregroundColor,
        ),
        onPressed: () => themeProvider.toggleTheme(),
        tooltip: 'Toggle Theme',
      ),
    );

    return AppBar(
      leading: showBackButton && context.canPop()
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
              onPressed: () => context.pop(),
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
              theme.colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.5),
      actions: allActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
