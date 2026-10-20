import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_sub_app_bar.dart';

class PencarianPage extends StatefulWidget {
  const PencarianPage({super.key});

  @override
  State<PencarianPage> createState() => _PencarianPageState();
}

class _PencarianPageState extends State<PencarianPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterCategory = 'Semua';

  final List<Map<String, String>> _allData = const [
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
      'category': 'Sayuran',
      'solution': 'Varietas tahan panas dan cocok untuk rakit apung maupun pipa talang NFT.',
      'tag': 'Bibit',
    },
    {
      'title': 'Mint Hijau (Spearmint)',
      'category': 'Herbal',
      'solution': 'Tumbuh subur pada media cocopeat lembap dengan pencahayaan parsial teduh.',
      'tag': 'Herbal',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.toLowerCase();
    final filtered = _allData.where((item) {
      final matchesQuery = query.isEmpty ||
          item['title']!.toLowerCase().contains(query) ||
          item['solution']!.toLowerCase().contains(query);
      final matchesCat = _filterCategory == 'Semua' ||
          item['category'] == _filterCategory;
      return matchesQuery && matchesCat;
    }).toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const CustomSubAppBar(
                title: 'Pencarian Tanaman',
                subtitle: 'Eksplorasi Hama, Penyakit, & Solusi Nutrisi',
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
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari nama tanaman, hama, pupuk...',
                      hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 12.5),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.neonLime),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppTheme.textGrey, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() {});
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
                    'Hama & Penyakit',
                    'Nutrisi',
                    'Sayuran',
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
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textGrey.withValues(alpha: 0.5)),
                            const SizedBox(height: 10),
                            const Text(
                              'Tidak ada data yang cocok',
                              style: TextStyle(color: AppTheme.creamWhite, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, idx) {
                          final item = filtered[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                        item['title']!,
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
                                        color: AppTheme.neonLime.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['tag']!,
                                        style: const TextStyle(
                                          color: AppTheme.neonLime,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['solution']!,
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
