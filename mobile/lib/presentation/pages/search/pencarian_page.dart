import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/custom_sub_app_bar.dart';
import '../../../data/local_db/database_helper.dart';

class PencarianPage extends StatefulWidget {
  const PencarianPage({super.key});

  @override
  State<PencarianPage> createState() => _PencarianPageState();
}

class _PencarianPageState extends State<PencarianPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterCategory = 'Semua';
  List<Map<String, dynamic>> _dbResults = [];
  bool _isLoadingDb = false;

  final List<Map<String, String>> _agronomyData = const [
    {
      'title': 'Kutu Kebul (Bemisia tabaci)',
      'category': 'Hama & Penyakit',
      'solution': 'Semprotkan pestisida nabati daun nimba atau pasang sticky trap kuning di ventilasi.',
      'tag': 'Hama',
    },
    {
      'title': 'Nutrisi AB Mix Daun',
      'category': 'Nutrisi',
      'solution': 'Konsentrasi EC 1.8 - 2.2 mS/cm ideal untuk fase vegetatif selada, pakcoy, dan bayam.',
      'tag': 'Pupuk',
    },
    {
      'title': 'Busuk Ujung Buah (Blossom End Rot)',
      'category': 'Hama & Penyakit',
      'solution': 'Defisiensi kalsium (Ca) akibat fluktuasi kelembapan. Tambahkan kalsium nitrat terlarut.',
      'tag': 'Penyakit',
    },
    {
      'title': 'Pakcoy Nauli F1',
      'category': 'Varietas',
      'solution': 'Varietas tahan panas dan cocok untuk rakit apung maupun pipa talang NFT.',
      'tag': 'Bibit',
    },
    {
      'title': 'Melon Golden Emerald',
      'category': 'Varietas',
      'solution': 'Varietas melon unggul manis brix 14%, membutuhkan pH 6.2 - 6.8 dan sirkulasi udara baik.',
      'tag': 'Riset Unggul',
    },
    {
      'title': 'Mint Hijau (Spearmint)',
      'category': 'Herbal',
      'solution': 'Tumbuh subur pada media cocopeat lembap dengan pencahayaan parsial teduh.',
      'tag': 'Herbal',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchDatabase(''));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _searchDatabase(String query) async {
    final user = context.read<AuthProvider>().currentUser;
    final userId = user?.id ?? 1;

    setState(() => _isLoadingDb = true);
    final results = await DatabaseHelper.instance.searchGreenhouseAndPlants(userId, query);
    if (mounted) {
      setState(() {
        _dbResults = results;
        _isLoadingDb = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.toLowerCase();

    // Filter Agronomy knowledge
    final filteredAgro = _agronomyData.where((item) {
      final matchesQuery = query.isEmpty ||
          item['title']!.toLowerCase().contains(query) ||
          item['solution']!.toLowerCase().contains(query);
      final matchesCat = _filterCategory == 'Semua' ||
          item['category'] == _filterCategory;
      return matchesQuery && matchesCat;
    }).map((item) => {
      'title': item['title']!,
      'subtitle': item['solution']!,
      'category': item['category']!,
      'tag': item['tag']!,
      'isFromDb': false,
    }).toList();

    // Filter DB results (Greenhouse & Tanaman)
    final filteredDb = _dbResults.where((item) {
      final cat = item['kategori']?.toString() ?? 'Lahan';
      final matchesCat = _filterCategory == 'Semua' ||
          _filterCategory == cat ||
          (_filterCategory == 'Lahan Saya' && (cat == 'Greenhouse' || cat == 'Tanaman'));
      return matchesCat;
    }).map((item) => {
      'title': item['judul']?.toString() ?? '',
      'subtitle': item['subjudul']?.toString() ?? '',
      'category': item['kategori']?.toString() ?? 'Lahan',
      'tag': item['tag']?.toString() ?? 'SQLite',
      'isFromDb': true,
    }).toList();

    final allItems = [...filteredDb, ...filteredAgro];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const CustomSubAppBar(
                title: 'Pencarian & Filter',
                subtitle: 'Eksplorasi Lahan, Varietas, & Solusi Hama (FR-11)',
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                    onChanged: (val) {
                      _searchDatabase(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari greenhouse, varietas, hama, nutrisi...',
                      hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 12.5),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.neonLime),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppTheme.textGrey, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _searchDatabase('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

              // Category Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    'Semua',
                    'Lahan Saya',
                    'Varietas',
                    'Hama & Penyakit',
                    'Nutrisi',
                    'Herbal',
                  ].map((cat) {
                    final isSel = _filterCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _filterCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppTheme.neonLime : AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? AppTheme.neonLime : AppTheme.emeraldGreen.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSel ? AppTheme.darkForest : AppTheme.creamWhite,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // Results
              Expanded(
                child: _isLoadingDb
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.neonLime))
                    : allItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textGrey.withValues(alpha: 0.5)),
                                const SizedBox(height: 10),
                                const Text(
                                  'Tidak ada data yang cocok dengan pencarian.',
                                  style: TextStyle(color: AppTheme.creamWhite, fontSize: 13.5),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: allItems.length,
                            itemBuilder: (ctx, idx) {
                              final item = allItems[idx];
                              final isFromDb = item['isFromDb'] as bool? ?? false;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardSurface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isFromDb
                                        ? AppTheme.neonLime.withValues(alpha: 0.4)
                                        : AppTheme.emeraldGreen.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              if (isFromDb) ...[
                                                const Icon(Icons.storage_rounded, size: 15, color: AppTheme.neonLime),
                                                const SizedBox(width: 6),
                                              ],
                                              Expanded(
                                                child: Text(
                                                  item['title'] as String,
                                                  style: const TextStyle(
                                                    color: AppTheme.creamWhite,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isFromDb
                                                ? AppTheme.neonLime.withValues(alpha: 0.15)
                                                : const Color(0xFF29B6F6).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: isFromDb
                                                  ? AppTheme.neonLime.withValues(alpha: 0.4)
                                                  : const Color(0xFF29B6F6).withValues(alpha: 0.4),
                                            ),
                                          ),
                                          child: Text(
                                            item['tag'] as String,
                                            style: TextStyle(
                                              color: isFromDb ? AppTheme.neonLime : const Color(0xFF29B6F6),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['subtitle'] as String,
                                      style: TextStyle(
                                        color: AppTheme.pastelLime.withValues(alpha: 0.85),
                                        fontSize: 12,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
