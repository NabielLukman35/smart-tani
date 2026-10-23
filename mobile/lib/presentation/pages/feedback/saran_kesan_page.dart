import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/smart_tani_logo.dart';
import '../../../data/local_db/database_helper.dart';

class SaranKesanPage extends StatefulWidget {
  const SaranKesanPage({super.key});

  @override
  State<SaranKesanPage> createState() => _SaranKesanPageState();
}

class _SaranKesanPageState extends State<SaranKesanPage> {
  final _kesanCtrl = TextEditingController();
  final _saranCtrl = TextEditingController();
  List<Map<String, dynamic>> _savedList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFeedback());
  }

  @override
  void dispose() {
    _kesanCtrl.dispose();
    _saranCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFeedback() async {
    final user = context.read<AuthProvider>().currentUser;
    final userId = user?.id ?? 1;
    final list = await DatabaseHelper.instance.getSaranKesanByUser(userId);
    if (mounted) {
      setState(() {
        _savedList = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final kesan = _kesanCtrl.text.trim();
    final saran = _saranCtrl.text.trim();

    if (kesan.isEmpty || saran.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Silakan lengkapi kolom Kesan dan Saran terlebih dahulu.',
            style: TextStyle(color: AppTheme.darkForest),
          ),
          backgroundColor: AppTheme.neonLime,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final user = context.read<AuthProvider>().currentUser;
    final userId = user?.id ?? 1;

    await DatabaseHelper.instance.insertSaranKesan(userId, saran, kesan);
    _kesanCtrl.clear();
    _saranCtrl.clear();
    await _loadFeedback();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Terima kasih! Saran & kesan berhasil disimpan ke database SQLite (FR-05).',
            style: TextStyle(color: AppTheme.darkForest, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.neonLime,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

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
              // ── Header Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saran & Kesan',
                          style: TextStyle(
                            color: AppTheme.creamWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Mata Kuliah Pemrograman Aplikasi Mobile (FR-05)',
                          style: TextStyle(
                            color: AppTheme.pastelLime.withValues(alpha: 0.75),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                    const SmartTaniLogo(
                      size: 26,
                      variant: SmartTaniLogoVariant.neonLime,
                      showBadge: true,
                      hasGlow: false,
                    ),
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Card Form ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.panel,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                            width: 1.2,
                          ),

                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonLime.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.rate_review_rounded,
                                    color: AppTheme.neonLime,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Formulir Evaluasi & Masukan',
                                  style: TextStyle(
                                    color: AppTheme.creamWhite,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Bagikan kesan dan saran Anda selama perkuliahan Pemrograman Aplikasi Mobile (PAM). Data tersimpan permanen di database lokal SQLite.',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Field Kesan
                            const Text(
                              'Kesan Perkuliahan PAM',
                              style: TextStyle(
                                color: AppTheme.pastelLime,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.inputFill,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppTheme.emeraldGreen.withValues(alpha: 0.45),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _kesanCtrl,
                                maxLines: 3,
                                style: const TextStyle(
                                  color: AppTheme.creamWhite,
                                  fontSize: 13,
                                ),
                                cursorColor: AppTheme.neonLime,
                                decoration: const InputDecoration(
                                  hintText: 'Tuliskan kesan Anda selama mengikuti mata kuliah PAM...',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 12,
                                  ),
                                  contentPadding: EdgeInsets.all(14),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Field Saran
                            const Text(
                              'Saran untuk Perkuliahan & Dosen',
                              style: TextStyle(
                                color: AppTheme.pastelLime,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.inputFill,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppTheme.emeraldGreen.withValues(alpha: 0.45),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _saranCtrl,
                                maxLines: 3,
                                style: const TextStyle(
                                  color: AppTheme.creamWhite,
                                  fontSize: 13,
                                ),
                                cursorColor: AppTheme.neonLime,
                                decoration: const InputDecoration(
                                  hintText: 'Tuliskan saran konstruktif untuk mata kuliah & pengembangan aplikasi...',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 12,
                                  ),
                                  contentPadding: EdgeInsets.all(14),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton.icon(
                                onPressed: _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.neonLime,
                                  foregroundColor: AppTheme.darkForest,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(Icons.send_rounded, size: 18),
                                label: const Text(
                                  'Simpan Saran & Kesan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Riwayat Saran & Kesan Terkirim dari SQLite
                      const Text(
                        'Riwayat Saran & Kesan Tersimpan di SQLite',
                        style: TextStyle(
                          color: AppTheme.creamWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: AppTheme.neonLime),
                          ),
                        )
                      else if (_savedList.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.emeraldGreen.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.inbox_rounded, color: AppTheme.textGrey, size: 36),
                              SizedBox(height: 8),
                              Text(
                                'Belum ada saran & kesan tersimpan.',
                                style: TextStyle(color: AppTheme.textGrey, fontSize: 12.5),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._savedList.map((item) {
                          final kesanText = item['kesan'] ?? '';
                          final saranText = item['saran'] ?? '';
                          final waktu = item['waktu']?.toString().split('T').first ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(16),
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
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppTheme.neonLime,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Tersimpan di SQLite',
                                          style: TextStyle(
                                            color: AppTheme.neonLime.withValues(alpha: 0.9),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      waktu,
                                      style: const TextStyle(
                                        color: AppTheme.textGrey,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Kesan: $kesanText',
                                  style: const TextStyle(
                                    color: AppTheme.creamWhite,
                                    fontSize: 12.5,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Saran: $saranText',
                                  style: const TextStyle(
                                    color: AppTheme.pastelLime,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
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
}
