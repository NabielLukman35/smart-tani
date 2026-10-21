import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/local_db/database_helper.dart';
import '../../data/models/greenhouse_model.dart';

class GreenhouseProvider extends ChangeNotifier {
  List<GreenhouseModel> _greenhouses = [];
  bool _isLoading = false;

  List<GreenhouseModel> get greenhouses => _greenhouses;
  bool get isLoading => _isLoading;

  Future<void> loadGreenhouses(int userId) async {
    _isLoading = true;
    notifyListeners();
    final rows = await DatabaseHelper.instance.getGreenhousesByUser(userId);
    _greenhouses = rows.map((row) => GreenhouseModel.fromMap(row)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addGreenhouse(GreenhouseModel gh) async {
    try {
      await DatabaseHelper.instance.insertGreenhouse(gh.toMap());
      await loadGreenhouses(gh.penggunaId);
      return true;
    } catch (e) {
      debugPrint('Error insert greenhouse: $e');
      return false;
    }
  }

  /// FR-04: Reverse Geocoding memakai Nominatim OSM (Wajib User-Agent)
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'TaniGreenApp/1.0 (contact@tanigreen.id)',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Alamat tidak ditemukan';
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
    return 'Koordinat: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)} (Offline)';
  }

  /// LBS: Pencarian lokasi menggunakan OpenStreetMap Nominatim Search API
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'TaniGreenApp/1.0 (contact@tanigreen.id)',
        },
      );

      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((item) => {
          'display_name': item['display_name'] ?? '',
          'lat': double.parse(item['lat']),
          'lon': double.parse(item['lon']),
        }).toList();
      }
    } catch (e) {
      debugPrint('Search location error: $e');
    }
    return [];
  }
}
