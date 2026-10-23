import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database_helper.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/custom_sub_app_bar.dart';

class BlockchainPage extends StatefulWidget {
  const BlockchainPage({super.key});

  @override
  State<BlockchainPage> createState() => _BlockchainPageState();
}

class _BlockchainPageState extends State<BlockchainPage> {
  List<Map<String, dynamic>> _blocks = [];
  bool _isLoading = true;
  bool _isVerifying = false;
  bool? _isChainValid;

  @override
  void initState() {
    super.initState();
    _loadBlockchain();
  }

  Future<void> _loadBlockchain() async {
    final logs = await DatabaseHelper.instance.getAllBlokLogs();
    if (logs.isEmpty) {
      // Inisialisasi Genesis Block sesuai FR-13
      const genesisData = 'Genesis Block - Inisialisasi Sistem Smart Greenhouse TaniGreen';
      const prevHash = '0000000000000000000000000000000000000000000000000000000000000000';
      final timestamp = DateTime.now().toUtc().toIso8601String();
      final genesisHash = sha256.convert(utf8.encode('$genesisData$prevHash$timestamp')).toString();

      await DatabaseHelper.instance.insertBlokLog({
        'log_id': 0,
        'data_log': genesisData,
        'hash': genesisHash,
        'hash_sebelumnya': prevHash,
        'timestamp': timestamp,
      });

      final refreshed = await DatabaseHelper.instance.getAllBlokLogs();
      if (mounted) {
        setState(() {
          _blocks = refreshed;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _blocks = logs;
          _isLoading = false;
        });
      }
    }
  }

  /// FR-13: Verifikasi Integritas Rantai Hash ("Bukti Log Tidak Bisa Dimanipulasi")
  Future<void> _verifyChainIntegrity() async {
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(milliseconds: 600));

    bool valid = true;
    for (int i = 0; i < _blocks.length; i++) {
      final block = _blocks[i];
      final dataLog = block['data_log'] as String;
      final prevHash = block['hash_sebelumnya'] as String;
      final timestamp = block['timestamp'] as String;
      final currentHash = block['hash'] as String;

      // Hitung ulang hash: SHA-256(data log + hash_sebelumnya + timestamp)
      final expectedHash = sha256.convert(utf8.encode('$dataLog$prevHash$timestamp')).toString();

      if (currentHash != expectedHash) {
        valid = false;
        break;
      }

      // Validasi keterkaitan rantai dengan blok sebelumnya
      if (i > 0) {
        final previousBlock = _blocks[i - 1];
        if (prevHash != previousBlock['hash']) {
          valid = false;
          break;
        }
      }
    }

    if (mounted) {
      setState(() {
        _isVerifying = false;
        _isChainValid = valid;
      });
    }
  }

  /// FR-13: Catat Log Perawatan Baru & Buat Hash Block Baru + Reward Token
  Future<void> _showAddLogDialog() async {
    final textCtrl = TextEditingController();
    final actionOptions = [
      'Pemberian Nutrisi AB Mix Melon (EC 2.2 mS/cm)',
      'Polinasi Bunga Betina Melon Inthanon',
      'Penyemprotan Biopestisida Nabati Daun Nimba',
      'Pembersihan Filter Irigasi Tetes Drip Sistem',
      'Pengecekan Sensor Suhu & Kelembapan ESP32',
    ];
    String selectedAction = actionOptions.first;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: AppTheme.emeraldGreen.withValues(alpha: 0.5)),
          ),
          title: const Row(
            children: [
              Icon(Icons.add_link_rounded, color: AppTheme.neonLime, size: 24),
              SizedBox(width: 8),
              Text(
                'Catat Log & Buat Blok',
                style: TextStyle(
                  color: AppTheme.creamWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Setiap log perawatan yang dicatat akan disegel dengan hash SHA-256 dan memberikan +5 Reward Token Tani!',
                  style: TextStyle(color: AppTheme.pastelLime, fontSize: 12),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Jenis Tindakan Perawatan:',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkForest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedAction,
                      isExpanded: true,
                      dropdownColor: AppTheme.cardSurface,
                      icon: const Icon(Icons.arrow_drop_down_rounded, color: AppTheme.neonLime),
                      style: const TextStyle(color: AppTheme.creamWhite, fontSize: 12.5),
                      items: actionOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt,
                          child: Text(opt, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedAction = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Catatan Tambahan / Hasil Observasi:',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: textCtrl,
                  style: const TextStyle(color: AppTheme.creamWhite, fontSize: 13),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Kondisi tanaman prima, daun hijau gelap.',
                    hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.darkForest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.emeraldGreen.withValues(alpha: 0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.neonLime),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: AppTheme.textGrey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonLime,
                foregroundColor: AppTheme.darkForest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Segel Blok (+5 Token)', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      final auth = context.read<AuthProvider>();
      final userId = auth.currentUser?.id ?? 1;

      // Ambil block terakhir untuk prevHash
      final lastBlock = await DatabaseHelper.instance.getLastBlokLog();
      final prevHash = lastBlock?['hash'] ?? '0000000000000000000000000000000000000000000000000000000000000000';
      final logText = '$selectedAction. ${textCtrl.text.trim()}';
      final timestamp = DateTime.now().toUtc().toIso8601String();

      // Formula FR-13: hash = SHA-256(data log + hash_sebelumnya + timestamp)
      final newHash = sha256.convert(utf8.encode('$logText$prevHash$timestamp')).toString();

      await DatabaseHelper.instance.insertBlokLog({
        'log_id': (_blocks.length),
        'data_log': logText,
        'hash': newHash,
        'hash_sebelumnya': prevHash,
        'timestamp': timestamp,
      });

      // Berikan reward token simulasi
      await DatabaseHelper.instance.addRewardToken(userId, 5);
      await auth.refreshUser();

      await _loadBlockchain();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.token_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Blok baru berhasil disegel! +5 Token Tani reward telah ditambahkan ke saldo Anda.',
                    style: TextStyle(color: AppTheme.darkForest, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.neonLime,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppTheme.ground,
        child: SafeArea(
          child: Column(
            children: [
              CustomSubAppBar(
                title: 'Blockchain & Hash Chain',
                subtitle: 'Integritas Log Perawatan & Token Reward (FR-13)',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.token_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${user?.saldoToken ?? 0} Token',
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

              // Banner Ringkasan & Tombol Aksi Verifikasi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                          const Row(
                            children: [
                              Icon(Icons.hub_rounded, color: AppTheme.neonLime, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Hash Chain SHA-256',
                                style: TextStyle(
                                  color: AppTheme.creamWhite,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.neonLime.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_blocks.length} Blok Tersimpan',
                              style: const TextStyle(
                                color: AppTheme.neonLime,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Formula: hash = SHA-256(data log + hash_sebelumnya + timestamp). Log ini berfungsi sebagai bukti perawatan varietas melon yang tidak bisa dimanipulasi.',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 11.5, height: 1.35),
                      ),
                      const SizedBox(height: 14),

                      // Tombol Verifikasi & Tambah Blok
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isVerifying ? null : _verifyChainIntegrity,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.cardSurface,
                                foregroundColor: AppTheme.neonLime,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: AppTheme.neonLime.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              icon: _isVerifying
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.neonLime,
                                      ),
                                    )
                                  : const Icon(Icons.verified_rounded, size: 18),
                              label: const Text(
                                'Cek Integritas',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showAddLogDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonLime,
                                foregroundColor: AppTheme.darkForest,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                              label: const Text(
                                '+ Catat Log',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Status Hasil Verifikasi Rantai
                      if (_isChainValid != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _isChainValid!
                                ? const Color(0xFF2ECC71).withValues(alpha: 0.15)
                                : const Color(0xFFE74C3C).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isChainValid!
                                  ? const Color(0xFF2ECC71)
                                  : const Color(0xFFE74C3C),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isChainValid!
                                    ? Icons.check_circle_rounded
                                    : Icons.error_rounded,
                                color: _isChainValid!
                                    ? const Color(0xFF2ECC71)
                                    : const Color(0xFFFF6B6B),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _isChainValid!
                                      ? 'Bukti Log Tidak Bisa Dimanipulasi! Seluruh rantai SHA-256 100% Valid & Sah.'
                                      : 'Peringatan! Rantai hash terindikasi mengalami perubahan / manipulasi.',
                                  style: TextStyle(
                                    color: _isChainValid!
                                        ? const Color(0xFF2ECC71)
                                        : const Color(0xFFFF6B6B),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Rantai Blok Vertikal
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.neonLime),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: _blocks.length,
                        separatorBuilder: (_, __) => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Icon(Icons.link_rounded, color: AppTheme.pastelLime, size: 22),
                          ),
                        ),
                        itemBuilder: (ctx, idx) {
                          final block = _blocks[idx];
                          final id = block['id'];
                          final data = block['data_log'] ?? '';
                          final hash = block['hash'] ?? '';
                          final prevHash = block['hash_sebelumnya'] ?? '';
                          final time = block['timestamp'] ?? '';
                          final isGenesis = idx == 0;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isGenesis
                                    ? Colors.amber.withValues(alpha: 0.5)
                                    : AppTheme.emeraldGreen.withValues(alpha: 0.35),
                                width: isGenesis ? 1.5 : 1,
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
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: isGenesis
                                                ? Colors.amber.withValues(alpha: 0.15)
                                                : AppTheme.neonLime.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            isGenesis ? Icons.auto_awesome_rounded : Icons.token_rounded,
                                            color: isGenesis ? Colors.amber : AppTheme.neonLime,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isGenesis ? 'Blok #0 (Genesis)' : 'Blok #$id',
                                          style: TextStyle(
                                            color: isGenesis ? Colors.amber : AppTheme.creamWhite,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      time.length >= 16 ? time.substring(0, 16).replaceAll('T', ' ') : time,
                                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  data,
                                  style: const TextStyle(
                                    color: AppTheme.creamWhite,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Prev Hash
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.darkForest,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Hash Sebelumnya (Prev):',
                                        style: TextStyle(color: AppTheme.textGrey, fontSize: 9.5),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        prevHash,
                                        style: TextStyle(
                                          color: AppTheme.textGrey.withValues(alpha: 0.8),
                                          fontFamily: 'monospace',
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Hash Blok Ini (Current SHA-256):',
                                        style: TextStyle(color: AppTheme.neonLime, fontSize: 9.5, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        hash,
                                        style: const TextStyle(
                                          color: AppTheme.neonLime,
                                          fontFamily: 'monospace',
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
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
}
