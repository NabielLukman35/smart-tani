import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class TimezoneHelper {
  static bool _initialized = false;

  /// Inisialisasi database timezone offline (FR-07)
  static void init() {
    if (!_initialized) {
      tz.initializeTimeZones();
      _initialized = true;
    }
  }

  /// Konversi waktu UTC ISO String ke 4 Zona Waktu (WIB, WITA, WIT, London)
  static String formatUtcToZone(String utcIsoString, String zone) {
    init();
    try {
      final utcDateTime = DateTime.parse(utcIsoString).toUtc();

      String locationName;
      switch (zone) {
        case 'WIB':
          locationName = 'Asia/Jakarta';
          break;
        case 'WITA':
          locationName = 'Asia/Makassar';
          break;
        case 'WIT':
          locationName = 'Asia/Jayapura';
          break;
        case 'London':
          locationName = 'Europe/London';
          break;
        default:
          locationName = 'Asia/Jakarta';
      }

      final location = tz.getLocation(locationName);
      final tzDateTime = tz.TZDateTime.from(utcDateTime, location);

      final formatter = DateFormat('dd MMM yyyy, HH:mm:ss');
      return '${formatter.format(tzDateTime)} $zone';
    } catch (_) {
      return utcIsoString;
    }
  }
}