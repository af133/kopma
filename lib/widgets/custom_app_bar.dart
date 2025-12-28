import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar(
      {super.key, required this.title, this.actions, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
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
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
        onPressed: () => themeProvider.toggleTheme(),
        tooltip: 'Toggle Theme',
      ),
    );

    return AppBar(
      leading: showBackButton && context.canPop()
          ? IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () => context.pop(),
            )
          : null,
      automaticallyImplyLeading: false,
      title: Text(title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).appBarTheme.foregroundColor)),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      actions: allActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
