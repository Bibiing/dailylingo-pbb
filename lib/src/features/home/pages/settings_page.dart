import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.authService,
    required this.notificationService,
  });

  final AuthService authService;
  final NotificationService notificationService;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<bool> _enabledFuture;
  late Future<TimeOfDay> _timeFuture;

  @override
  void initState() {
    super.initState();
    _enabledFuture = widget.notificationService.isEnabled;
    _timeFuture = widget.notificationService.reminderTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<bool>(
            future: _enabledFuture,
            builder: (context, snapshot) {
              final enabled = snapshot.data ?? false;
              return SwitchListTile(
                value: enabled,
                onChanged: (value) async {
                  await widget.notificationService.setEnabled(value);
                  if (value) {
                    final reminderTime =
                        await widget.notificationService.reminderTime;
                    await widget.notificationService.scheduleDailyReminder(
                      reminderTime,
                    );
                  }
                  setState(() {
                    _enabledFuture = Future.value(value);
                  });
                },
                title: const Text('Daily reminder'),
                subtitle: const Text(
                  'Tampilkan pengingat harian untuk menulis dan berbicara.',
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          FutureBuilder<TimeOfDay>(
            future: _timeFuture,
            builder: (context, snapshot) {
              final time =
                  snapshot.data ?? const TimeOfDay(hour: 20, minute: 0);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Reminder time'),
                subtitle: Text(time.format(context)),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );
                    if (picked == null) return;
                    await widget.notificationService.setReminderTime(picked);
                    final enabled = await widget.notificationService.isEnabled;
                    if (enabled) {
                      await widget.notificationService.scheduleDailyReminder(
                        picked,
                      );
                    }
                    setState(() {
                      _timeFuture = Future.value(picked);
                    });
                  },
                  child: const Text('Change'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () => widget.authService.signOut(),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
