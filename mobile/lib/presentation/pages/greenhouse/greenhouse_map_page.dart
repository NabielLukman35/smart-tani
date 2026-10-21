import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_providers.dart';
import '../../providers/greenhouse_providers.dart';
import '../../../data/models/greenhouse_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/recommendation_helper.dart';
import '../../widgets/custom_sub_app_bar.dart';

class GreenhouseMapPage extends StatefulWidget {
  const GreenhouseMapPage({super.key});

  @override
  State<GreenhouseMapPage> createState() => _GreenhouseMapPageState();
}

class _GreenhouseMapPageState extends State<GreenhouseMapPage> {
  final MapController _mapController = MapController();
  LatLng _selectedPoint = const LatLng(-7.7828, 110.3670); // Default Yogyakarta
  String _currentAddress = 'Ketuk peta untuk memilih lokasi greenhouse';
  bool _isLoadingLocation = false;

  // Search Location Bar
  final TextEditingController _searchMapCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // Arah Mata Angin & Kompas
  double _compassHeading = 0.0; // Derajat 0 - 360
  String _arahMataAngin = 'Utara (0°)';
  LatLng? _currentLiveLocation; // Posisi live GPS real-time (ala Gojek)
  bool _isLiveTrackingFollow = true; // Auto-center kamera saat bergerak
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user?.id != null) {
        context.read<GreenhouseProvider>().loadGreenhouses(user!.id!);
      }
      _initLiveTrackingAndSensors();
    });
  }

  /// FR-04 & Sensor Rubrik PAM: Streaming GPS Realtime ala Gojek & Sensor Kompas Otomatis
  Future<void> _initLiveTrackingAndSensors() async {
    await _getCurrentLocation();

    // 1. Live GPS Stream (Update setiap 2 meter)
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      );
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position pos) {
        if (!mounted) return;
        final livePoint = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentLiveLocation = livePoint;
          if (_isLiveTrackingFollow) {
            _mapController.move(livePoint, _mapController.camera.zoom);
          }
        });
      });
    } catch (e) {
      debugPrint('Live GPS Stream error: $e');
    }

    // 2. Hardware Compass Sensor Stream (Otomatis Mengunci Utara)
    try {
      _compassSubscription = FlutterCompass.events?.listen((event) {
        if (event.heading != null && mounted) {
          setState(() {
            _updateCompassHeading(event.heading!);
          });
        }
      });
    } catch (e) {
      debugPrint('Compass Sensor error: $e');
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _compassSubscription?.cancel();
    _searchMapCtrl.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        final newPoint = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _selectedPoint = newPoint;
          if (pos.heading > 0) {
            _updateCompassHeading(pos.heading);
          }
        });
        _mapController.move(newPoint, 16.0);
        await _updateAddress(newPoint);
      }
    } catch (e) {
      debugPrint('Error GPS: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _updateAddress(LatLng point) async {
    setState(() => _currentAddress = 'Mencari alamat geocoding...');
    final address = await context
        .read<GreenhouseProvider>()
        .getAddressFromLatLng(point.latitude, point.longitude);
    if (mounted) {
      setState(() => _currentAddress = address);
    }
  }

  void _updateCompassHeading(double heading) {
    _compassHeading = heading % 360;
    if (_compassHeading >= 337.5 || _compassHeading < 22.5) {
      _arahMataAngin = 'Utara (N - ${_compassHeading.toInt()}°)';
    } else if (_compassHeading >= 22.5 && _compassHeading < 67.5) {
      _arahMataAngin = 'Timur Laut (NE - ${_compassHeading.toInt()}°)';
    } else if (_compassHeading >= 67.5 && _compassHeading < 112.5) {
      _arahMataAngin = 'Timur (E - ${_compassHeading.toInt()}°)';
    } else if (_compassHeading >= 112.5 && _compassHeading < 157.5) {
      _arahMataAngin = 'Tenggara (SE - ${_compassHeading.toInt()}°)';
    } else if (_compassHeading >= 157.5 && _compassHeading < 202.5) {
      _arahMataAngin = 'Selatan (S - ${_compassHeading.toInt()}°)';
    } else if (_compassHeading >= 202.5 && _compassHeading < 247.5) {
      _arahMataAngin = 'Barat Daya (SW - ${_compassHeading.toInt()}°)';
    } else if (_compassHeading >= 247.5 && _compassHeading < 292.5) {
      _arahMataAngin = 'Barat (W - ${_compassHeading.toInt()}°)';
    } else {
      _arahMataAngin = 'Barat Laut (NW - ${_compassHeading.toInt()}°)';
    }
  }

  Future<void> _handleSearchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await context.read<GreenhouseProvider>().searchPlaces(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(Map<String, dynamic> item) {
    final lat = item['lat'] as double;
    final lon = item['lon'] as double;
    final point = LatLng(lat, lon);

    setState(() {
      _selectedPoint = point;
      _currentAddress = item['display_name'] as String;
      _searchResults = [];
      _searchMapCtrl.clear();
    });
    FocusScope.of(context).unfocus();
    _mapController.move(point, 16.0);
  }

  Color _getMarkerColor(String status) {
    switch (status) {
      case 'Terlambat':
        return const Color(0xFFFF5252);
      case 'Perlu Perhatian':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  /// FR-12: Mengirimkan Notifikasi Pengingat Suhu & Status Lahan
  Future<void> _triggerTemperatureReminder() async {
    final ghName = _currentAddress.split(',').first;
    await NotificationService.instance.showTelemetryNotification(
      greenhouseName: ghName.isNotEmpty ? ghName : 'Greenhouse Utama',
      suhu: 28.5,
      lembapTanah: 62.0,
      lembapUdara: 68.0,
      cahaya: 650.0,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: AppTheme.darkForest),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Notifikasi pengingat suhu (FR-12) berhasil dikirimkan ke status bar perangkat!',
                  style: TextStyle(color: AppTheme.darkForest, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.neonLime,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Menampilkan Rekomendasi Buah & IoT Berdasarkan Lahan
  void _showRecommendationsBottomSheet() {
    final fruits = RecommendationHelper.getFruitRecommendations(
      latitude: _selectedPoint.latitude,
      longitude: _selectedPoint.longitude,
      luasAreaM2: 250.0,
    );
    final iotList = RecommendationHelper.getIotRecommendations();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DefaultTabController(
        length: 2,
        child: Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: AppTheme.darkForest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textGrey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Analisis Lahan Cerdas',
                    style: TextStyle(
                      color: AppTheme.creamWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textGrey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TabBar(
                  indicatorColor: AppTheme.neonLime,
                  labelColor: AppTheme.neonLime,
                  unselectedLabelColor: AppTheme.textGrey,
                  tabs: [
                    Tab(icon: Icon(Icons.eco_rounded), text: 'Rekomendasi Buah'),
                    Tab(icon: Icon(Icons.sensors_rounded), text: 'Rekomendasi IoT'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Tab 1: Rekomendasi Buah
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: fruits.length,
                      itemBuilder: (c, idx) {
                        final f = fruits[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.emeraldGreen.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      f.namaBuah,
                                      style: const TextStyle(
                                        color: AppTheme.creamWhite,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonLime.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      f.suhuIdeal,
                                      style: const TextStyle(
                                        color: AppTheme.neonLime,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f.varietasUnggul,
                                style: const TextStyle(
                                  color: AppTheme.textGrey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                f.alasanRekomendasi,
                                style: TextStyle(
                                  color: AppTheme.pastelLime.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.timer_rounded, size: 14, color: Color(0xFF00E5FF)),
                                  const SizedBox(width: 4),
                                  Text(
                                    f.estimasiPanen,
                                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.crop_free_rounded, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      f.kebutuhanLuas,
                                      style: const TextStyle(color: Colors.amber, fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Tab 2: Rekomendasi IoT
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: iotList.length,
                      itemBuilder: (c, idx) {
                        final iot = iotList[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.emeraldGreen.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      iot.namaPerangkat,
                                      style: const TextStyle(
                                        color: AppTheme.creamWhite,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      iot.tipe,
                                      style: const TextStyle(
                                        color: Color(0xFF00E5FF),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                iot.fungsiUtama,
                                style: TextStyle(
                                  color: AppTheme.pastelLime.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.inputFill,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.tune_rounded, size: 14, color: AppTheme.neonLime),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Standar Ideal: ${iot.nilaiIdeal}',
                                        style: const TextStyle(
                                          color: AppTheme.neonLime,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final luasCtrl = TextEditingController(text: '200');
    String selectedStatus = 'Normal';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: AppTheme.emeraldGreen.withValues(alpha: 0.45),
            ),
          ),
          title: const Text(
            'Tambah Titik Greenhouse (LBS)',
            style: TextStyle(color: AppTheme.creamWhite, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.creamWhite),
                  decoration: const InputDecoration(
                    labelText: 'Nama Greenhouse',
                    labelStyle: TextStyle(color: AppTheme.textGrey),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: luasCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppTheme.creamWhite),
                  decoration: const InputDecoration(
                    labelText: 'Luas Lahan (m²)',
                    labelStyle: TextStyle(color: AppTheme.textGrey),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  dropdownColor: AppTheme.cardSurface,
                  style: const TextStyle(color: AppTheme.creamWhite),
                  decoration: const InputDecoration(
                    labelText: 'Status Perawatan',
                    labelStyle: TextStyle(color: AppTheme.textGrey),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Normal',
                      child: Text('Normal (Hijau - Aman)'),
                    ),
                    DropdownMenuItem(
                      value: 'Perlu Perhatian',
                      child: Text('Perlu Perhatian (Oranye)'),
                    ),
                    DropdownMenuItem(
                      value: 'Terlambat',
                      child: Text('Terlambat (Merah)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedStatus = val);
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  'Alamat Geocoding:\n$_currentAddress',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppTheme.textGrey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = context.read<AuthProvider>().currentUser;
                if (user?.id == null || nameCtrl.text.isEmpty) return;

                final gh = GreenhouseModel(
                  penggunaId: user!.id!,
                  namaGreenhouse: nameCtrl.text.trim(),
                  latitude: _selectedPoint.latitude,
                  longitude: _selectedPoint.longitude,
                  alamat: _currentAddress,
                  luas: double.tryParse(luasCtrl.text) ?? 200.0,
                  status: selectedStatus,
                  syncStatus: 'Menunggu Unggah',
                );

                await context.read<GreenhouseProvider>().addGreenhouse(gh);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonLime,
                foregroundColor: AppTheme.darkForest,
              ),
              child: const Text('Simpan Lahan', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ghProvider = context.watch<GreenhouseProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              CustomSubAppBar(
                title: 'Peta & LBS Greenhouse',
                subtitle: 'Pemetaan Lahan, Arah Angin & Rekomendasi IoT',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Uji Notifikasi Suhu FR-12
                    GestureDetector(
                      onTap: _triggerTemperatureReminder,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Color(0xFF00E5FF),
                          size: 19,
                        ),
                      ),
                    ),
                    // Tombol My Location
                    GestureDetector(
                      onTap: _getCurrentLocation,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.neonLime.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.neonLime.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: AppTheme.neonLime,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Location Bar di atas Peta
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.inputFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
                  ),
                  child: TextField(
                    controller: _searchMapCtrl,
                    style: const TextStyle(color: AppTheme.creamWhite, fontSize: 13),
                    cursorColor: AppTheme.neonLime,
                    onSubmitted: _handleSearchLocation,
                    decoration: InputDecoration(
                      hintText: 'Cari lokasi (contoh: Sleman, Bantul, Lembang)...',
                      hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.neonLime, size: 20),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.neonLime),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded, color: AppTheme.neonLime, size: 18),
                              onPressed: () => _handleSearchLocation(_searchMapCtrl.text),
                            ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // Hasil Pencarian Dropdown List
              if (_searchResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.neonLime.withValues(alpha: 0.5)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) => Divider(color: AppTheme.emeraldGreen.withValues(alpha: 0.2), height: 1),
                    itemBuilder: (ctx, idx) {
                      final item = _searchResults[idx];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_city_rounded, color: AppTheme.neonLime, size: 18),
                        title: Text(
                          item['display_name'] as String,
                          style: const TextStyle(color: AppTheme.creamWhite, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectSearchResult(item),
                      );
                    },
                  ),
                ),

              // Peta OSM
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedPoint,
                        initialZoom: 15.0,
                        onPositionChanged: (camera, hasGesture) {
                          if (hasGesture && _isLiveTrackingFollow) {
                            setState(() => _isLiveTrackingFollow = false);
                          }
                        },
                        onTap: (tapPosition, point) {
                          setState(() {
                            _selectedPoint = point;
                            _isLiveTrackingFollow = false;
                          });
                          _updateAddress(point);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.tanigreen.mobile',
                        ),
                        MarkerLayer(
                          markers: [
                            // Marker Posisi Live Pengguna (Pulsing Blue Dot ala Gojek)
                            if (_currentLiveLocation != null)
                              Marker(
                                point: _currentLiveLocation!,
                                width: 50,
                                height: 50,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF2196F3).withValues(alpha: 0.25),
                                        border: Border.all(
                                          color: const Color(0xFF2196F3).withValues(alpha: 0.6),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    Transform.rotate(
                                      angle: (_compassHeading * (math.pi / 180)),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.topCenter,
                                        child: const Icon(
                                          Icons.navigation_rounded,
                                          color: Color(0xFF1976D2),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF1E88E5),
                                        border: Border.all(color: Colors.white, width: 2.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.35),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Marker(
                              point: _selectedPoint,
                              width: 50,
                              height: 50,
                              child: const Icon(
                                Icons.add_location_alt_rounded,
                                color: Color(0xFF00E5FF),
                                size: 44,
                              ),
                            ),
                            ...ghProvider.greenhouses.map(
                              (gh) => Marker(
                                point: LatLng(gh.latitude, gh.longitude),
                                width: 120,
                                height: 65,
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${gh.namaGreenhouse} (${gh.status}) - Luas: ${gh.luas} m²',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.darkForest,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: _getMarkerColor(gh.status),
                                          ),
                                        ),
                                        child: Text(
                                          gh.namaGreenhouse,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.location_on_rounded,
                                        color: _getMarkerColor(gh.status),
                                        size: 34,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Widget Kompas Arah Mata Angin (Pojok Kanan Atas Peta)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          // Tap kompas untuk putar sudut simulasi arah mata angin
                          setState(() {
                            _updateCompassHeading(_compassHeading + 45.0);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.darkForest.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.neonLime.withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.rotate(
                                angle: (_compassHeading * (math.pi / 180)),
                                child: const Icon(
                                  Icons.explore_rounded,
                                  color: Color(0xFFFF5252),
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _arahMataAngin,
                                style: const TextStyle(
                                  color: AppTheme.creamWhite,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                              const Text(
                                'Sensor Otomatis (Utara)',
                                style: TextStyle(color: AppTheme.textGrey, fontSize: 8.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Tombol Recenter / Ikuti Saya ala Gojek
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        heroTag: 'recenter_gps_gojek',
                        backgroundColor: _isLiveTrackingFollow ? AppTheme.neonLime : AppTheme.cardSurface,
                        foregroundColor: _isLiveTrackingFollow ? AppTheme.darkForest : AppTheme.creamWhite,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: _isLiveTrackingFollow
                                ? AppTheme.neonLime
                                : AppTheme.emeraldGreen.withValues(alpha: 0.4),
                          ),
                        ),
                        onPressed: () {
                          final target = _currentLiveLocation ?? _selectedPoint;
                          _mapController.move(target, 16.5);
                          setState(() => _isLiveTrackingFollow = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('📍 Mode Ikuti Pengguna Aktif (Live Tracking Gojek)'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Icon(
                          _isLiveTrackingFollow ? Icons.my_location_rounded : Icons.location_searching_rounded,
                          size: 20,
                        ),
                      ),
                    ),

                    // Banner Saran Orientasi Sinar Matahari
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.darkForest.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 14),
                            SizedBox(width: 6),
                            Text(
                              'Orientasi Ideal: Timur-Barat',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Panel Informasi Alamat & Rekomendasi di Bawah Peta
                    Positioned(
                      bottom: 14,
                      left: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF143E33),
                              Color(0xFF0C2720),
                              Color(0xFF071B15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.emeraldGreen.withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.place_rounded,
                                      color: AppTheme.neonLime,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Titik Lahan Terpilih:',
                                      style: TextStyle(
                                        color: AppTheme.creamWhite,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                                // Koordinat Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkForest,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${_selectedPoint.latitude.toStringAsFixed(4)}, ${_selectedPoint.longitude.toStringAsFixed(4)}',
                                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoadingLocation ? 'Mengambil koordinat GPS...' : _currentAddress,
                              style: TextStyle(
                                color: AppTheme.pastelLime.withValues(alpha: 0.85),
                                fontSize: 11.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Tombol Rekomendasi Buah & IoT
                                Expanded(
                                  child: SizedBox(
                                    height: 42,
                                    child: OutlinedButton.icon(
                                      onPressed: _showRecommendationsBottomSheet,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.neonLime,
                                        side: const BorderSide(color: AppTheme.neonLime),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.tips_and_updates_rounded, size: 16),
                                      label: const Text(
                                        'Rekomendasi Buah & IoT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Tombol Tambah Lahan
                                Expanded(
                                  child: SizedBox(
                                    height: 42,
                                    child: ElevatedButton.icon(
                                      onPressed: _showAddDialog,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.neonLime,
                                        foregroundColor: AppTheme.darkForest,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(Icons.add_business_rounded, size: 16),
                                      label: const Text(
                                        'Simpan Lahan',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
