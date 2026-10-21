import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/local_db/database_helper.dart';
import '../../widgets/custom_sub_app_bar.dart';

enum ScheduleSortOption {
  timeAsc,
  timeDesc,
  priority,
  alphabetical,
}

class JadwalTanamPage extends StatefulWidget {
  const JadwalTanamPage({super.key});

  @override
  State<JadwalTanamPage> createState() => _JadwalTanamPageState();
}

class _JadwalTanamPageState extends State<JadwalTanamPage> {
  int _selectedFilter = 0; // 0: Semua, 1: Hari Ini, 2: Belum Selesai, 3: Selesai
  ScheduleSortOption _currentSort = ScheduleSortOption.timeAsc;
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedulesFromDB();
  }

  Future<void> _loadSchedulesFromDB() async {
    setState(() => _isLoading = true);
    try {
      final list = await DatabaseHelper.instance.getAllJadwalList();
      if (mounted) {
        setState(() {
          _schedules = List<Map<String, dynamic>>.from(list);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAndSortedSchedules {
    final now = DateTime.now();
    List<Map<String, dynamic>> result = _schedules.where((item) {
      final isDone = item['status'] == 'Selesai';
      final waktuStr = item['waktu_utc'] as String? ?? '';
      final itemDate = DateTime.tryParse(waktuStr)?.toLocal() ?? now;

      if (_selectedFilter == 1) {
        // Hari Ini
        return itemDate.year == now.year &&
            itemDate.month == now.month &&
            itemDate.day == now.day;
      } else if (_selectedFilter == 2) {
        // Belum Selesai
        return !isDone;
      } else if (_selectedFilter == 3) {
        // Selesai
        return isDone;
      }
      return true; // Semua
    }).toList();

    // Sorting
    result.sort((a, b) {
      final aTime = DateTime.tryParse(a['waktu_utc'] as String? ?? '') ?? now;
      final bTime = DateTime.tryParse(b['waktu_utc'] as String? ?? '') ?? now;
      final aStatus = a['status'] as String? ?? '';
      final bStatus = b['status'] as String? ?? '';
      final aTitle = a['jenis_perawatan'] as String? ?? '';
      final bTitle = b['jenis_perawatan'] as String? ?? '';

      switch (_currentSort) {
        case ScheduleSortOption.timeAsc:
          return aTime.compareTo(bTime);
        case ScheduleSortOption.timeDesc:
          return bTime.compareTo(aTime);
        case ScheduleSortOption.priority:
          final pMap = {'Prioritas': 0, 'Panen': 1, 'Terjadwal': 2, 'Mendatang': 3, 'Selesai': 4};
          return (pMap[aStatus] ?? 99).compareTo(pMap[bStatus] ?? 99);
        case ScheduleSortOption.alphabetical:
          return aTitle.compareTo(bTitle);
      }
    });

    return result;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Prioritas':
        return const Color(0xFFFFA726);
      case 'Terjadwal':
        return AppTheme.neonLime;
      case 'Mendatang':
        return const Color(0xFF29B6F6);
      case 'Panen':
        return const Color(0xFF2ECC71);
      case 'Selesai':
        return AppTheme.textGrey;
      default:
        return AppTheme.neonLime;
    }
  }

  IconData _getScheduleIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('pupuk') || lower.contains('nutrisi')) {
      return Icons.water_drop_rounded;
    } else if (lower.contains('ph') || lower.contains('ec') || lower.contains('cek')) {
      return Icons.science_rounded;
    } else if (lower.contains('pangkas') || lower.contains('prun')) {
      return Icons.content_cut_rounded;
    } else if (lower.contains('panen')) {
      return Icons.shopping_basket_rounded;
    } else if (lower.contains('siram')) {
      return Icons.shower_rounded;
    }
    return Icons.eco_rounded;
  }

  String _formatTimeDisplay(String? waktuUtc) {
    if (waktuUtc == null || waktuUtc.isEmpty) return 'Hari ini';
    final date = DateTime.tryParse(waktuUtc)?.toLocal();
    if (date == null) return waktuUtc;

    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isTomorrow = date.year == now.year &&
        date.month == now.month &&
        date.day == now.add(const Duration(days: 1)).day;

    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');

    if (isToday) {
      return 'Hari ini, $hour:$min WIB';
    } else if (isTomorrow) {
      return 'Besok, $hour:$min WIB';
    } else {
      return '${date.day}/${date.month}/${date.year}, $hour:$min WIB';
    }
  }

  Future<void> _toggleScheduleStatus(int id, bool currentlyDone) async {
    final newStatus = currentlyDone ? 'Terjadwal' : 'Selesai';
    await DatabaseHelper.instance.updateJadwalStatus(id, newStatus);
    await _loadSchedulesFromDB();
  }

  Future<void> _deleteSchedule(int id) async {
    await DatabaseHelper.instance.deleteJadwal(id);
    await NotificationService.instance.cancelNotification(id);
    await _loadSchedulesFromDB();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal dan pengingat berhasil dihapus.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 16),
              const Text(
                'Urutkan Jadwal Tanam',
                style: TextStyle(
                  color: AppTheme.creamWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _buildSortItem(
                label: 'Waktu Terdekat (Mendekati sekarang)',
                option: ScheduleSortOption.timeAsc,
                icon: Icons.arrow_upward_rounded,
              ),
              _buildSortItem(
                label: 'Waktu Terjauh (Masa depan)',
                option: ScheduleSortOption.timeDesc,
                icon: Icons.arrow_downward_rounded,
              ),
              _buildSortItem(
                label: 'Prioritas Tertinggi (Urgensi)',
                option: ScheduleSortOption.priority,
                icon: Icons.flag_rounded,
              ),
              _buildSortItem(
                label: 'Nama Kegiatan (A-Z)',
                option: ScheduleSortOption.alphabetical,
                icon: Icons.sort_by_alpha_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortItem({
    required String label,
    required ScheduleSortOption option,
    required IconData icon,
  }) {
    final isSelected = _currentSort == option;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.neonLime : AppTheme.textGrey,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppTheme.neonLime : AppTheme.creamWhite,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13.5,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppTheme.neonLime)
          : null,
      onTap: () {
        setState(() => _currentSort = option);
        Navigator.pop(context);
      },
    );
  }

  void _showAddScheduleBottomSheet() {
    final titleCtrl = TextEditingController();
    final locationCtrl = TextEditingController(text: 'Greenhouse A • Tomat Hidroponik');
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);
    String selectedPriority = 'Prioritas';

    final presetTasks = [
      'Pemupukan NPK Cair AB Mix',
      'Penyiraman & Nutrisi Tandon',
      'Pengecekan pH & EC Air',
      'Pemangkasan Tunas Air (Pruning)',
      'Semprot Mist Pendingin',
      'Panen Raya Buah',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.add_task_rounded, color: AppTheme.neonLime, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Tambah Jadwal & Notifikasi Otomatis',
                      style: TextStyle(
                        color: AppTheme.creamWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Pengingat alarm otomatis akan dikirim ke status bar HP saat waktu tiba.',
                  style: TextStyle(
                    color: AppTheme.pastelLime.withValues(alpha: 0.8),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Pilihan Cepat Tugas
                const Text(
                  'Pilih Cepat / Ketik Nama Kegiatan:',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: presetTasks.map((task) {
                    return ActionChip(
                      label: Text(
                        task,
                        style: const TextStyle(fontSize: 11, color: AppTheme.creamWhite),
                      ),
                      backgroundColor: const Color(0xFF143B33),
                      side: BorderSide(
                        color: AppTheme.neonLime.withValues(alpha: 0.3),
                      ),
                      onPressed: () {
                        setModalState(() {
                          titleCtrl.text = task;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Text field judul
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: AppTheme.creamWhite),
                  decoration: InputDecoration(
                    labelText: 'Nama Kegiatan / Tugas',
                    labelStyle: const TextStyle(color: AppTheme.textGrey),
                    filled: true,
                    fillColor: const Color(0xFF102E27),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Lokasi Greenhouse
                TextField(
                  controller: locationCtrl,
                  style: const TextStyle(color: AppTheme.creamWhite),
                  decoration: InputDecoration(
                    labelText: 'Lokasi Greenhouse & Blok',
                    labelStyle: const TextStyle(color: AppTheme.textGrey),
                    filled: true,
                    fillColor: const Color(0xFF102E27),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Date & Time Picker
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        icon: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.neonLime,
                          side: BorderSide(
                            color: AppTheme.neonLime.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() => selectedTime = picked);
                          }
                        },
                        icon: const Icon(Icons.access_time_rounded, size: 16),
                        label: Text(
                          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} WIB',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.neonLime,
                          side: BorderSide(
                            color: AppTheme.neonLime.withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Prioritas Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedPriority,
                  dropdownColor: AppTheme.cardSurface,
                  style: const TextStyle(color: AppTheme.creamWhite),
                  decoration: InputDecoration(
                    labelText: 'Status Prioritas',
                    labelStyle: const TextStyle(color: AppTheme.textGrey),
                    filled: true,
                    fillColor: const Color(0xFF102E27),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Prioritas', child: Text('Prioritas Utama')),
                    DropdownMenuItem(value: 'Terjadwal', child: Text('Terjadwal')),
                    DropdownMenuItem(value: 'Mendatang', child: Text('Mendatang')),
                    DropdownMenuItem(value: 'Panen', child: Text('Panen')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => selectedPriority = val);
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Masukkan nama kegiatan terlebih dahulu.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final finalDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      final location = locationCtrl.text.trim().isEmpty
                          ? 'Greenhouse A'
                          : locationCtrl.text.trim();

                      // 1. Simpan ke database lokal SQLite
                      final newId = await DatabaseHelper.instance.insertJadwal({
                        'tanaman_id': 1,
                        'jenis_perawatan': title,
                        'waktu_utc': finalDateTime.toUtc().toIso8601String(),
                        'status': selectedPriority,
                        'catatan': location,
                        'sync_status': 'Menunggu Unggah',
                      });

                      // 2. Jadwalkan Notifikasi Pengingat Otomatis
                      await NotificationService.instance.schedulePlantReminderNotification(
                        id: newId,
                        title: title,
                        body: '📍 $location • Waktunya merawat tanaman sesuai jadwal!',
                        scheduledDate: finalDateTime,
                      );

                      nav.pop();
                      if (!mounted) return;
                      await _loadSchedulesFromDB();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Jadwal perawatan berhasil disimpan & pengingat dipasang.',
                            style: TextStyle(color: AppTheme.darkForest),
                          ),
                          backgroundColor: AppTheme.neonLime,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonLime,
                      foregroundColor: AppTheme.darkForest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.alarm_add_rounded),
                    label: const Text(
                      'Simpan Jadwal & Pasang Pengingat',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredAndSortedSchedules;

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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Sorting
                    GestureDetector(
                      onTap: _showSortMenu,
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
                          Icons.sort_rounded,
                          color: AppTheme.neonLime,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(0, 'Semua Tugas (${_schedules.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip(1, 'Hari Ini'),
                      const SizedBox(width: 8),
                      _buildFilterChip(2, 'Belum Selesai'),
                      const SizedBox(width: 8),
                      _buildFilterChip(3, 'Selesai'),
                    ],
                  ),
                ),
              ),

              // List Jadwal Cards
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.neonLime),
                      )
                    : list.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_available_rounded,
                                  size: 54,
                                  color: AppTheme.textGrey.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tidak ada jadwal tanam yang cocok',
                                  style: TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            itemCount: list.length,
                            itemBuilder: (ctx, idx) {
                              final item = list[idx];
                              final id = item['id'] as int? ?? idx;
                              final title = item['jenis_perawatan'] as String? ?? 'Perawatan Tanaman';
                              final location = item['catatan'] as String? ??
                                  '${item['nama_greenhouse'] ?? 'Greenhouse A'} • ${item['nama_varietas'] ?? 'Melon'}';
                              final waktuUtc = item['waktu_utc'] as String?;
                              final status = item['status'] as String? ?? 'Terjadwal';
                              final isDone = status == 'Selesai';
                              final statusColor = _getStatusColor(status);
                              final icon = _getScheduleIcon(title);

                              return Dismissible(
                                key: Key('schedule_$id'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.only(right: 20),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                                ),
                                onDismissed: (_) => _deleteSchedule(id),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardSurface,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: statusColor.withValues(alpha: 0.35),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _toggleScheduleStatus(id, isDone),
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
                                              title,
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
                                              location,
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
                                                  _formatTimeDisplay(waktuUtc),
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
                                          color: statusColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(icon, size: 12, color: statusColor),
                                            const SizedBox(width: 4),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
        onPressed: _showAddScheduleBottomSheet,
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
