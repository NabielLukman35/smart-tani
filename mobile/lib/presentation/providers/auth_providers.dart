import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/biometric_services.dart';
import '../../core/utils/custom_encryption.dart';
import '../../data/local_db/database_helper.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final BiometricService _biometricService = BiometricService();

  static const String _sessionUserIdKey = 'session_user_id';

  /// Alur 1 PRD: Cek sesi lokal saat aplikasi dibuka
  Future<UserModel?> checkSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt(_sessionUserIdKey);
    if (savedUserId == null) return null;

    final user = await DatabaseHelper.instance.getUserById(savedUserId);
    _currentUser = user;
    notifyListeners();
    return user;
  }

  /// Memperbarui data pengguna terkini dari SQLite (misal saldo token setelah kuis)
  Future<void> refreshCurrentUser() async {
    if (_currentUser?.id != null) {
      final user = await DatabaseHelper.instance.getUserById(_currentUser!.id!);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    }
  }

  /// FR-02: Mengaktifkan atau menonaktifkan autentikasi biometrik pengguna
  Future<bool> setBiometricEnabled(bool isEnabled) async {
    if (_currentUser == null || _currentUser!.id == null) return false;
    final rows = await DatabaseHelper.instance.updateBiometricStatus(_currentUser!.id!, isEnabled);
    if (rows > 0) {
      _currentUser = _currentUser!.copyWith(biometrikAktif: isEnabled);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// FR-02: Autentikasi Biometrik untuk membuka sesi tersimpan
  Future<bool> loginWithBiometric() async {
    if (_currentUser == null) return false;
    final available = await _biometricService.isBiometricAvailable();
    if (!available) {
      _errorMessage = 'Sensor biometrik tidak tersedia di perangkat ini.';
      notifyListeners();
      return false;
    }

    final authenticated = await _biometricService.authenticate();
    if (!authenticated) {
      _errorMessage = 'Autentikasi biometrik dibatalkan. Silakan gunakan password.';
      notifyListeners();
    }
    return authenticated;
  }

  /// Cek apakah email sudah terdaftar di database lokal
  Future<bool> checkEmailExists(String email) async {
    final user = await DatabaseHelper.instance.getUserByEmail(email);
    return user != null;
  }

  /// FR-01: Registrasi pengguna baru dengan enkripsi custom
  Future<bool> register({
    required String nama,
    required String email,
    required String password,
    bool enableBiometric = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim().toLowerCase();
      final existing = await DatabaseHelper.instance.getUserByEmail(cleanEmail);
      if (existing != null) {
        _errorMessage = 'Email sudah terdaftar. Silakan login.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Buat salt acak & enkripsi password dengan algoritma custom
      final salt = CustomEncryption.generateSalt();
      final encryptedPassword = CustomEncryption.encryptPassword(password, salt);

      final newUser = UserModel(
        nama: nama.trim(),
        email: cleanEmail,
        passwordTerenkripsi: encryptedPassword,
        salt: salt,
        biometrikAktif: enableBiometric,
        saldoToken: 10, // Token awal simulasi
        dibuatPada: DateTime.now().toUtc().toIso8601String(),
      );

      final id = await DatabaseHelper.instance.insertUser(newUser);
      _currentUser = await DatabaseHelper.instance.getUserById(id);

      // Simpan sesi lokal
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionUserIdKey, id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat registrasi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// FR-01: Login pengguna dengan verifikasi hash password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim().toLowerCase();
      final user = await DatabaseHelper.instance.getUserByEmail(cleanEmail);

      if (user == null) {
        _errorMessage = 'Akun dengan email ini tidak ditemukan.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final isValid = CustomEncryption.verifyPassword(
        password,
        user.salt,
        user.passwordTerenkripsi,
      );

      if (!isValid) {
        _errorMessage = 'Password yang kamu masukkan salah.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_sessionUserIdKey, user.id!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// FR-01: Logout & hapus sesi lokal
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionUserIdKey);
    _currentUser = null;
    notifyListeners();
  }
}
