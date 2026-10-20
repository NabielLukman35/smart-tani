import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_sub_app_bar.dart';

class VarietasTanamanPage extends StatelessWidget {
  const VarietasTanamanPage({super.key});

  final List<Map<String, dynamic>> _varieties = const [
    {
      'name': 'Tomat Cherry Ruby',
      'latin': 'Solanum lycopersicum var. cerasiforme',
      'harvestDays': '60 - 70 Hari',
      'ph': '6.0 - 6.8 pH',
      'temp': '22 - 28°C',
      'tag': 'Populer',
      'color': Color(0xFFFF5252),
      'icon': Icons.spa_rounded,
      'desc': 'Rasa manis segar dengan kandungan likopen tinggi, sangat tahan serangan jamur daun.',
    },
    {
      'name': 'Selada Romaine Hijau',
      'latin': 'Lactuca sativa L.',
      'harvestDays': '30 - 40 Hari',
      'ph': '5.8 - 6.5 pH',
      'temp': '18 - 25°C',
      'tag': 'Cepat Panen',
      'color': Color(0xFF2ECC71),
      'icon': Icons.eco_rounded,
      'desc': 'Tekstur renyah cocok untuk hidroponik sistem NFT & DFT dengan sirkulasi nutrisi stabil.',
    },
    {
      'name': 'Cabai Rawit Hibrida',
      'latin': 'Capsicum frutescens',
      'harvestDays': '75 - 85 Hari',
      'ph': '6.0 - 7.0 pH',
      'temp': '25 - 32°C',
      'tag': 'Hasil Tinggi',
      'color': Color(0xFFFFA726),
      'icon': Icons.local_fire_department_rounded,
      'desc': 'Tingkat kepedasan tinggi dan produktivitas lebat sepanjang tahun.',
    },
    {
      'name': 'Melon Golden Emerald',
      'latin': 'Cucumis melo L.',
      'harvestDays': '65 - 75 Hari',
      'ph': '6.2 - 6.8 pH',
      'temp': '24 - 30°C',
      'tag': 'Premium',
      'color': Color(0xFFFFD54F),
      'icon': Icons.grain_rounded,
      'desc': 'Kulit kuning emas dengan daging renyah manis hingga tingkat brix 14%.',
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
              const CustomSubAppBar(
                title: 'Varietas Tanaman',
                subtitle: 'Katalog Bibit Unggul & Parameter Budidaya',
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: _varieties.length,
                  itemBuilder: (ctx, idx) {
                    final item = _varieties[idx];
                    final color = item['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF143E33),
                            Color(0xFF0C2720),
                            Color(0xFF071B15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: color.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(item['icon'], color: color, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        color: AppTheme.creamWhite,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15.5,
                                      ),
                                    ),
                                    Text(
                                      item['latin'],
                                      style: const TextStyle(
                                        color: AppTheme.textGrey,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['tag'],
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['desc'],
                            style: TextStyle(
                              color: AppTheme.pastelLime.withValues(alpha: 0.85),
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.inputFill,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildBadge(Icons.timer_rounded, item['harvestDays']),
                                _buildBadge(Icons.science_rounded, item['ph']),
                                _buildBadge(Icons.thermostat_rounded, item['temp']),
                              ],
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

  Widget _buildBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.neonLime),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.creamWhite,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
