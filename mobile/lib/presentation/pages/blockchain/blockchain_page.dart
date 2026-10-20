import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_sub_app_bar.dart';

class BlockchainPage extends StatelessWidget {
  const BlockchainPage({super.key});

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
              const CustomSubAppBar(
                title: 'Blockchain Supply Chain',
                subtitle: 'Pelacakan Asal Komoditas & Integritas Data (FR-13)',
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Batch Overview Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF281C38),
                              Color(0xFF140D20),
                              Color(0xFF0C241C),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFAB47BC).withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'BATCH #TG-8821-YK',
                                  style: TextStyle(
                                    color: AppTheme.creamWhite,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2ECC71).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF2ECC71)),
                                  ),
                                  child: const Text(
                                    '✓ Verified on-Chain',
                                    style: TextStyle(
                                      color: Color(0xFF2ECC71),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Komoditas: Tomat Cherry Hidroponik Grade A',
                              style: TextStyle(
                                color: AppTheme.pastelLime,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.fingerprint_rounded, size: 16, color: Color(0xFFAB47BC)),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      'SHA-256: 8f4a2b9c7e103d51829e...c701',
                                      style: TextStyle(
                                        color: AppTheme.textGrey,
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Hash transaksi blockchain disalin ke clipboard!'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.neonLime),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Rantai Perjalanan Komoditas (Traceability)',
                        style: TextStyle(
                          color: AppTheme.creamWhite,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Timeline
                      _buildTimelineItem(
                        icon: Icons.grain_rounded,
                        title: '1. Penyemaian Bibit Tersertifikasi',
                        desc: 'Bibit bersertifikat BPSB Jawa Tengah • Greenhouse A',
                        time: '12 Okt 2026, 09:00 WIB',
                        isFirst: true,
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        icon: Icons.eco_rounded,
                        title: '2. Budidaya Nutrisi Terkontrol IoT',
                        desc: 'Sensor mencatat kelembapan 76% & pH 6.4 stabil tanpa pestisida',
                        time: '14 Okt - 18 Okt 2026',
                        isFirst: false,
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        icon: Icons.inventory_2_rounded,
                        title: '3. Pemanenan & Quality Grading',
                        desc: 'Dipanen manual, kadar brix 12.5%, lolos sortir higienis',
                        time: '20 Okt 2026, 06:30 WIB',
                        isFirst: false,
                        isLast: false,
                      ),
                      _buildTimelineItem(
                        icon: Icons.local_shipping_rounded,
                        title: '4. Distribusi Cold-Chain Siap Kirim',
                        desc: 'Suhu penyimpanan terkendali 4°C menuju pasar retail mitra',
                        time: 'Sedang Berlangsung',
                        isFirst: false,
                        isLast: true,
                      ),
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

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String desc,
    required String time,
    required bool isFirst,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFAB47BC).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFAB47BC), width: 1.5),
              ),
              child: Icon(icon, color: const Color(0xFFAB47BC), size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: const Color(0xFFAB47BC).withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.creamWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: AppTheme.pastelLime.withValues(alpha: 0.7),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
