import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../services/auth_service.dart';
import '../../services/diary_repository.dart';
import '../../services/notification_service.dart';
import 'pages/diary_page.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.authService});

  final AuthService authService;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final DiaryRepository _repository;
  late final NotificationService _notificationService;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _repository = DiaryRepository(FirebaseFirestore.instance);
    _notificationService = NotificationService(
      FlutterLocalNotificationsPlugin(),
    );
    unawaited(_bootstrapNotifications());
  }

  Future<void> _bootstrapNotifications() async {
    await _notificationService.initialize();
    final enabled = await _notificationService.isEnabled;
    if (enabled) {
      await _notificationService.requestPermission();
      final time = await _notificationService.reminderTime;
      await _notificationService.scheduleDailyReminder(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser!;
    final pages = <Widget>[
      HomePage(
        user: user,
        repository: _repository,
        notificationService: _notificationService,
      ),
      DiaryPage(user: user, repository: _repository),
      SettingsPage(
        authService: widget.authService,
        notificationService: _notificationService,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            label: 'Diary',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
