import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CurrencyHelper {
  static const String _cacheKey = 'cached_currency_rates';

  // Kurs fallback default jika pertama kali buka aplikasi dalam keadaan offline
  static Map<String, double> _rates = {
    'USD': 0.000064,
    'EUR': 0.000059,
    'GBP': 0.000050,
  };

  /// Ambil kurs terbaru dari Frankfurter API & simpan ke cache lokal
  static Future<Map<String, double>> fetchRates() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final url = Uri.parse(
        'https://api.frankfurter.app/latest?from=IDR&to=USD,EUR,GBP',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> apiRates = data['rates'];
        _rates = {
          'USD': (apiRates['USD'] as num).toDouble(),
          'EUR': (apiRates['EUR'] as num).toDouble(),
          'GBP': (apiRates['GBP'] as num).toDouble(),
        };
        await prefs.setString(_cacheKey, json.encode(_rates));
        return _rates;
      }
    } catch (_) {
      // Jika gagal/offline, baca dari cache terakhir
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        final Map<String, dynamic> decoded = json.decode(cached);
        _rates = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    }
    return _rates;
  }

  static String formatIdr(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  static String convertAndFormat(double idrAmount, String targetCurrency) {
    final rate = _rates[targetCurrency] ?? 0.0;
    final converted = idrAmount * rate;
    final symbol = targetCurrency == 'USD'
        ? '\$ '
        : targetCurrency == 'EUR'
            ? '€ '
            : '£ ';
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol,
      decimalDigits: 2,
    ).format(converted);
  }
}