import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local_db/database_helper.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/smart_tani_logo.dart';
import '../auth/login_page.dart';
import '../blockchain/blockchain_page.dart';
import '../greenhouse/greenhouse_map_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _userGreenhouses = [];
  bool _isLoadingGh = true;

  @override
  void initState() {
    super.initState();
    _loadUserGreenhouses();
  }

  Future<void> _loadUserGreenhouses() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user?.id != null) {
      final list = await DatabaseHelper.instance.getGreenhousesByUser(user!.id!);
      if (mounted) {
        setState(() {
          _userGreenhouses = list;
          _isLoadingGh = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingGh = false);
      }
    }
  }

  /// FR-05: Ganti foto profil dari Kamera atau Galeri
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        final auth = context.read<AuthProvider>();
        await auth.updatePhoto(picked.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Foto profil berhasil diperbarui!',
                style: TextStyle(color: AppTheme.darkForest, fontWeight: FontWeight.w700),
              ),
              backgroundColor: AppTheme.neonLime,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: const Color(0xFFE74C3C),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ganti Foto Profil',
                style: TextStyle(
                  color: AppTheme.creamWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih sumber foto untuk profil petani Anda',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppTheme.darkForest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.emeraldGreen.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.camera_alt_rounded, color: AppTheme.neonLime, size: 28),
                            SizedBox(height: 8),
                            Text(
                              'Kamera',
                              style: TextStyle(
                                color: AppTheme.creamWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppTheme.darkForest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.emeraldGreen.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.photo_library_rounded, color: AppTheme.neonLime, size: 28),
                            SizedBox(height: 8),
                            Text(
                              'Galeri',
                              style: TextStyle(
                                color: AppTheme.creamWhite,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

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
                          'Profil Akun',
                          style: TextStyle(
                            color: AppTheme.creamWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Identitas Petani & Manajemen Greenhouse (FR-05)',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    children: [
                      // ── Profile Card dengan Foto & Tombol Edit ──
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
                          children: [
                            // Avatar Foto / Inisial
                            Stack(
                              children: [
                                Container(
                                  width: 86,
                                  height: 86,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF1F6652),
                                        Color(0xFF0E3327),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppTheme.neonLime.withValues(alpha: 0.7),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.neonLime.withValues(alpha: 0.15),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: user?.fotoPath != null &&
                                          File(user!.fotoPath!).existsSync()
                                      ? Image.file(
                                          File(user.fotoPath!),
                                          fit: BoxFit.cover,
                                        )
                                      : Center(
                                          child: Text(
                                            (user?.nama.isNotEmpty == true)
                                                ? user!.nama[0].toUpperCase()
                                                : 'P',
                                            style: const TextStyle(
                                              color: AppTheme.neonLime,
                                              fontSize: 38,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _showImagePickerSheet,
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: AppTheme.neonLime,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.4),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: AppTheme.darkForest,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              user?.nama ?? 'Petani Smart Tani',
                              style: const TextStyle(
                                color: AppTheme.creamWhite,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'petani@tanigreen.id',
                              style: const TextStyle(
                                color: AppTheme.textGrey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.neonLime.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.neonLime.withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_user_rounded,
                                      color: AppTheme.neonLime, size: 14),
                                  SizedBox(width: 5),
                                  Text(
                                    'Petani Riset Terverifikasi',
                                    style: TextStyle(
                                      color: AppTheme.neonLime,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Saldo Token Reward Card (FR-13) ──
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BlockchainPage()),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.token_rounded,
                                  color: Colors.amber,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Saldo Token Reward (FR-13)',
                                      style: TextStyle(
                                        color: AppTheme.textGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${user?.saldoToken ?? 0} Token Tani',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppTheme.textGrey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── DAFTAR GREENHOUSE MILIK PENGGUNA (FR-05) ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(20),
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
                                const Row(
                                  children: [
                                    Icon(Icons.roofing_rounded,
                                        color: AppTheme.neonLime, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Daftar Greenhouse Saya',
                                      style: TextStyle(
                                        color: AppTheme.creamWhite,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const GreenhouseMapPage()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Peta GPS →',
                                    style: TextStyle(
                                      color: AppTheme.neonLime,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_isLoadingGh)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.neonLime,
                                  ),
                                ),
                              )
                            else if (_userGreenhouses.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkForest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        color: AppTheme.textGrey, size: 18),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Belum ada data greenhouse terdaftar.',
                                        style: TextStyle(
                                            color: AppTheme.textGrey, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _userGreenhouses.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (ctx, idx) {
                                  final gh = _userGreenhouses[idx];
                                  final nama = gh['nama_greenhouse'] ?? 'Greenhouse #${gh['id']}';
                                  final alamat = gh['alamat'] ?? 'Sleman, D.I. Yogyakarta';
                                  final luas = gh['luas'] != null ? '${gh['luas']} m²' : '150 m²';
                                  final status = gh['status'] ?? 'Optimal';

                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.darkForest,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppTheme.emeraldGreen.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.neonLime.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.roofing_rounded,
                                            color: AppTheme.neonLime,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                nama,
                                                style: const TextStyle(
                                                  color: AppTheme.creamWhite,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '$alamat • Luas $luas',
                                                style: const TextStyle(
                                                  color: AppTheme.textGrey,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            status,
                                            style: const TextStyle(
                                              color: Color(0xFF2ECC71),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Security & Biometric Status (FR-01, FR-02) ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.emeraldGreen.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.fingerprint_rounded,
                                  color: AppTheme.neonLime,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Autentikasi Biometrik',
                                        style: TextStyle(
                                          color: AppTheme.creamWhite,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'Login cepat sidik jari / Face Unlock (FR-02)',
                                        style: TextStyle(
                                          color: AppTheme.textGrey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: user?.biometrikAktif ?? false,
                                  activeThumbColor: AppTheme.neonLime,
                                  activeTrackColor: AppTheme.neonLime.withValues(alpha: 0.4),
                                  onChanged: (val) async {
                                    final success = await authProvider.setBiometricEnabled(val);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? (val
                                                    ? 'Autentikasi biometrik berhasil diaktifkan.'
                                                    : 'Autentikasi biometrik dinonaktifkan.')
                                                : 'Gagal memperbarui status biometrik.',
                                            style: const TextStyle(
                                              color: AppTheme.darkForest,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor: AppTheme.neonLime,
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const Divider(
                              color: Color(0xFF143B31),
                              height: 24,
                            ),
                            const Row(
                              children: [
                                Icon(
                                  Icons.security_rounded,
                                  color: AppTheme.pastelLime,
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Keamanan Sandi Enkripsi Custom',
                                        style: TextStyle(
                                          color: AppTheme.creamWhite,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'Salt kustom + permutasi acak lokal (FR-01)',
                                        style: TextStyle(
                                          color: AppTheme.textGrey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppTheme.neonLime,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Logout Button ──
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppTheme.cardSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                                  ),
                                ),
                                title: const Text(
                                  'Konfirmasi Keluar',
                                  style: TextStyle(color: AppTheme.creamWhite),
                                ),
                                content: const Text(
                                  'Apakah Anda yakin ingin keluar dari akun Smart Tani ini?',
                                  style: TextStyle(color: AppTheme.textGrey),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text('Batal',
                                        style: TextStyle(color: AppTheme.textGrey)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE74C3C),
                                    ),
                                    child: const Text('Keluar',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              await authProvider.logout();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                  (route) => false,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFE74C3C).withValues(alpha: 0.15),
                            foregroundColor: const Color(0xFFFF6B6B),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: const Color(0xFFE74C3C).withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: const Text(
                            'Keluar dari Akun',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
