import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/smart_tani_logo.dart';
import '../greenhouse/greenhouse_map_page.dart';
import '../iot/iot_monitor_page.dart';
import '../ai_assistant/ai_assistant_page.dart';
import '../schedule/jadwal_tanam_page.dart';
import '../variety_plant/varietas_tanaman_page.dart';
import '../blockchain/blockchain_page.dart';
import '../game/edukasi_game_page.dart';
import '../search/pencarian_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.ground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Header (Brand & Operator Aktif) ──
              _buildHeader(context, user?.nama ?? 'Petani Unggul'),
              const SizedBox(height: 24),

              // ── 2. Telemetri Lingkungan Mikro (Live Console) ──
              _buildLiveTelemetry(context),
              const SizedBox(height: 28),

              // ── 3. Operasi & Kontrol Lahan ──
              const Text(
                'Operasi & Kontrol Lahan',
                style: AppTheme.sectionTitle,
              ),
              const SizedBox(height: 6),
              const Text(
                'Alat presisi pemantauan lapangan, kalender perawatan, dan aktuator.',
                style: AppTheme.bodyMuted,
              ),
              const SizedBox(height: 14),
              _buildOperationsSection(context),
              const SizedBox(height: 28),

              // ── 4. Katalog & Ketertelusuran ──
              const Text(
                'Katalog & Ketertelusuran',
                style: AppTheme.sectionTitle,
              ),
              const SizedBox(height: 6),
              const Text(
                'Basis data agronomi, log panen terverifikasi, dan modul edukasi.',
                style: AppTheme.bodyMuted,
              ),
              const SizedBox(height: 14),
              _buildRecordsSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Lahan ──
  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TaniGreen Agronomy Console',
                    style: AppTheme.caption,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: AppTheme.headline.copyWith(fontSize: 22),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        const SmartTaniLogo(
          size: 38,
        ),
      ],
    );
  }

  // ── Telemetri Lahan Real-Time ──
  Widget _buildLiveTelemetry(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.borderQuiet,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Greenhouse Utama',
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Blok Melon Inthanon • Fase Pembesaran',
                      style: AppTheme.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.panelElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.borderQuiet,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.statusOk,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Optimal',
                      style: TextStyle(
                        color: AppTheme.statusOk,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3 Kolom Metrik Sensor Lahan
          Row(
            children: [
              Expanded(
                child: _buildMetricBlock(
                  label: 'Suhu Udara',
                  value: '26.8°C',
                  subtext: 'Batas 24-28°C',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBlock(
                  label: 'Kelembapan',
                  value: '76%',
                  subtext: 'Batas 70-80%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBlock(
                  label: 'pH Nutrisi',
                  value: '6.4 pH',
                  subtext: 'Ideal 6.0-6.8',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBlock({
    required String label,
    required String value,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.panelElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.borderQuiet,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: const TextStyle(
              color: AppTheme.inkTertiary,
              fontSize: 10.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Modul Operasi Presisi ──
  Widget _buildOperationsSection(BuildContext context) {
    return Column(
      children: [
        _buildActionTile(
          context: context,
          icon: Icons.explore_outlined,
          title: 'Pemetaan Greenhouse & Kompas',
          description: 'Streaming live GPS lahan dan orientasi kompas hardware ke unit greenhouse.',
          badgeText: 'GPS & Sensor',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GreenhouseMapPage()),
          ),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          context: context,
          icon: Icons.event_note_outlined,
          title: 'Jadwal Perawatan & Notifikasi',
          description: 'Pengingat otomatis pemupukan NPK, irigasi, dan kalender rotasi panen.',
          badgeText: 'Pengingat Lokal',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JadwalTanamPage()),
          ),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          context: context,
          icon: Icons.sensors_outlined,
          title: 'Telemetri & Aktuator IoT',
          description: 'Status instrumen aktuator, pompa irigasi otomatis, dan mist blower.',
          badgeText: 'Aktuator',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IoTMonitorPage()),
          ),
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          context: context,
          icon: Icons.psychology_outlined,
          title: 'Asisten Agronomi & Suara',
          description: 'Konsultasi diagnosis hama, daun menguning, dan nutrisi via AI & suara.',
          badgeText: 'Gemini AI',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiAssistantPage()),
          ),
        ),
      ],
    );
  }

  // ── Modul Katalog & Ketertelusuran ──
  Widget _buildRecordsSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                context: context,
                icon: Icons.spa_outlined,
                title: 'Varietas Tanaman',
                subtitle: 'Katalog bibit & siklus tanam',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VarietasTanamanPage()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactCard(
                context: context,
                icon: Icons.search_outlined,
                title: 'Pencarian Tanaman',
                subtitle: 'Filter agronomis & hama',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PencarianPage()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                context: context,
                icon: Icons.verified_outlined,
                title: 'Buku Rantai Pasok',
                subtitle: 'Verifikasi SHA-256 panen',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BlockchainPage()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCompactCard(
                context: context,
                icon: Icons.sports_esports_outlined,
                title: 'Simulasi Edukasi',
                subtitle: 'Gamifikasi panen & kuis',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EdukasiGamePage()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderQuiet,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.panelElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.borderQuiet,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: AppTheme.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppTheme.ink,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.panelElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: AppTheme.inkSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTheme.bodyMuted.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.inkTertiary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderQuiet,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.panelElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderQuiet,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: AppTheme.ink,
                size: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTheme.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
