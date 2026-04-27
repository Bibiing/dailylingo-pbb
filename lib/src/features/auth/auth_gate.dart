import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../home/home_shell.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(
      FirebaseAuth.instance,
    ); // inisialisasi AuthService dengan FirebaseAuth
    // StreamBuilder untuk memantau perubahan status autentikasi pengguna
    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        // tampilkan loading indicator saat menunggu status autentikasi
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // jika pengguna sudah terautentikasi, tampilkan HomeShell
        if (snapshot.hasData) {
          return HomeShell(authService: authService);
        }
        // jika pengguna belum terautentikasi, tampilkan AuthScreen
        return AuthScreen(authService: authService);
      },
    );
  }
}
