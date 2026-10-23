import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/timezone_helper.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/local_db/database_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_sub_app_bar.dart';

class IotMonitoringPage extends StatefulWidget {
  final Map<String, dynamic> greenhouse;
  final int userId;

  const IotMonitoringPage({
    super.key,
    required this.greenhouse,
    required this.userId,
  });

  @override
  State<IotMonitoringPage> createState() => _IotMonitoringPageState();
}

class _IotMonitoringPageState extends State<IotMonitoringPage> {
  late double _biayaIdr;
  late double _batasSuhuMaks;
  late double _batasLembapMin;

  String _selectedZone = 'WIB'; // Pilihan FR-07: WIB, WITA, WIT, London
  bool _isLoadingRates = true;
  List<Map<String, dynamic>> _sensorLogs = [];
  bool _isAutoPeriodicNotification = false;

  @override
  void initState() {
    super.initState();
    TimezoneHelper.init();
    _biayaIdr = (widget.greenhouse['biaya_operasional_idr'] as num?)?.toDouble() ?? 1500000.0;
    _batasSuhuMaks = (widget.greenhouse['batas_suhu_maks'] as num?)?.toDouble() ?? 35.0;
    _batasLembapMin = (widget.greenhouse['batas_lembap_min'] as num?)?.toDouble() ?? 40.0;

    _initData();
  }

  Future<void> _initData() async {
    await CurrencyHelper.fetchRates();
    await _loadSensorLogs();
    final prefs = await SharedPreferences.getInstance();
    final autoNotif = prefs.getBool('auto_periodic_notification') ?? false;
    if (mounted) {
      setState(() {
        _isAutoPeriodicNotification = autoNotif;
        _isLoadingRates = false;
      });
    }
  }

  Future<void> _loadSensorLogs() async {
    final ghId = widget.greenhouse['id'] as int? ?? 1;
    final logs = await DatabaseHelper.instance.getSensorLogsByGreenhouse(ghId);
    if (mounted) {
      setState(() => _sensorLogs = logs);
    }
  }

  /// FR-08 & FR-12: Simulasi kiriman data sensor IoT + trigger notifikasi status bar
  Future<void> _simulateIncomingSensorData() async {
    final rand = Random();
    final double suhu = double.parse((26 + rand.nextDouble() * 12).toStringAsFixed(1));
    final double lembapUdara = double.parse((50 + rand.nextDouble() * 35).toStringAsFixed(1));
    final double lembapTanah = double.parse((30 + rand.nextDouble() * 50).toStringAsFixed(1));
    final double cahaya = double.parse((300 + rand.nextDouble() * 700).toStringAsFixed(0));
    final String nowUtc = DateTime.now().toUtc().toIso8601String();
    final ghId = widget.greenhouse['id'] as int? ?? 1;

    await DatabaseHelper.instance.insertSensorLog({
      'greenhouse_id': ghId,
      'suhu': suhu,
      'kelembapan_udara': lembapUdara,
      'kelembapan_tanah': lembapTanah,
      'cahaya': cahaya,
      'waktu_utc': nowUtc,
      'sync_status': 'Menunggu Unggah',
    });

    List<String> alerts = [];
    if (suhu > _batasSuhuMaks) {
      alerts.add('Suhu terlalu tinggi ($suhu°C > $_batasSuhuMaks°C)');
    }
    if (lembapTanah < _batasLembapMin) {
      alerts.add('Kelembapan tanah kering ($lembapTanah% < $_batasLembapMin%)');
    }

    final ghName = widget.greenhouse['nama_greenhouse'] ?? 'Greenhouse Utama';

    // FR-12: Kirim notifikasi nyata ke status bar Android
    await NotificationService.instance.showTelemetryNotification(
      greenhouseName: ghName,
      suhu: suhu,
      lembapTanah: lembapTanah,
      lembapUdara: lembapUdara,
      cahaya: cahaya,
    );

    if (alerts.isNotEmpty) {
      final pesanNotif = '[PERINGATAN IoT - $ghName] ${alerts.join(', ')}';
      await DatabaseHelper.instance.insertNotifikasi({
        'pengguna_id': widget.userId,
        'greenhouse_id': ghId,
        'pesan': pesanNotif,
        'dibaca': 0,
        'waktu': nowUtc,
      });

      // FR-12: Trigger Notifikasi Lokal Tanpa Firebase
      try {
        await NotificationService().showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: '⚠️ Peringatan Sensor: $ghName',
          body: alerts.join(', '),
        );
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFE74C3C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(pesanNotif, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        );
      }
    }

    await _loadSensorLogs();
  }

  void _showSettingsDialog() {
    final biayaCtrl = TextEditingController(text: _biayaIdr.toStringAsFixed(0));
    final suhuCtrl = TextEditingController(text: _batasSuhuMaks.toString());
    final lembapCtrl = TextEditingController(text: _batasLembapMin.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
        ),
        title: const Text(
          'Pengaturan Biaya & Ambang IoT',
          style: TextStyle(color: AppTheme.creamWhite, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: biayaCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.creamWhite),
                decoration: const InputDecoration(
                  labelText: 'Estimasi Biaya Operasional (IDR)',
                  labelStyle: TextStyle(color: AppTheme.textGrey),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: suhuCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.creamWhite),
                decoration: const InputDecoration(
                  labelText: 'Batas Suhu Maksimum (°C)',
                  labelStyle: TextStyle(color: AppTheme.textGrey),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lembapCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.creamWhite),
                decoration: const InputDecoration(
                  labelText: 'Batas Kelembapan Tanah Minimum (%)',
                  labelStyle: TextStyle(color: AppTheme.textGrey),
                ),
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
              final newBiaya = double.tryParse(biayaCtrl.text) ?? _biayaIdr;
              final newSuhu = double.tryParse(suhuCtrl.text) ?? _batasSuhuMaks;
              final newLembap = double.tryParse(lembapCtrl.text) ?? _batasLembapMin;
              final ghId = widget.greenhouse['id'] as int? ?? 1;

              await DatabaseHelper.instance.updateGreenhouse(
                ghId,
                {
                  'biaya_operasional_idr': newBiaya,
                  'batas_suhu_maks': newSuhu,
                  'batas_lembap_min': newLembap,
                  'sync_status': 'Menunggu Unggah',
                },
              );

              setState(() {
                _biayaIdr = newBiaya;
                _batasSuhuMaks = newSuhu;
                _batasLembapMin = newLembap;
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonLime,
              foregroundColor: AppTheme.darkForest,
            ),
            child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latestLog = _sensorLogs.isNotEmpty ? _sensorLogs.first : null;
    final ghName = widget.greenhouse['nama_greenhouse'] ?? 'Greenhouse';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.ground,
        child: SafeArea(
          child: Column(
            children: [
              CustomSubAppBar(
                title: 'IoT & Biaya: $ghName',
                subtitle: 'Telemetri Sensor, Multivaluta & Multizona',
                trailing: GestureDetector(
                  onTap: _showSettingsDialog,
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
                      Icons.settings_rounded,
                      color: AppTheme.neonLime,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    // KARTU FR-06: KONVERSI MATA UANG
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.panel,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Estimasi Biaya Operasional (FR-06)',
                                style: TextStyle(
                                  color: AppTheme.creamWhite,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5,
                                ),
                              ),
                              if (_isLoadingRates)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.neonLime,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CurrencyHelper.formatIdr(_biayaIdr),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.neonLime,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Divider(color: AppTheme.emeraldGreen.withValues(alpha: 0.3)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCurrencyItem('USD', CurrencyHelper.convertAndFormat(_biayaIdr, 'USD')),
                              _buildCurrencyItem('EUR', CurrencyHelper.convertAndFormat(_biayaIdr, 'EUR')),
                              _buildCurrencyItem('GBP', CurrencyHelper.convertAndFormat(_biayaIdr, 'GBP')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // KARTU FR-08 & FR-12: MONITORING SENSOR IoT & NOTIFIKASI
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Status Sensor IoT Terkini (FR-08)',
                                style: TextStyle(
                                  color: AppTheme.creamWhite,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonLime.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'IoT Aktif',
                                  style: TextStyle(color: AppTheme.neonLime, fontSize: 10.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ambang Batas: Suhu Maks $_batasSuhuMaks°C | Lembap Tanah Min $_batasLembapMin%',
                            style: const TextStyle(fontSize: 11.5, color: AppTheme.textGrey),
                          ),
                          const SizedBox(height: 14),
                          if (latestLog == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text(
                                  'Belum ada data sensor masuk.\nKetuk tombol di bawah untuk simulasi IoT.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                                ),
                              ),
                            )
                          else
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 2.1,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              children: [
                                _buildSensorTile(
                                  'Suhu (DHT22)',
                                  '${latestLog['suhu']} °C',
                                  Icons.thermostat_rounded,
                                  (latestLog['suhu'] as num) > _batasSuhuMaks ? const Color(0xFFFF5252) : const Color(0xFFFFA726),
                                ),
                                _buildSensorTile(
                                  'Kelembapan Udara',
                                  '${latestLog['kelembapan_udara']} %',
                                  Icons.air_rounded,
                                  const Color(0xFF29B6F6),
                                ),
                                _buildSensorTile(
                                  'Kelembapan Tanah',
                                  '${latestLog['kelembapan_tanah']} %',
                                  Icons.water_drop_rounded,
                                  (latestLog['kelembapan_tanah'] as num) < _batasLembapMin ? const Color(0xFFFF5252) : const Color(0xFF1ABC9C),
                                ),
                                _buildSensorTile(
                                  'Cahaya (LDR)',
                                  '${latestLog['cahaya']} Lux',
                                  Icons.wb_sunny_rounded,
                                  const Color(0xFFFFD54F),
                                ),
                              ],
                            ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: _simulateIncomingSensorData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonLime,
                                foregroundColor: AppTheme.darkForest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.sensors_rounded, size: 20),
                              label: const Text(
                                'Ambil / Simulasikan Data IoT Baru',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // FR-12: Tombol Notifikasi Pengingat Suhu
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final currentSuhu = (latestLog?['suhu'] as num?)?.toDouble() ?? 28.5;
                                final currentLembapTanah = (latestLog?['kelembapan_tanah'] as num?)?.toDouble() ?? 60.0;
                                final currentLembapUdara = (latestLog?['kelembapan_udara'] as num?)?.toDouble() ?? 65.0;
                                final currentCahaya = (latestLog?['cahaya'] as num?)?.toDouble() ?? 650.0;

                                await NotificationService.instance.showTelemetryNotification(
                                  greenhouseName: ghName,
                                  suhu: currentSuhu,
                                  lembapTanah: currentLembapTanah,
                                  lembapUdara: currentLembapUdara,
                                  cahaya: currentCahaya,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Notifikasi pengingat suhu (FR-12) berhasil dikirimkan ke status bar!'),
                                      backgroundColor: AppTheme.neonLime,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF00E5FF),
                                side: const BorderSide(color: Color(0xFF00E5FF)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.notifications_active_rounded, size: 18),
                              label: const Text(
                                'Kirim Pengingat Notifikasi Suhu Sekarang (FR-12)',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // FR-12: Switch Pengingat Otomatis Latar Belakang
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF102E27),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _isAutoPeriodicNotification
                                    ? AppTheme.neonLime.withValues(alpha: 0.6)
                                    : AppTheme.emeraldGreen.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isAutoPeriodicNotification ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                                  color: _isAutoPeriodicNotification ? AppTheme.neonLime : AppTheme.textGrey,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pengingat Berkala Otomatis',
                                        style: TextStyle(
                                          color: AppTheme.creamWhite,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                      Text(
                                        'Tetap aktif otomatis meski aplikasi ditutup',
                                        style: TextStyle(
                                          color: AppTheme.textGrey,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isAutoPeriodicNotification,
                                  activeThumbColor: AppTheme.neonLime,
                                  activeTrackColor: AppTheme.neonLime.withValues(alpha: 0.4),
                                  onChanged: (val) async {
                                    setState(() => _isAutoPeriodicNotification = val);
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setBool('auto_periodic_notification', val);
                                    if (val) {
                                      final curSuhu = latestLog?['suhu'] ?? 28.5;
                                      final curLembap = latestLog?['kelembapan_tanah'] ?? 65;
                                      await NotificationService.instance.startPeriodicTelemetryReminder(
                                          title: '🌿 [Auto-Reminder] $ghName',
                                          body: '🌡️ Suhu: $curSuhu°C | Kelembaban: $curLembap%',
                                      );
                                    } else {
                                      await NotificationService.instance.stopPeriodicTelemetryReminder();
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            val
                                                ? '✓ Pengingat otomatis diaktifkan! Notifikasi suhu akan berbunyi berkala walau aplikasi keluar.'
                                                : 'Pengingat berkala otomatis dimatikan.',
                                            style: const TextStyle(color: AppTheme.darkForest),
                                          ),
                                          backgroundColor: AppTheme.neonLime,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // KARTU FR-07: ZONA WAKTU & RIWAYAT LOG
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Log Sensor (FR-07)',
                          style: TextStyle(
                            color: AppTheme.creamWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedZone,
                              dropdownColor: AppTheme.cardSurface,
                              style: const TextStyle(color: AppTheme.creamWhite, fontSize: 12),
                              items: const [
                                DropdownMenuItem(value: 'WIB', child: Text('Zona: WIB (UTC+7)')),
                                DropdownMenuItem(value: 'WITA', child: Text('Zona: WITA (UTC+8)')),
                                DropdownMenuItem(value: 'WIT', child: Text('Zona: WIT (UTC+9)')),
                                DropdownMenuItem(value: 'London', child: Text('Zona: London (UTC+0)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedZone = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_sensorLogs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Belum ada riwayat sensor tercatat.',
                            style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ..._sensorLogs.map((log) {
                        final convertedTime = TimezoneHelper.formatUtcToZone(
                          log['waktu_utc'] as String,
                          _selectedZone,
                        );
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.emeraldGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonLime.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.memory_rounded, color: AppTheme.neonLime, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Suhu: ${log['suhu']}°C • Lembap: ${log['kelembapan_tanah']}% • ${log['cahaya']} lx',
                                      style: const TextStyle(
                                        color: AppTheme.creamWhite,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Waktu: $convertedTime [${log['sync_status']}]',
                                      style: TextStyle(
                                        color: AppTheme.pastelLime.withValues(alpha: 0.8),
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyItem(String code, String value) {
    return Column(
      children: [
        Text(code, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
            color: AppTheme.creamWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildSensorTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppTheme.creamWhite),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
