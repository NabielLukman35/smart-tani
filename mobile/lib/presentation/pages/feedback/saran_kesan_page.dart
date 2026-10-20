import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/smart_tani_logo.dart';

class SaranKesanPage extends StatefulWidget {
  const SaranKesanPage({super.key});

  @override
  State<SaranKesanPage> createState() => _SaranKesanPageState();
}

class _SaranKesanPageState extends State<SaranKesanPage> {
  final _controller = TextEditingController();
  final List<String> _submittedFeedback = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Silakan tuliskan pesan saran & kesan Anda terlebih dahulu.',
            style: TextStyle(color: AppTheme.darkForest),
          ),
          backgroundColor: AppTheme.neonLime,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _submittedFeedback.insert(0, text);
    });
    _controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Terima kasih! Saran & kesan berhasil dikirim dan tersimpan.',
          style: TextStyle(color: AppTheme.darkForest, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.neonLime,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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
                          'Mata Kuliah Pemrograman Aplikasi Mobile',
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
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF143E33),
                              Color(0xFF0C2720),
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
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                              'Bagikan pengalaman, masukan teknis, atau ide pengembangan aplikasi Smart Tani untuk mata kuliah ini.',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Textarea Container
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
                                controller: _controller,
                                maxLines: 5,
                                style: const TextStyle(
                                  color: AppTheme.creamWhite,
                                  fontSize: 13.5,
                                ),
                                cursorColor: AppTheme.neonLime,
                                decoration: const InputDecoration(
                                  hintText: 'Tuliskan saran dan kesan Anda secara lengkap di sini...',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 12.5,
                                  ),
                                  contentPadding: EdgeInsets.all(16),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

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
                                  'Kirim Saran & Kesan',
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

                      // Riwayat Saran Terkirim
                      if (_submittedFeedback.isNotEmpty) ...[
                        const Text(
                          'Masukan yang Telah Dikirim',
                          style: TextStyle(
                            color: AppTheme.creamWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._submittedFeedback.map(
                          (msg) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.emeraldGreen.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppTheme.neonLime,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    msg,
                                    style: const TextStyle(
                                      color: AppTheme.creamWhite,
                                      fontSize: 12.5,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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