import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_sub_app_bar.dart';

class JadwalTanamPage extends StatefulWidget {
  const JadwalTanamPage({super.key});

  @override
  State<JadwalTanamPage> createState() => _JadwalTanamPageState();
}

class _JadwalTanamPageState extends State<JadwalTanamPage> {
  int _selectedFilter = 0;

  final List<Map<String, dynamic>> _schedules = [
    {
      'title': 'Pemupukan NPK Cair AB Mix',
      'location': 'Greenhouse A • Tomat Hidroponik',
      'time': 'Hari ini, 08:30 WIB',
      'status': 'Prioritas',
      'statusColor': const Color(0xFFFFA726),
      'icon': Icons.water_drop_rounded,
      'isCompleted': false,
    },
    {
      'title': 'Pengecekan pH & EC Tandon Nutrisi',
      'location': 'Greenhouse B • Selada Romaine',
      'time': 'Hari ini, 15:00 WIB',
      'status': 'Terjadwal',
      'statusColor': AppTheme.neonLime,
      'icon': Icons.science_rounded,
      'isCompleted': false,
    },
    {
      'title': 'Pemangkasan Tunas Air (Pruning)',
      'location': 'Greenhouse A • Melon Golden',
      'time': 'Besok, 07:00 WIB',
      'status': 'Mendatang',
      'statusColor': const Color(0xFF29B6F6),
      'icon': Icons.content_cut_rounded,
      'isCompleted': false,
    },
    {
      'title': 'Panen Raya Perdana Batch #2',
      'location': 'Greenhouse C • Cabai Rawit',
      'time': '3 Hari Lagi, 06:30 WIB',
      'status': 'Panen',
      'statusColor': const Color(0xFF2ECC71),
      'icon': Icons.shopping_basket_rounded,
      'isCompleted': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              CustomSubAppBar(
                title: 'Jadwal Tanam',
                subtitle: 'Kalender Perawatan & Siklus Panen Lahan',
                trailing: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sinkronisasi zona waktu otomatis aktif (FR-07)'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
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
                      Icons.today_rounded,
                      color: AppTheme.neonLime,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    _buildFilterChip(0, 'Semua Tugas'),
                    const SizedBox(width: 8),
                    _buildFilterChip(1, 'Hari Ini (2)'),
                    const SizedBox(width: 8),
                    _buildFilterChip(2, 'Minggu Ini'),
                  ],
                ),
              ),

              // List Jadwal Cards
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: _schedules.length,
                  itemBuilder: (ctx, idx) {
                    final item = _schedules[idx];
                    final isDone = item['isCompleted'] as bool;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: (item['statusColor'] as Color)
                              .withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                item['isCompleted'] = !isDone;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone
                                    ? AppTheme.neonLime
                                    : Colors.transparent,
                                border: Border.all(
                                  color: AppTheme.neonLime,
                                  width: 2,
                                ),
                              ),
                              child: isDone
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: AppTheme.darkForest,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: TextStyle(
                                    color: isDone
                                        ? AppTheme.textGrey
                                        : AppTheme.creamWhite,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['location'],
                                  style: const TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 12,
                                      color: AppTheme.pastelLime.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      item['time'],
                                      style: TextStyle(
                                        color: AppTheme.pastelLime.withValues(alpha: 0.8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (item['statusColor'] as Color)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['status'],
                              style: TextStyle(
                                color: item['statusColor'],
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tambah Jadwal Tanam Baru'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: AppTheme.neonLime,
        foregroundColor: AppTheme.darkForest,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Jadwal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonLime : AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.neonLime
                : AppTheme.emeraldGreen.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.darkForest : AppTheme.creamWhite,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }
}
