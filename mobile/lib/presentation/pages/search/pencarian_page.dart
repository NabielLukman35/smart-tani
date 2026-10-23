import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database_helper.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/custom_sub_app_bar.dart';
import '../iot/iot_monitoring_page.dart';

class PencarianPage extends StatefulWidget {
  const PencarianPage({super.key});

  @override
  State<PencarianPage> createState() => _PencarianPageState();
}

class _PencarianPageState extends State<PencarianPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  // FR-11 Filter States
  String _selectedVarietas = 'Semua';
  String _selectedStatus = 'Semua';
  String _selectedTingkatHama = 'Semua';

  List<Map<String, dynamic>> _dataList = [];
  bool _isLoading = true;

  final List<String> _varietasOptions = [
    'Semua',
    'Melon Inthanon',
    'Golden Aroma',
    'Rock Melon',
    'Sky Rocket',
  ];

  final List<String> _statusOptions = [
    'Semua',
    'Terjadwal',
    'Selesai',
    'Terlambat',
  ];

  final List<String> _hamaOptions = [
    'Semua',
    'Aman',
    'Rendah',
    'Sedang',
    'Kritis',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? 1;

    // Ambil data greenhouse dan jadwal
    final greenhouses = await DatabaseHelper.instance.getGreenhousesByUser(userId);

    // Siapkan dataset lengkap gabungan
    List<Map<String, dynamic>> combined = [];

    if (greenhouses.isNotEmpty) {
      for (final gh in greenhouses) {
        combined.add({
          'greenhouse_id': gh['id'],
          'nama_greenhouse': gh['nama_greenhouse'] ?? 'Greenhouse #${gh['id']}',
          'kecamatan': gh['alamat']?.toString().split(',').first ?? 'Sleman',
          'alamat_lengkap': gh['alamat'] ?? 'Sleman, D.I. Yogyakarta',
          'luas': gh['luas'] ?? 150,
          'varietas': 'Melon Inthanon RZ',
          'status_perawatan': 'Terjadwal',
          'tingkat_hama': 'Aman',
          'jadwal_info': 'Pemberian nutrisi AB Mix jam 08:00 WIB',
        });
      }
    }

    // Tambahkan dataset varietas & riset melon komprehensif
    final defaultItems = [
      {
        'greenhouse_id': 1,
        'nama_greenhouse': 'Greenhouse Inthanon Prime',
        'kecamatan': 'Ngaglik',
        'alamat_lengkap': 'Jl. Kaliurang KM 12, Ngaglik, Sleman',
        'luas': 250,
        'varietas': 'Melon Inthanon',
        'status_perawatan': 'Terjadwal',
        'tingkat_hama': 'Aman',
        'jadwal_info': 'Pengecekan EC & pH nutrisi drip irrigation',
      },
      {
        'greenhouse_id': 2,
        'nama_greenhouse': 'Greenhouse Golden Aroma YK',
        'kecamatan': 'Depok',
        'alamat_lengkap': 'Maguwoharjo, Depok, Sleman',
        'luas': 180,
        'varietas': 'Golden Aroma',
        'status_perawatan': 'Terlambat',
        'tingkat_hama': 'Sedang',
        'jadwal_info': 'Penyemprotan biopestisida pencegahan kutu kebul',
      },
      {
        'greenhouse_id': 3,
        'nama_greenhouse': 'Greenhouse Rock Melon Lestari',
        'kecamatan': 'Pakem',
        'alamat_lengkap': 'Jl. Boyong, Pakem, Sleman',
        'luas': 300,
        'varietas': 'Rock Melon',
        'status_perawatan': 'Selesai',
        'tingkat_hama': 'Rendah',
        'jadwal_info': 'Polinasi bunga betina & seleksi 1 buah per pohon',
      },
      {
        'greenhouse_id': 4,
        'nama_greenhouse': 'Smart Greenhouse Sky Rocket',
        'kecamatan': 'Mlati',
        'alamat_lengkap': 'Sendangadi, Mlati, Sleman',
        'luas': 200,
        'varietas': 'Sky Rocket',
        'status_perawatan': 'Terjadwal',
        'tingkat_hama': 'Kritis',
        'jadwal_info': 'Penanganan isolasi bercak daun antraknosa',
      },
    ];

    combined.addAll(defaultItems);

    if (mounted) {
      setState(() {
        _dataList = combined;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.toLowerCase().trim();

    // FR-11: Filter berdasarkan nama greenhouse, varietas, kecamatan, status perawatan, & tingkat hama
    final filtered = _dataList.where((item) {
      final namaGh = (item['nama_greenhouse'] ?? '').toString().toLowerCase();
      final varietas = (item['varietas'] ?? '').toString().toLowerCase();
      final kecamatan = (item['kecamatan'] ?? '').toString().toLowerCase();
      final status = (item['status_perawatan'] ?? '').toString();
      final hama = (item['tingkat_hama'] ?? '').toString();

      final matchesQuery = query.isEmpty ||
          namaGh.contains(query) ||
          varietas.contains(query) ||
          kecamatan.contains(query);

      final matchesVarietas = _selectedVarietas == 'Semua' ||
          varietas.contains(_selectedVarietas.toLowerCase());

      final matchesStatus =
          _selectedStatus == 'Semua' || status == _selectedStatus;

      final matchesHama =
          _selectedTingkatHama == 'Semua' || hama == _selectedTingkatHama;

      return matchesQuery && matchesVarietas && matchesStatus && matchesHama;
    }).toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.ground,
        child: SafeArea(
          child: Column(
            children: [
              const CustomSubAppBar(
                title: 'Pencarian & Filter',
                subtitle: 'Greenhouse, Varietas Melon, & Status Perawatan (FR-11)',
              ),

              // Search Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.inputFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.45),
                    ),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: AppTheme.creamWhite, fontSize: 13.5),
                    cursorColor: AppTheme.neonLime,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari greenhouse, varietas melon, atau kecamatan...',
                      hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.neonLime),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: AppTheme.textGrey, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                    ),
                  ),
                ),
              ),

              // Filter Chips Bar (Varietas, Status, Tingkat Hama)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    _buildDropdownFilter(
                      label: 'Varietas: $_selectedVarietas',
                      items: _varietasOptions,
                      selected: _selectedVarietas,
                      onChanged: (val) => setState(() => _selectedVarietas = val!),
                    ),
                    const SizedBox(width: 8),
                    _buildDropdownFilter(
                      label: 'Status: $_selectedStatus',
                      items: _statusOptions,
                      selected: _selectedStatus,
                      onChanged: (val) => setState(() => _selectedStatus = val!),
                    ),
                    const SizedBox(width: 8),
                    _buildDropdownFilter(
                      label: 'Hama: $_selectedTingkatHama',
                      items: _hamaOptions,
                      selected: _selectedTingkatHama,
                      onChanged: (val) => setState(() => _selectedTingkatHama = val!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Header Hasil
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ditemukan ${filtered.length} Data',
                      style: const TextStyle(
                        color: AppTheme.pastelLime,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_selectedVarietas != 'Semua' ||
                        _selectedStatus != 'Semua' ||
                        _selectedTingkatHama != 'Semua' ||
                        _searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchCtrl.clear();
                            _selectedVarietas = 'Semua';
                            _selectedStatus = 'Semua';
                            _selectedTingkatHama = 'Semua';
                          });
                        },
                        child: const Text(
                          'Reset Filter',
                          style: TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // List Hasil Pencarian
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.neonLime),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off_rounded,
                                    size: 48, color: AppTheme.textGrey),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tidak ada data yang cocok dengan kriteria.',
                                  style: TextStyle(
                                      color: AppTheme.textGrey, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Coba cari dengan nama kecamatan atau jenis varietas lain.',
                                  style: TextStyle(
                                      color: AppTheme.textGrey.withValues(alpha: 0.6),
                                      fontSize: 11),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (ctx, idx) {
                              final item = filtered[idx];
                              return _buildCardItem(item);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required List<String> items,
    required String selected,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected != 'Semua'
              ? AppTheme.neonLime
              : AppTheme.emeraldGreen.withValues(alpha: 0.35),
          width: selected != 'Semua' ? 1.4 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isDense: true,
          dropdownColor: AppTheme.cardSurface,
          icon: const Icon(Icons.arrow_drop_down_rounded,
              color: AppTheme.neonLime, size: 20),
          style: const TextStyle(
            color: AppTheme.creamWhite,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
          onChanged: onChanged,
          items: items.map((val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> item) {
    final status = item['status_perawatan'] ?? 'Terjadwal';
    final hama = item['tingkat_hama'] ?? 'Aman';

    Color statusColor = AppTheme.neonLime;
    if (status == 'Terlambat') statusColor = const Color(0xFFFF5252);
    if (status == 'Selesai') statusColor = const Color(0xFF2ECC71);

    Color hamaColor = const Color(0xFF2ECC71);
    if (hama == 'Sedang') hamaColor = Colors.amber;
    if (hama == 'Kritis') hamaColor = const Color(0xFFFF5252);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
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
                  item['nama_greenhouse'] ?? '',
                  style: const TextStyle(
                    color: AppTheme.creamWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppTheme.neonLime, size: 14),
              const SizedBox(width: 4),
              Text(
                'Kecamatan ${item['kecamatan']} ΓÇó Luas ${item['luas']} m┬▓',
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.darkForest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('≡ƒìê', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Varietas: ${item['varietas']}',
                        style: const TextStyle(
                          color: AppTheme.pastelLime,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['jadwal_info'] ?? '',
                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Tingkat Hama: ',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 11.5)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: hamaColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hama,
                      style: TextStyle(
                        color: hamaColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IotMonitoringPage(
                        greenhouse: {
                          'id': item['greenhouse_id'] ?? 1,
                          'nama_greenhouse': item['nama_greenhouse'],
                          'alamat': item['alamat_lengkap'],
                          'luas': item['luas'],
                          'batas_suhu_maks': 35.0,
                          'batas_lembap_min': 40.0,
                          'biaya_operasional_idr': 1500000.0,
                        },
                        userId: context.read<AuthProvider>().currentUser?.id ?? 1,
                      ),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Monitoring IoT',
                      style: TextStyle(
                        color: AppTheme.neonLime,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: AppTheme.neonLime, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
