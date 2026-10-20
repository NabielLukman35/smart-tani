class GreenhouseModel {
  final int? id;
  final int penggunaId;
  final String namaGreenhouse;
  final double latitude;
  final double longitude;
  final String alamat;
  final double luas;
  final String status; // Contoh: 'Normal', 'Perlu Perhatian', 'Terlambat'
  final String syncStatus; // FR-03: 'Menunggu Unggah' atau 'Tersinkron'

  GreenhouseModel({
    this.id,
    required this.penggunaId,
    required this.namaGreenhouse,
    required this.latitude,
    required this.longitude,
    required this.alamat,
    required this.luas,
    this.status = 'Normal',
    this.syncStatus = 'Menunggu Unggah',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pengguna_id': penggunaId,
      'nama_greenhouse': namaGreenhouse,
      'latitude': latitude,
      'longitude': longitude,
      'alamat': alamat,
      'luas': luas,
      'status': status,
      'sync_status': syncStatus,
    };
  }

  factory GreenhouseModel.fromMap(Map<String, dynamic> map) {
    return GreenhouseModel(
      id: map['id'],
      penggunaId: map['pengguna_id'],
      namaGreenhouse: map['nama_greenhouse'],
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      alamat: map['alamat'] ?? '',
      luas: (map['luas'] as num).toDouble(),
      status: map['status'] ?? 'Normal',
      syncStatus: map['sync_status'] ?? 'Menunggu Unggah',
    );
  }
}