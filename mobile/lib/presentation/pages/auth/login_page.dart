import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/smart_tani_logo.dart';
import '../main_layout.dart';

enum AuthScreenStage {
  splash,
  waiting,
  signIn,
  signUp,
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  AuthScreenStage _stage = AuthScreenStage.splash;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _startFlow());
  }

  /// Menjalankan alur Splash -> Waiting (Cek Sesi & Biometrik) -> Auth Screen
  Future<void> _startFlow() async {
    // 1. Tampilkan Splash Screen berkelas
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() => _stage = AuthScreenStage.waiting);

    // 2. Waiting Screen: Cek sesi lokal sesuai Alur 1 Bagian 9 PRD
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final savedUser = await authProvider.checkSavedSession();

    if (savedUser != null) {
      if (savedUser.biometrikAktif) {
        final bioSuccess = await authProvider.loginWithBiometric();
        if (bioSuccess && mounted) {
          _navigateToHome();
          return;
        }
      } else {
        if (mounted) {
          _navigateToHome();
          return;
        }
      }
    }

    // Jika tidak ada sesi atau biometrik gagal -> masuk ke SignIn Screen
    if (mounted) {
      setState(() => _stage = AuthScreenStage.signIn);
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  Future<void> _handleLoginSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Masukkan alamat email yang valid.');
      return;
    }
    if (password.isEmpty) {
      _showSnackBar('Masukkan kata sandi akun Anda.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: email,
      password: password,
    );

    if (success && mounted) {
      _navigateToHome();
    } else if (auth.errorMessage != null && mounted) {
      _showSnackBar(auth.errorMessage!);
    }
  }

  Future<void> _handleSignUpSubmit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.length < 4) {
      _showSnackBar('Lengkapi nama, email, dan password (min. 4 karakter).');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      nama: name,
      email: email,
      password: password,
    );

    if (success && mounted) {
      _navigateToHome();
    } else if (auth.errorMessage != null && mounted) {
      _showSnackBar(auth.errorMessage!);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: AppTheme.darkForest,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.neonLime,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ══════════════════════════════════════════════════════
    // LAYAR 1: SPLASH SCREEN (PREMIUM BRAND IDENTITY)
    // ══════════════════════════════════════════════════════
    if (_stage == AuthScreenStage.splash) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient radial glow di belakang logo
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonLime.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SmartTaniLogo(
                    size: 80,
                    variant: SmartTaniLogoVariant.neonLime,
                    showBadge: true,
                    hasGlow: true,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SMART TANI',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                      color: AppTheme.neonLime,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Smart Greenhouse & Agriculture Intelligence',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      color: AppTheme.pastelLime.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 36,
                child: Text(
                  'v0.1.0 • Modern Agriculture',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textGrey.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ══════════════════════════════════════════════════════
    // LAYAR 2: WAITING / SESSION CHECK SCREEN
    // ══════════════════════════════════════════════════════
    if (_stage == AuthScreenStage.waiting) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SmartTaniLogo(
                  size: 56,
                  variant: SmartTaniLogoVariant.neonLime,
                  showBadge: true,
                  hasGlow: true,
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.8,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonLime),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Memeriksa sesi pengguna...',
                  style: TextStyle(
                    color: AppTheme.pastelLime.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ══════════════════════════════════════════════════════
    // LAYAR 3: SIGN IN & SIGN UP FORM (MODERN ERGONOMIS)
    // ══════════════════════════════════════════════════════
    final authProvider = context.watch<AuthProvider>();
    final isSignUp = _stage == AuthScreenStage.signUp;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Brand Header ──
                  const SmartTaniLogo(
                    size: 52,
                    variant: SmartTaniLogoVariant.neonLime,
                    showBadge: true,
                    hasGlow: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Smart Tani',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppTheme.creamWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSignUp
                        ? 'Daftar akun petani baru dan mulai kelola tanaman'
                        : 'Masuk untuk memantau greenhouse & lahan Anda',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textGrey,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Segmented Tab Switcher (Masuk / Daftar) ──
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSpruce,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _stage = AuthScreenStage.signIn);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isSignUp
                                    ? AppTheme.neonLime
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Masuk',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !isSignUp
                                      ? AppTheme.darkForest
                                      : AppTheme.textGrey,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _stage = AuthScreenStage.signUp);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSignUp
                                    ? AppTheme.neonLime
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Daftar Baru',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSignUp
                                      ? AppTheme.darkForest
                                      : AppTheme.textGrey,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Main Card Form ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppTheme.emeraldGreen.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tombol Cepat Biometrik (jika ada sesi pengguna)
                        if (!isSignUp && authProvider.currentUser != null) ...[
                          InkWell(
                            onTap: () async {
                              final ok = await authProvider.loginWithBiometric();
                              if (ok && mounted) _navigateToHome();
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.neonLime.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppTheme.neonLime.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonLime.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.fingerprint_rounded,
                                      color: AppTheme.neonLime,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Masuk Cepat Biometrik',
                                          style: TextStyle(
                                            color: AppTheme.neonLime,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'Akun: ${authProvider.currentUser!.nama}',
                                          style: TextStyle(
                                            color: AppTheme.pastelLime.withValues(alpha: 0.7),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: AppTheme.neonLime,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'atau gunakan password',
                                  style: TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Input Nama (Hanya mode SignUp)
                        if (isSignUp) ...[
                          _buildFieldLabel('Nama Lengkap Petani'),
                          const SizedBox(height: 6),
                          _buildInputField(
                            controller: _nameController,
                            hintText: 'Contoh: Budi Santoso',
                            prefixIcon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Input Email
                        _buildFieldLabel('Alamat Email'),
                        const SizedBox(height: 6),
                        _buildInputField(
                          controller: _emailController,
                          hintText: 'petani@smarthouse.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Input Password
                        _buildFieldLabel('Kata Sandi'),
                        const SizedBox(height: 6),
                        _buildInputField(
                          controller: _passwordController,
                          hintText: 'Masukkan kata sandi...',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppTheme.textGrey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),

                        // Catatan Enkripsi FR-01
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 13,
                              color: AppTheme.pastelLime,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                isSignUp
                                    ? 'Diamankan dengan Salt Hash SHA-256 Offline (FR-01)'
                                    : 'Koneksi lokal terenkripsi & aman',
                                style: const TextStyle(
                                  color: AppTheme.textGrey,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── Tombol Submit Utama (Gradient Lime Button) ──
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : (isSignUp ? _handleSignUpSubmit : _handleLoginSubmit),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonLime,
                              foregroundColor: AppTheme.darkForest,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppTheme.darkForest,
                                    ),
                                  )
                                : Text(
                                    isSignUp ? 'Daftar Akun Sekarang' : 'Masuk ke Aplikasi',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tombol Tambahan: Opsi Masuk Cepat / Google
                        OutlinedButton.icon(
                          onPressed: () {
                            _showSnackBar(
                              'Fitur Google Auth opsional, silakan masuk langsung menggunakan email & password.',
                            );
                          },
                          icon: const Icon(
                            Icons.g_mobiledata_rounded,
                            size: 24,
                            color: AppTheme.pastelLime,
                          ),
                          label: const Text(
                            'Lanjut dengan Google',
                            style: TextStyle(
                              color: AppTheme.pastelLime,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Footer Terms & Privacy ──
                  Text(
                    'Dengan melanjutkan, Anda menyetujui Ketentuan Layanan\ndan Kebijakan Privasi Smart Tani.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textGrey.withValues(alpha: 0.7),
                      fontSize: 10.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.creamWhite,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.emeraldGreen.withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: AppTheme.creamWhite, fontSize: 13.5),
        cursorColor: AppTheme.neonLime,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
          prefixIcon: Icon(prefixIcon, color: AppTheme.neonLime, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
