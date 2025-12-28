
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/views/main_page.dart';
import 'package:myapp/views/auth/login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Periksa status koneksi stream
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          // Jika tidak ada data user, tampilkan halaman Login
          if (user == null) {
            return const LoginPage();
          }
          // Jika ada data user, tampilkan halaman Dashboard
          return const MainPage();
        } else {
          // Selagi stream menunggu koneksi awal, tampilkan loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
