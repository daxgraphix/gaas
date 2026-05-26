import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _notificationsEnabled = true;

  Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Load user preferences
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    _initialized = true;
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    // Handle notification tap - could navigate to specific screens
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and handle navigation
      try {
        json.decode(payload);
        // Navigate based on notification type
      } catch (e) {
        // Invalid payload
      }
    }
  }

  Future<void> showAchievementNotification(String title, String body) async {
    if (!_notificationsEnabled) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievements',
      channelDescription: 'Achievement notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      details,
      payload: json.encode({'type': 'achievement', 'title': title}),
    );
  }

  Future<void> showDailyReminder(String title, String body) async {
    if (!_notificationsEnabled) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminders',
      channelDescription: 'Daily practice reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch + 1,
      title,
      body,
      details,
      payload: json.encode({'type': 'daily_reminder'}),
    );
  }

  Future<void> showStreakNotification(String title, String body) async {
    if (!_notificationsEnabled) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'streak',
      'Streak Notifications',
      channelDescription: 'Streak maintenance notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch + 2,
      title,
      body,
      details,
      payload: json.encode({'type': 'streak', 'title': title}),
    );
  }

  Future<void> showLevelUpNotification(String title, String body) async {
    if (!_notificationsEnabled) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'level_up',
      'Level Up',
      channelDescription: 'Level progression notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch + 3,
      title,
      body,
      details,
      payload: json.encode({'type': 'level_up', 'title': title}),
    );
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    if (!_notificationsEnabled) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_reminder',
      'Scheduled Reminders',
      channelDescription: 'Scheduled daily reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      999, // ID for daily reminder
      'Time for Math Practice!',
      'Keep your streak going with daily practice.',
      _nextInstanceOfTime(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelDailyReminder() async {
    await _notificationsPlugin.cancel(999);
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }

  bool get notificationsEnabled => _notificationsEnabled;
}