import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database_helper.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/custom_sub_app_bar.dart';

class EdukasiGamePage extends StatefulWidget {
  const EdukasiGamePage({super.key});

  @override
  State<EdukasiGamePage> createState() => _EdukasiGamePageState();
}

enum FallingItemType {
  melonHijau,
  melonEmas,
  hamaUlat,
  hamaBelalang,
  nutrisi,
}

class FallingItem {
  double x; // 0.0 to 1.0 (relative width)
  double y; // 0.0 to 1.0 (relative height)
  final double speed;
  final FallingItemType type;

  FallingItem({
    required this.x,
    required this.y,
    required this.speed,
    required this.type,
  });
}

class _EdukasiGamePageState extends State<EdukasiGamePage>
    with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: Game Panen Melon (FR-10), 1: Kuis Agronomi

  // ΓöÇΓöÇ GAME STATE ΓöÇΓöÇ
  bool _isPlaying = false;
  int _score = 0;
  int _highScore = 0;
  int _lives = 3;
  double _basketX = 0.5; // Posisi keranjang (0.0 kiri - 1.0 kanan)
  final List<FallingItem> _items = [];
  Timer? _gameLoopTimer;
  Timer? _spawnTimer;
  final Random _random = Random();

  // ΓöÇΓöÇ KUIS STATE ΓöÇΓöÇ
  int _quizScore = 50;
  int? _selectedOption;
  bool _quizAnswered = false;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? 1;
    final hs = await DatabaseHelper.instance.getHighScore(userId);
    if (mounted) {
      setState(() => _highScore = hs);
    }
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _score = 0;
      _lives = 3;
      _basketX = 0.5;
      _items.clear();
    });

    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();

    // Loop Update Posisi (60 FPS ~ 16ms)
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _updateGame();
    });

    // Loop Spawn Objek Baru
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _spawnItem();
    });
  }

  void _spawnItem() {
    final randVal = _random.nextDouble();
    FallingItemType type;
    if (randVal < 0.45) {
      type = FallingItemType.melonHijau;
    } else if (randVal < 0.65) {
      type = FallingItemType.hamaUlat;
    } else if (randVal < 0.80) {
      type = FallingItemType.hamaBelalang;
    } else if (randVal < 0.92) {
      type = FallingItemType.melonEmas;
    } else {
      type = FallingItemType.nutrisi;
    }

    final double speed = 0.012 + (_random.nextDouble() * 0.012);
    _items.add(FallingItem(
      x: 0.08 + (_random.nextDouble() * 0.84),
      y: 0.0,
      speed: speed,
      type: type,
    ));
  }

  void _updateGame() {
    final itemsToRemove = <FallingItem>[];
    const double basketY = 0.88;
    const double basketHalfWidth = 0.12;

    for (final item in _items) {
      item.y += item.speed;

      // Cek Tabrakan dengan Keranjang
      if (item.y >= (basketY - 0.05) && item.y <= (basketY + 0.04)) {
        if ((item.x - _basketX).abs() <= basketHalfWidth) {
          itemsToRemove.add(item);
          _handleCatch(item.type);
          continue;
        }
      }

      // Melewati Batas Bawah Layar
      if (item.y > 1.05) {
        itemsToRemove.add(item);
        if (item.type == FallingItemType.melonHijau ||
            item.type == FallingItemType.melonEmas) {
          // Melon lolos tidak mengurangi hati, hanya lewat
        }
      }
    }

    _items.removeWhere((item) => itemsToRemove.contains(item));

    if (_lives <= 0) {
      _gameOver();
    } else {
      setState(() {});
    }
  }

  void _handleCatch(FallingItemType type) {
    switch (type) {
      case FallingItemType.melonHijau:
        _score += 10;
        break;
      case FallingItemType.melonEmas:
        _score += 25;
        break;
      case FallingItemType.nutrisi:
        _score += 15;
        if (_lives < 3) _lives++;
        break;
      case FallingItemType.hamaUlat:
      case FallingItemType.hamaBelalang:
        _lives--;
        break;
    }
  }

  Future<void> _gameOver() async {
    _isPlaying = false;
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();

    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? 1;

    // Simpan skor ke SQLite (FR-10)
    await DatabaseHelper.instance.insertSkorGame(userId, _score);

    bool isNewRecord = false;
    if (_score > _highScore) {
      _highScore = _score;
      isNewRecord = true;
    }

    // Reward Token jika skor tinggi (>= 50)
    int rewardTokenGiven = 0;
    if (_score >= 50) {
      rewardTokenGiven = (_score / 25).floor();
      await DatabaseHelper.instance.addRewardToken(userId, rewardTokenGiven);
      await auth.refreshUser();
    }

    if (!mounted) return;
    setState(() {});

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isNewRecord ? AppTheme.neonLime : const Color(0xFFE74C3C),
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Icon(
              isNewRecord ? Icons.emoji_events_rounded : Icons.sports_esports_rounded,
              color: isNewRecord ? AppTheme.neonLime : const Color(0xFFFF6B6B),
              size: 26,
            ),
            const SizedBox(width: 10),
            Text(
              isNewRecord ? 'REKOR BARU!' : 'Game Selesai!',
              style: TextStyle(
                color: isNewRecord ? AppTheme.neonLime : AppTheme.creamWhite,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skor Akhir: $_score Poin',
              style: const TextStyle(
                color: AppTheme.creamWhite,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Skor Tertinggi Lokal: $_highScore Poin',
              style: const TextStyle(color: AppTheme.pastelLime, fontSize: 13),
            ),
            if (rewardTokenGiven > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.token_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bonus Panen: +$rewardTokenGiven Token Tani (Tersimpan ke Saldo)',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _items.clear());
            },
            child: const Text('Menu Utama', style: TextStyle(color: AppTheme.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonLime,
              foregroundColor: AppTheme.darkForest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Main Lagi', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        return Stack(
          children: [
            // Background Arena Petani
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.panel,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),

            // Elemen Jatuh (Melon, Hama, Nutrisi)
            for (final item in _items)
              Positioned(
                left: (item.x * width) - 22,
                top: (item.y * height) - 22,
                child: _buildItemWidget(item.type),
              ),

            // Keranjang Petani / Mobil Panen di Posisi _basketX
            Positioned(
              left: (_basketX * width) - 45,
              top: (0.88 * height) - 20,
              child: Container(
                width: 90,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.neonLime, width: 2),

                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_basket_rounded, color: AppTheme.darkForest, size: 24),
                    SizedBox(width: 4),
                    Text(
                      'PANEN',
                      style: TextStyle(
                        color: AppTheme.darkForest,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Kontrol Drag Horizontal pada Layar
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  if (!_isPlaying) return;
                  setState(() {
                    _basketX += details.delta.dx / width;
                    _basketX = _basketX.clamp(0.08, 0.92);
                  });
                },
                onTapDown: (details) {
                  if (!_isPlaying) return;
                  final tapX = details.localPosition.dx / width;
                  setState(() {
                    _basketX = tapX.clamp(0.08, 0.92);
                  });
                },
              ),
            ),

            // Overlay Mulai Game jika Belum Bermain
            if (!_isPlaying)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '≡ƒìê PANEN MELON 2D',
                          style: TextStyle(
                            color: AppTheme.neonLime,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Text(
                            'Geser keranjang untuk menangkap buah melon matang & hindari serangan hama ulat/belalang!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.creamWhite, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _startGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonLime,
                            foregroundColor: AppTheme.darkForest,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 24),
                          label: const Text(
                            'MULAI PANEN',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildItemWidget(FallingItemType type) {
    switch (type) {
      case FallingItemType.melonHijau:
        return const Text('≡ƒìê', style: TextStyle(fontSize: 32));
      case FallingItemType.melonEmas:
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,

          ),
          child: const Text('≡ƒìê', style: TextStyle(fontSize: 34)),
        );
      case FallingItemType.hamaUlat:
        return const Text('≡ƒÉ¢', style: TextStyle(fontSize: 30));
      case FallingItemType.hamaBelalang:
        return const Text('≡ƒªù', style: TextStyle(fontSize: 30));
      case FallingItemType.nutrisi:
        return const Text('≡ƒº¬', style: TextStyle(fontSize: 28));
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
              CustomSubAppBar(
                title: 'Mini Game & Edukasi',
                subtitle: 'Game 2D Panen Melon (FR-10) & Kuis Agronomi',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Rekor: $_highScore',
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

              // Tab Selector (Game 2D vs Kuis Agronomi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_activeTab != 0) setState(() => _activeTab = 0);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _activeTab == 0
                                  ? AppTheme.neonLime
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Panen Melon 2D (FR-10)',
                                style: TextStyle(
                                  color: _activeTab == 0
                                      ? AppTheme.darkForest
                                      : AppTheme.textGrey,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_activeTab != 1) {
                              _gameLoopTimer?.cancel();
                              _spawnTimer?.cancel();
                              setState(() {
                                _isPlaying = false;
                                _activeTab = 1;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _activeTab == 1
                                  ? AppTheme.neonLime
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Kuis Agronomi',
                                style: TextStyle(
                                  color: _activeTab == 1
                                      ? AppTheme.darkForest
                                      : AppTheme.textGrey,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Tab
              Expanded(
                child: _activeTab == 0 ? _buildGameTab() : _buildQuizTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        children: [
          // Bar Informasi Skor & Nyawa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Skor: ',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        color: AppTheme.neonLime,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Nyawa: ',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                    for (int i = 0; i < 3; i++)
                      Icon(
                        i < _lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: i < _lives ? const Color(0xFFFF5252) : AppTheme.textGrey,
                        size: 20,
                      ),
                  ],
                ),
                if (_isPlaying)
                  GestureDetector(
                    onTap: _gameOver,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Stop',
                        style: TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Area Canvas Game Interaktif
          Expanded(child: _buildGameCanvas()),
          const SizedBox(height: 10),

          // Tombol Kontrol Bawah (Tombol Kiri / Kanan Tambahan)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filled(
                onPressed: _isPlaying
                    ? () {
                        setState(() {
                          _basketX = (_basketX - 0.1).clamp(0.08, 0.92);
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_back_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.cardSurface,
                  foregroundColor: AppTheme.neonLime,
                  side: BorderSide(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
                ),
              ),
              const Text(
                'Geser Layar / Tekan Panah',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
              ),
              IconButton.filled(
                onPressed: _isPlaying
                    ? () {
                        setState(() {
                          _basketX = (_basketX + 0.1).clamp(0.08, 0.92);
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.cardSurface,
                  foregroundColor: AppTheme.neonLime,
                  side: BorderSide(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.neonLime.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school_rounded, color: AppTheme.neonLime, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kuis Budidaya Melon',
                            style: TextStyle(
                              color: AppTheme.creamWhite,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.neonLime.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Skor: $_quizScore',
                              style: const TextStyle(
                                color: AppTheme.neonLime,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Jawab pertanyaan agronomi untuk memperdalam pemahaman greenhouse.',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Pertanyaan Kuis
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pertanyaan #1',
                  style: TextStyle(
                    color: AppTheme.neonLime,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Berapakah rentang pH air nutrisi hidroponik yang paling optimal bagi pertumbuhan tanaman melon di greenhouse?',
                  style: TextStyle(
                    color: AppTheme.creamWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuizOption(0, 'A. pH 4.0 - 4.8'),
                const SizedBox(height: 10),
                _buildQuizOption(1, 'B. pH 5.8 - 6.5 (Ideal)'),
                const SizedBox(height: 10),
                _buildQuizOption(2, 'C. pH 7.5 - 8.5'),
                const SizedBox(height: 10),
                _buildQuizOption(3, 'D. pH 9.0 ke atas'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizOption(int index, String text) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == 1;

    Color borderColor = AppTheme.emeraldGreen.withValues(alpha: 0.3);
    Color bgColor = AppTheme.darkForest;

    if (_quizAnswered) {
      if (isCorrect) {
        borderColor = AppTheme.neonLime;
        bgColor = AppTheme.neonLime.withValues(alpha: 0.15);
      } else if (isSelected) {
        borderColor = const Color(0xFFE74C3C);
        bgColor = const Color(0xFFE74C3C).withValues(alpha: 0.15);
      }
    }

    return InkWell(
      onTap: () {
        if (_quizAnswered) return;
        setState(() {
          _selectedOption = index;
          _quizAnswered = true;
          if (isCorrect) _quizScore += 15;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _quizAnswered && isCorrect
                ? AppTheme.neonLime
                : AppTheme.creamWhite,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
