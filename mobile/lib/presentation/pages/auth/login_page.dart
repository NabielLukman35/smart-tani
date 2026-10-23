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
    // LAYAR 1: SPLASH SCREEN (DESIGN TASTE DISIPLIN)
    // ══════════════════════════════════════════════════════
    if (_stage == AuthScreenStage.splash) {
      return const Scaffold(
        backgroundColor: AppTheme.ground,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SmartTaniLogo(
                size: 84,
              ),
              SizedBox(height: 20),
              Text(
                'Smart Tani',
                style: AppTheme.display,
              ),
              SizedBox(height: 6),
              Text(
                'Greenhouse & Agronomy Console',
                style: AppTheme.bodyMuted,
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
      return const Scaffold(
        backgroundColor: AppTheme.ground,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SmartTaniLogo(
                size: 56,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Memeriksa sesi pengguna...',
                style: AppTheme.caption,
              ),
            ],
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
      backgroundColor: AppTheme.ground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Brand Header ──
                const Center(
                  child: SmartTaniLogo(
                    size: 52,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Smart Tani',
                  textAlign: TextAlign.center,
                  style: AppTheme.headline,
                ),
                const SizedBox(height: 4),
                Text(
                  isSignUp
                      ? 'Daftar akun petani baru untuk kelola lahan'
                      : 'Masuk untuk memantau greenhouse & lahan Anda',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMuted,
                ),
                const SizedBox(height: 24),

                // ── Segmented Tab Switcher (Masuk / Daftar) ──
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.panel,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.borderQuiet,
                      width: 1,
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
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: !isSignUp
                                  ? AppTheme.panelElevated
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: !isSignUp
                                  ? Border.all(
                                      color: AppTheme.borderQuiet,
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Text(
                              'Masuk',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !isSignUp
                                    ? AppTheme.ink
                                    : AppTheme.inkSecondary,
                                fontWeight: FontWeight.w600,
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
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: isSignUp
                                  ? AppTheme.panelElevated
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSignUp
                                  ? Border.all(
                                      color: AppTheme.borderQuiet,
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Text(
                              'Daftar Baru',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSignUp
                                    ? AppTheme.ink
                                    : AppTheme.inkSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── Main Card Form (Flat Tone Separation) ──
                Container(
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tombol Cepat Biometrik (jika ada sesi pengguna)
                      if (!isSignUp && authProvider.currentUser != null) ...[
                        InkWell(
                          onTap: () async {
                            final ok = await authProvider.loginWithBiometric();
                            if (ok && mounted) _navigateToHome();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            decoration: BoxDecoration(
                              color: AppTheme.panelElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.borderQuiet,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.fingerprint_rounded,
                                  color: AppTheme.accent,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Masuk Cepat Biometrik',
                                        style: TextStyle(
                                          color: AppTheme.ink,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'Akun: ${authProvider.currentUser!.nama}',
                                        style: AppTheme.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: AppTheme.inkTertiary,
                                  size: 13,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
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

                        // ── Tombol Submit Utama (Flat & Fungsional) ──
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : (isSignUp ? _handleSignUpSubmit : _handleLoginSubmit),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: AppTheme.ground,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppTheme.ground,
                                    ),
                                  )
                                : Text(
                                    isSignUp ? 'Daftar Akun Sekarang' : 'Masuk ke Aplikasi',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: -0.2,
                                    ),
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
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.inkTertiary,
                    ),
                  ),
                ],
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
        color: AppTheme.ink,
        fontSize: 13,
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
        color: AppTheme.panelElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.borderQuiet,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: AppTheme.ink, fontSize: 13.5),
        cursorColor: AppTheme.accent,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppTheme.inkTertiary, fontSize: 13),
          prefixIcon: Icon(prefixIcon, color: AppTheme.inkSecondary, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }
}
