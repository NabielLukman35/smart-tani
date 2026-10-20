import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_sub_app_bar.dart';

class EdukasiGamePage extends StatefulWidget {
  const EdukasiGamePage({super.key});

  @override
  State<EdukasiGamePage> createState() => _EdukasiGamePageState();
}

class _EdukasiGamePageState extends State<EdukasiGamePage> {
  int _score = 120;
  int? _selectedOption;
  bool _answered = false;

  void _answerQuestion(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == 1) {
        _score += 15;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          index == 1
              ? 'Jawaban Benar! +15 Poin Petani didapatkan.'
              : 'Jawaban Belum Tepat. pH ideal sayuran daun adalah 5.8 - 6.5.',
          style: const TextStyle(color: AppTheme.darkForest, fontWeight: FontWeight.w600),
        ),
        backgroundColor: index == 1 ? AppTheme.neonLime : const Color(0xFFFF5252),
        behavior: SnackBarBehavior.floating,
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
              CustomSubAppBar(
                title: 'Edukasi Game',
                subtitle: 'Kuis Agronomi & Gamifikasi Token Petani',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$_score Poin',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                      // Banner Level
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E1C1A), Color(0xFF1C1210), Color(0xFF0C241C)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5252).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.sports_esports_rounded,
                                color: Color(0xFFFF5252),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Level 3: Petani Ahli Smart Agro',
                                    style: TextStyle(
                                      color: AppTheme.creamWhite,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Jawab kuis harian untuk kumpulkan Token Tani!',
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
                      const SizedBox(height: 24),

                      // Kuis Card
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
                                  'Tantangan Hari Ini #04',
                                  style: TextStyle(
                                    color: AppTheme.neonLime,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '+15 Token',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Berapa rentang pH air nutrisi yang paling optimal untuk pertumbuhan sayuran daun hidroponik (selada, pakcoy)?',
                              style: TextStyle(
                                color: AppTheme.creamWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Pilihan Jawaban
                            _buildOption(0, 'A. 4.0 - 5.0 pH (Sangat Asam)'),
                            _buildOption(1, 'B. 5.8 - 6.5 pH (Ideal Seimbang)'),
                            _buildOption(2, 'C. 7.5 - 8.5 pH (Basa Tinggi)'),
                            _buildOption(3, 'D. Di atas 9.0 pH (Alkali)'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Misi Harian
                      const Text(
                        'Misi Harian Petani',
                        style: TextStyle(
                          color: AppTheme.creamWhite,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDailyMission(
                        title: 'Periksa Suhu Greenhouse',
                        reward: '+5 Token',
                        isCompleted: true,
                      ),
                      const SizedBox(height: 10),
                      _buildDailyMission(
                        title: 'Simulasikan Irigasi Tetes',
                        reward: '+10 Token',
                        isCompleted: false,
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

  Widget _buildOption(int index, String text) {
    Color? bgColor = AppTheme.inputFill;
    Color borderColor = AppTheme.emeraldGreen.withValues(alpha: 0.35);

    if (_answered) {
      if (index == 1) {
        bgColor = AppTheme.neonLime.withValues(alpha: 0.2);
        borderColor = AppTheme.neonLime;
      } else if (_selectedOption == index) {
        bgColor = const Color(0xFFFF5252).withValues(alpha: 0.2);
        borderColor = const Color(0xFFFF5252);
      }
    }

    return GestureDetector(
      onTap: () => _answerQuestion(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppTheme.creamWhite,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_answered && index == 1)
              const Icon(Icons.check_circle_rounded, color: AppTheme.neonLime, size: 18)
            else if (_answered && _selectedOption == index)
              const Icon(Icons.cancel_rounded, color: Color(0xFFFF5252), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyMission({
    required String title,
    required String reward,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isCompleted ? AppTheme.neonLime : AppTheme.textGrey,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isCompleted ? AppTheme.textGrey : AppTheme.creamWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
          Text(
            reward,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
