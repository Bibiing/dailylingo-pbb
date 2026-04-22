import 'package:flutter/material.dart';

import 'features/auth/auth_gate.dart';
import 'theme/app_theme.dart';

class DailyLingoApp extends StatelessWidget {
  const DailyLingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DailyLingo',
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}
