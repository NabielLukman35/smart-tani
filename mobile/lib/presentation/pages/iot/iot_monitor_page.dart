import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_sub_app_bar.dart';
import 'iot_monitoring_page.dart';

class IoTMonitorPage extends StatefulWidget {
  const IoTMonitorPage({super.key});

  @override
  State<IoTMonitorPage> createState() => _IoTMonitorPageState();
}

class _IoTMonitorPageState extends State<IoTMonitorPage> {
  bool _irrigationActive = true;
  bool _fanActive = false;
  bool _growLightActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.ground,
        child: SafeArea(
          child: Column(
            children: [
              CustomSubAppBar(
                title: 'IoT Monitor',
                subtitle: 'Sensor Presisi & Kendali Aktuator Lahan',
                trailing: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Data telemetri sensor berhasil diperbarui!',
                          style: TextStyle(color: AppTheme.darkForest),
                        ),
                        backgroundColor: AppTheme.neonLime,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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
                      Icons.refresh_rounded,
                      color: AppTheme.neonLime,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.panel,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.emeraldGreen.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.neonLime.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.sensors_rounded,
                                color: AppTheme.neonLime,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Semua Node Sensor Terhubung',
                                    style: TextStyle(
                                      color: AppTheme.creamWhite,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Protokol MQTT • Latensi 42ms • Update tiap 5 detik',
                                    style: TextStyle(
                                      color: AppTheme.pastelLime,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Shortcut ke Halaman Telemetri & Multi-Valuta (FR-06, FR-07, FR-08)
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const IotMonitoringPage(
                                greenhouse: {
                                  'id': 1,
                                  'nama_greenhouse': 'Greenhouse Utama (A)',
                                  'biaya_operasional_idr': 1500000.0,
                                  'batas_suhu_maks': 35.0,
                                  'batas_lembap_min': 40.0,
                                },
                                userId: 1,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.neonLime.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.neonLime.withValues(alpha: 0.45),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.currency_exchange_rounded, color: AppTheme.neonLime, size: 22),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Telemetri IoT & Konversi Valuta (FR-06, FR-07)',
                                      style: TextStyle(
                                        color: AppTheme.neonLime,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    Text(
                                      'Buka kurs 4 mata uang & 4 zona waktu riwayat sensor',
                                      style: TextStyle(
                                        color: AppTheme.pastelLime,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.neonLime, size: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Parameter Lingkungan Greenhouse',
                        style: TextStyle(
                          color: AppTheme.creamWhite,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Grid Kartu Sensor
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                        children: [
                          _buildSensorCard(
                            title: 'Suhu Udara',
                            value: '26.8°C',
                            status: 'Optimal (24-28°C)',
                            icon: Icons.thermostat_rounded,
                            color: const Color(0xFFFFA726),
                          ),
                          _buildSensorCard(
                            title: 'Kelembapan',
                            value: '76%',
                            status: 'Normal Lembap',
                            icon: Icons.water_drop_rounded,
                            color: const Color(0xFF29B6F6),
                          ),
                          _buildSensorCard(
                            title: 'pH Tanah',
                            value: '6.4 pH',
                            status: 'Ideal Sayuran',
                            icon: Icons.science_rounded,
                            color: AppTheme.neonLime,
                          ),
                          _buildSensorCard(
                            title: 'Intensitas Cahaya',
                            value: '840 Lux',
                            status: 'Pencahayaan Baik',
                            icon: Icons.wb_sunny_rounded,
                            color: const Color(0xFFFFD54F),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Kendali Aktuator Otomatis',
                        style: TextStyle(
                          color: AppTheme.creamWhite,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Aktuator Cards
                      _buildActuatorTile(
                        icon: Icons.shower_rounded,
                        title: 'Pompa Irigasi Tetes',
                        subtitle: 'Otomatis menyala saat kelembapan < 60%',
                        value: _irrigationActive,
                        onChanged: (val) => setState(() => _irrigationActive = val),
                      ),
                      const SizedBox(height: 10),
                      _buildActuatorTile(
                        icon: Icons.air_rounded,
                        title: 'Kipas Exhaust & Ventilasi',
                        subtitle: 'Peredam suhu dan sirkulasi udara mikro',
                        value: _fanActive,
                        onChanged: (val) => setState(() => _fanActive = val),
                      ),
                      const SizedBox(height: 10),
                      _buildActuatorTile(
                        icon: Icons.lightbulb_rounded,
                        title: 'Lampu LED Grow Light',
                        subtitle: 'Spektrum fotosintesis saat malam hari',
                        value: _growLightActive,
                        onChanged: (val) => setState(() => _growLightActive = val),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.creamWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActuatorTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.emeraldGreen.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (value ? AppTheme.neonLime : AppTheme.textGrey)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? AppTheme.neonLime : AppTheme.textGrey,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.creamWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.neonLime,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
