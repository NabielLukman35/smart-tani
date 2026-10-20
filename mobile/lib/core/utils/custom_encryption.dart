import 'dart:convert';
import 'dart:math';

class CustomEncryption {
  static const String _secretKey = 'TaniGreen_PAM_2026_Key';

  /// Membuat salt acak sepanjang 16 karakter untuk setiap pengguna baru
  static String generateSalt([int length = 16]) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final rnd = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  /// FR-01: Enkripsi Custom (Salt + Substitusi XOR/Shift + Permutasi Blok)
  static String encryptPassword(String plainPassword, String salt) {
    final combined = '$salt:$plainPassword:$_secretKey';
    final bytes = utf8.encode(combined);
    final keyBytes = utf8.encode(salt + _secretKey);

    // 1. Transformasi Substitusi (XOR dengan kunci + pergeseran nilai byte)
    List<int> substituted = List<int>.generate(bytes.length, (i) {
      int k = keyBytes[i % keyBytes.length];
      return ((bytes[i] ^ k) + (i * 7)) % 256;
    });

    // 2. Transformasi Permutasi (Membalik urutan pasangan indeks ganjil-genap)
    for (int i = 0; i < substituted.length - 1; i += 2) {
      int temp = substituted[i];
      substituted[i] = substituted[i + 1];
      substituted[i + 1] = temp;
    }

    // 3. Encode hasil akhir menjadi heksadesimal ciphertext
    return substituted.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Verifikasi apakah password input cocok dengan ciphertext di database
  static bool verifyPassword(String inputPassword, String salt, String storedCiphertext) {
    final encryptedInput = encryptPassword(inputPassword, salt);
    return encryptedInput == storedCiphertext;
  }
}