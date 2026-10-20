class UserModel {
  final int? id;
  final String nama;
  final String email;
  final String passwordTerenkripsi;
  final String salt;
  final String? fotoPath;
  final bool biometrikAktif;
  final int saldoToken;
  final String dibuatPada;

  UserModel({
    this.id,
    required this.nama,
    required this.email,
    required this.passwordTerenkripsi,
    required this.salt,
    this.fotoPath,
    this.biometrikAktif = false,
    this.saldoToken = 0,
    required this.dibuatPada,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'password_terenkripsi': passwordTerenkripsi,
      'salt': salt,
      'foto_path': fotoPath,
      'biometrik_aktif': biometrikAktif ? 1 : 0,
      'saldo_token': saldoToken,
      'dibuat_pada': dibuatPada,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      email: map['email'] as String,
      passwordTerenkripsi: map['password_terenkripsi'] as String,
      salt: map['salt'] as String,
      fotoPath: map['foto_path'] as String?,
      biometrikAktif: (map['biometrik_aktif'] ?? 0) == 1,
      saldoToken: (map['saldo_token'] ?? 0) as int,
      dibuatPada: map['dibuat_pada'] as String,
    );
  }
}