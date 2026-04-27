import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  static const _enabledKey = 'daily_notifications_enabled'; // untuk menyimpan status apakah notifikasi diaktifkan atau tidak
  static const _hourKey = 'daily_notifications_hour'; // untuk menyimpan jam pengingat harian
  static const _minuteKey = 'daily_notifications_minute'; // untuk menyimpan menit pengingat harian
  static const _notificationId = 1001; // ID unik untuk notifikasi harian

  // fungsi untuk menginisialisasi layanan notifikasi, termasuk mengatur zona waktu dan meminta izin jika diperlukan
  Future<void> initialize() async {
    tz.initializeTimeZones();
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    await requestPermission();
  }

  // fungsi untuk meminta izin notifikasi dari pengguna
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  // fungsi untuk memeriksa apakah notifikasi harian diaktifkan atau tidak
  Future<bool> get isEnabled async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  // fungsi untuk mengaktifkan atau menonaktifkan notifikasi harian
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    if (!enabled) {
      await _plugin.cancel(_notificationId);
    }
  }

  // fungsi untuk mendapatkan waktu pengingat harian yang disimpan, atau mengembalikan waktu default (20:00) jika belum disimpan
  Future<TimeOfDay> get reminderTime async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_hourKey) ?? 20;
    final minute = prefs.getInt(_minuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  // fungsi untuk mengatur waktu pengingat harian
  Future<void> setReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, time.hour);
    await prefs.setInt(_minuteKey, time.minute);
  }

  // fungsi detail yang ditampilkan pada notifikasi harian
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'dailylingo_reminder',
        'Daily reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _notificationId,
      'Time for your DailyLingo!',
      'What did you do today? Let\'s write and speak it out.',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // fungsi untuk membatalkan notifikasi harian yang sudah dijadwalkan
  Future<void> showReminder() async {
    final time = await reminderTime;
    await scheduleDailyReminder(time);
  }

  // testing
  Future<void> showReminderNow() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'dailylingo_reminder',
        'Daily reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      _notificationId + 1,
      'Time for your DailyLingo!',
      'What did you do today? Let\'s write and speak it out.',
      details,
    );
  }
}
