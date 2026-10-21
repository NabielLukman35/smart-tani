import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  NotificationService._init();

  Future<void> init() async {
    if (_isInitialized) return;

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
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Gagal inisialisasi NotificationService: $e');
    }
  }

  /// FR-12: Menampilkan notifikasi lokal pengingat suhu dan status IoT terkini
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
}
