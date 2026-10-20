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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Top Header (Greeting + Brand Squircle Badge) ──
                _buildHeader(context, user?.nama ?? 'Petani Unggul'),
                const SizedBox(height: 20),

                // ── 2. Quick Status Hero Card (Greenhouse Summary) ──
                _buildStatusBanner(context),
                const SizedBox(height: 24),

                // ── 3. Kategori 1: Pertanian (4 Fitur) ──
                _buildCategorySection(
                  context: context,
                  title: 'Pertanian & Budidaya',
                  subtitle: 'Manajemen lahan, varietas, dan jadwal panen',
                  icon: Icons.eco_rounded,
                  accentColor: AppTheme.neonLime,
                  screenWidth: screenWidth,
                  items: const [
                    _MenuItemData(
                      icon: Icons.map_rounded,
                      label: 'Greenhouse\nMap',
                      color: Color(0xFF2ECC71),
                      page: GreenhouseMapPage(),
                    ),
                    _MenuItemData(
                      icon: Icons.calendar_month_rounded,
                      label: 'Jadwal\nTanam',
                      color: Color(0xFF3CD070),
                      page: JadwalTanamPage(),
                    ),
                    _MenuItemData(
                      icon: Icons.grass_rounded,
                      label: 'Varietas\nTanaman',
                      color: Color(0xFF1ABC9C),
                      page: VarietasTanamanPage(),
                    ),
                    _MenuItemData(
                      icon: Icons.search_rounded,
                      label: 'Pencarian\nTanaman',
                      color: Color(0xFF16A085),
                      page: PencarianPage(),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── 4. Kategori 2: Monitoring & IoT (2 Fitur) ──
                _buildCategorySection(
                  context: context,
                  title: 'Monitoring & IoT',
                  subtitle: 'Sensor presisi dan konsultasi AI otomatis',
                  icon: Icons.sensors_rounded,
                  accentColor: const Color(0xFF00E5FF),
                  screenWidth: screenWidth,
                  items: const [
                    _MenuItemData(
                      icon: Icons.thermostat_rounded,
                      label: 'IoT\nMonitor',
                      color: Color(0xFFFFA726),
                      page: IoTMonitorPage(),
                    ),
                    _MenuItemData(
                      icon: Icons.smart_toy_rounded,
                      label: 'AI\nAssistant',
                      color: Color(0xFF29B6F6),
                      page: AiAssistantPage(),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── 5. Kategori 3: Komunitas & Edukasi (2 Fitur) ──
                _buildCategorySection(
                  context: context,
                  title: 'Komunitas & Edukasi',
                  subtitle: 'Traceability panen dan gamifikasi edukatif',
                  icon: Icons.groups_rounded,
                  accentColor: const Color(0xFFB388FF),
                  screenWidth: screenWidth,
                  items: const [
                    _MenuItemData(
                      icon: Icons.link_rounded,
                      label: 'Blockchain\nSupply',
                      color: Color(0xFFAB47BC),
                      page: BlockchainPage(),
                    ),
                    _MenuItemData(
                      icon: Icons.sports_esports_rounded,
                      label: 'Edukasi\nGame',
                      color: Color(0xFFFF5252),
                      page: EdukasiGamePage(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header Widget ──
  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.neonLime,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Selamat datang,',
                    style: TextStyle(
                      color: AppTheme.pastelLime.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: AppTheme.creamWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Logo Brand Squircle Badge dari Desain Resmi
        const SmartTaniLogo(
          size: 34,
          variant: SmartTaniLogoVariant.neonLime,
          showBadge: true,
          hasGlow: true,
        ),
      ],
    );
  }

  // ── Status Banner (Hero Card) ──
  Widget _buildStatusBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF143E33),
            Color(0xFF0D2B23),
            Color(0xFF071B15),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.neonLime.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      color: AppTheme.neonLime,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sistem Greenhouse Aktif',
                    style: TextStyle(
                      color: AppTheme.creamWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.neonLime.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.neonLime.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  '● Kondisi Optimal',
                  style: TextStyle(
                    color: AppTheme.neonLime,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSensorMetric(
                icon: Icons.thermostat_rounded,
                label: 'Suhu Udara',
                value: '26.8°C',
                color: const Color(0xFFFFA726),
              ),
              Container(
                width: 1,
                height: 32,
                color: AppTheme.emeraldGreen.withValues(alpha: 0.3),
              ),
              _buildSensorMetric(
                icon: Icons.water_drop_rounded,
                label: 'Kelembapan',
                value: '76%',
                color: const Color(0xFF29B6F6),
              ),
              Container(
                width: 1,
                height: 32,
                color: AppTheme.emeraldGreen.withValues(alpha: 0.3),
              ),
              _buildSensorMetric(
                icon: Icons.science_rounded,
                label: 'pH Tanah',
                value: '6.4 pH',
                color: AppTheme.neonLime,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.creamWhite,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }

  // ── Category Section ──
  Widget _buildCategorySection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required double screenWidth,
    required List<_MenuItemData> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header dengan Badge Kapsul
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentColor, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.creamWhite,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textGrey.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Grid Menu Items (4 Kolom Sesuai Referensi Squircle BCA & Desain)
        Wrap(
          spacing: 12,
          runSpacing: 14,
          children: items.map((item) {
            final itemWidth = (screenWidth - 40 - 36) / 4;
            return _buildMenuItem(
              context: context,
              item: item,
              width: itemWidth,
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Single Menu Item (Squircle Card Mewah) ──
  Widget _buildMenuItem({
    required BuildContext context,
    required _MenuItemData item,
    required double width,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => item.page),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            // Squircle Button Card
            Container(
              width: width * 0.86,
              height: width * 0.86,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF163E33),
                    Color(0xFF0C2720),
                    Color(0xFF071B15),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: item.color.withValues(alpha: 0.45),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Label Teks
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.creamWhite,
                fontSize: 10.8,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data class for menu items ──
class _MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  final Widget page;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.color,
    required this.page,
  });
}