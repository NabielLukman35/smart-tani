import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._init();

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    try {
      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notifikasi diklik: ${response.payload}');
        },
      );

      // Request permission on Android 13+
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Gagal inisialisasi NotificationService: $e');
    }
  }

  /// FR-12: Menampilkan notifikasi lokal pengingat suhu dan status IoT terkini (Foreground / Manual)
  Future<void> showTelemetryNotification({
    required String greenhouseName,
    required double suhu,
    required double lembapTanah,
    required double lembapUdara,
    required double cahaya,
    String? status,
  }) async {
    await init();

    final bool isWarning = suhu > 35.0 || lembapTanah < 40.0;
    final String title = isWarning
        ? '⚠️ [PERINGATAN IoT] $greenhouseName'
        : '🌿 [Pengingat Berkala] $greenhouseName';

    final String body =
        '🌡️ Suhu: $suhu°C | 💧 Lembap Tanah: $lembapTanah% | ☀️ Cahaya: ${cahaya.toInt()} Lux\n'
        '${isWarning ? 'Perhatian: Suhu tinggi / tanah kering. Sirkulasi mist spray dianjurkan.' : 'Status Mikroklimat: Kondisi tanaman optimal dan sehat.'}';

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'smart_tani_telemetry_channel',
      'Smart Tani Monitoring & Pengingat',
      channelDescription: 'Notifikasi pengingat telemetri suhu dan kelembapan IoT',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _plugin.show(
        DateTime.now().millisecond,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Error show notification: $e');
    }
  }

  /// FR-12: Mengaktifkan Pengingat Berkala Otomatis (Periodic Background Notification)
  /// Notifikasi ini otomatis tetap berbunyi di latar belakang walau aplikasi ditutup.
  Future<void> startPeriodicTelemetryReminder({
    String title = '🌿 [Pengingat Berkala] Smart Greenhouse',
    String body = '🌡️ Suhu Saat Ini: 28.5°C | Lembap Tanah: 72% | Kondisi Optimal',
  }) async {
    await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'smart_tani_periodic_channel',
      'Smart Tani Pengingat Otomatis',
      channelDescription: 'Pengingat berkala otomatis kondisi greenhouse saat aplikasi ditutup',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      // Pemicu berkala level OS (Hourly Repeat Interval)
      await _plugin.periodicallyShow(
        8888, // ID khusus periodic telemetry
        title,
        body,
        RepeatInterval.hourly,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Error starting periodic notification: $e');
    }
  }

  /// Mematikan pengingat berkala otomatis
  Future<void> stopPeriodicTelemetryReminder() async {
    await init();
    try {
      await _plugin.cancel(8888);
    } catch (e) {
      debugPrint('Error canceling periodic notification: $e');
    }
  }

  /// FR-12: Menjadwalkan pengingat otomatis untuk agenda Jadwal Tanam (Sesuai Jam Terpilih)
  Future<void> schedulePlantReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'smart_tani_schedule_channel',
      'Jadwal Tanam & Perawatan',
      channelDescription: 'Pengingat waktu penyiraman, pemupukan, dan panen tanaman',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      final now = DateTime.now();
      if (scheduledDate.isAfter(now)) {
        final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);
        await _plugin.zonedSchedule(
          id,
          '📅 [Pengingat Jadwal] $title',
          body,
          tzScheduled,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        // Jika waktu jadwal sudah dekat atau saat ini, tampilkan notifikasi langsung sebagai konfirmasi
        await _plugin.show(
          id,
          '📅 [Jadwal Aktif] $title',
          body,
          notificationDetails,
        );
      }
    } catch (e) {
      debugPrint('Error schedule notification: $e');
      // Fallback
      await _plugin.show(
        id,
        '📅 [Jadwal Tercatat] $title',
        body,
        notificationDetails,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await init();
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification $id: $e');
    }
  }
}
