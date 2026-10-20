import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_providers.dart';
import '../../providers/greenhouse_providers.dart';
import '../../../data/models/greenhouse_model.dart';
import '../../../core/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user?.id != null) {
        context.read<GreenhouseProvider>().loadGreenhouses(user!.id!);
      }
      _getCurrentLocation();
    });
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
        setState(() => _selectedPoint = newPoint);
        _mapController.move(newPoint, 16.0);
        await _updateAddress(newPoint);
      }
    } catch (e) {
      debugPrint('Error GPS: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _updateAddress(LatLng point) async {
    setState(() => _currentAddress = 'Mencari alamat...');
    final address = await context
        .read<GreenhouseProvider>()
        .getAddressFromLatLng(point.latitude, point.longitude);
    if (mounted) {
      setState(() => _currentAddress = address);
    }
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

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final luasCtrl = TextEditingController();
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
            'Tambah Titik Greenhouse',
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
                  luas: double.tryParse(luasCtrl.text) ?? 0.0,
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
                title: 'Peta & Lokasi Greenhouse',
                subtitle: 'Pemetaan Lahan & GPS Presisi',
                trailing: GestureDetector(
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
                      size: 20,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedPoint,
                        initialZoom: 15.0,
                        onTap: (tapPosition, point) {
                          setState(() => _selectedPoint = point);
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
                                          '${gh.namaGreenhouse} (${gh.status}) - [${gh.syncStatus}]',
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

                    // Panel Informasi Alamat di Bawah Peta
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
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
                            const Row(
                              children: [
                                Icon(
                                  Icons.place_rounded,
                                  color: AppTheme.neonLime,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Titik Pin Terpilih:',
                                  style: TextStyle(
                                    color: AppTheme.creamWhite,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoadingLocation ? 'Mengambil koordinat GPS...' : _currentAddress,
                              style: TextStyle(
                                color: AppTheme.pastelLime.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton.icon(
                                onPressed: _showAddDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.neonLime,
                                  foregroundColor: AppTheme.darkForest,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.add_business_rounded, size: 18),
                                label: const Text(
                                  'Tambah Greenhouse di Titik Ini',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
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