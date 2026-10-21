class FruitRecommendation {
  final String namaBuah;
  final String varietasUnggul;
  final String kecocokanKetinggian;
  final String suhuIdeal;
  final String estimasiPanen;
  final String potensiHasil;
  final String alasanRekomendasi;
  final String kebutuhanLuas;

  const FruitRecommendation({
    required this.namaBuah,
    required this.varietasUnggul,
    required this.kecocokanKetinggian,
    required this.suhuIdeal,
    required this.estimasiPanen,
    required this.potensiHasil,
    required this.alasanRekomendasi,
    required this.kebutuhanLuas,
  });
}

class IotRecommendation {
  final String namaPerangkat;
  final String tipe; // Sensor / Aktuator / Kontroler
  final String spesifikasi;
  final String fungsiUtama;
  final String nilaiIdeal;

  const IotRecommendation({
    required this.namaPerangkat,
    required this.tipe,
    required this.spesifikasi,
    required this.fungsiUtama,
    required this.nilaiIdeal,
  });
}

class RecommendationHelper {
  /// Analisis LBS untuk Rekomendasi Buah Berdasarkan Koordinat & Luas Lahan
  static List<FruitRecommendation> getFruitRecommendations({
    required double latitude,
    required double longitude,
    required double luasAreaM2,
  }) {
    // Estimasi ketinggian/wilayah berdasarkan pola koordinat tropis Indonesia
    // Contoh: wilayah pegunungan selatan/utara Jawa vs dataran rendah
    final bool isHighland = latitude < -7.5 && latitude > -7.8 && longitude > 110.4;

    List<FruitRecommendation> list = [];

    // 1. Melon Golden (Fokus Utama PRD)
    list.add(const FruitRecommendation(
      namaBuah: 'Melon Golden Emerald / Honey Globe',
      varietasUnggul: 'Cucumis melo L. var. Reticulatus',
      kecocokanKetinggian: 'Dataran Rendah - Menengah (50 - 500 mdpl)',
      suhuIdeal: '24°C - 32°C (Pencahayaan penuh)',
      estimasiPanen: '65 - 75 Hari Setelah Tanam',
      potensiHasil: '2.0 - 2.8 kg / tanaman (Brix 13 - 15%)',
      alasanRekomendasi:
          'Sangat cocok untuk greenhouse sistem trellis vertikal. Nilai jual pasar modern tinggi dan tahan cuaca tropis.',
      kebutuhanLuas: 'Ideal untuk luas lahan ≥ 100 m² (Kepadatan 2.5 tanaman/m²)',
    ));

    // 2. Tomat Cherry
    list.add(const FruitRecommendation(
      namaBuah: 'Tomat Cherry Ruby',
      varietasUnggul: 'Solanum lycopersicum var. cerasiforme',
      kecocokanKetinggian: 'Semua Ketinggian (0 - 1200 mdpl)',
      suhuIdeal: '20°C - 28°C',
      estimasiPanen: '60 - 70 Hari (Panen berkala tiap 3 hari)',
      potensiHasil: '3.0 - 4.5 kg / tanaman per musim',
      alasanRekomendasi:
          'Perawatan relatif mudah dengan sistem irigasi tetes (drip fertigation) dan perputaran kas cepat.',
      kebutuhanLuas: 'Fleksibel, dapat dibudidayakan mulai luas 30 m²',
    ));

    // 3. Stroberi (Bila dataran tinggi / sejuk)
    if (isHighland || luasAreaM2 < 150) {
      list.add(const FruitRecommendation(
        namaBuah: 'Stroberi Sweet Charlie / California',
        varietasUnggul: 'Fragaria × ananassa',
        kecocokanKetinggian: 'Dataran Tinggi / Greenhouse Berpendingin (≥ 600 mdpl)',
        suhuIdeal: '16°C - 24°C',
        estimasiPanen: '60 - 80 Hari',
        potensiHasil: '400 - 600 gram / polibag',
        alasanRekomendasi:
          'Sangat ideal untuk sistem talang bertingkat (A-frame vertikultur) hemat ruang.',
        kebutuhanLuas: 'Optimal untuk lahan terbatas 50 - 200 m²',
      ));
    }

    // 4. Semangka Inul Hidroponik
    list.add(const FruitRecommendation(
      namaBuah: 'Semangka Baby Inul Kuning / Merah',
      varietasUnggul: 'Citrullus lanatus Hibrida',
      kecocokanKetinggian: 'Dataran Rendah (0 - 400 mdpl)',
      suhuIdeal: '26°C - 34°C',
      estimasiPanen: '55 - 65 Hari',
      potensiHasil: '2.5 - 3.5 kg / buah (1 buah per pohon)',
      alasanRekomendasi:
          'Kebutuhan air terukur via sensor kelembapan tanah, masa panen singkat, dan manis renyah.',
      kebutuhanLuas: 'Dianjurkan luas ≥ 150 m²',
    ));

    // 5. Anggur Shine Muscat Greenhouse
    if (luasAreaM2 >= 200) {
      list.add(const FruitRecommendation(
        namaBuah: 'Anggur Shine Muscat / Tamaki',
        varietasUnggul: 'Vitis vinifera L.',
        kecocokanKetinggian: 'Dataran Rendah - Sedang',
        suhuIdeal: '22°C - 32°C (Wajib atap UV Greenhouse)',
        estimasiPanen: 'Tahun ke-1 (Panen 2x per tahun)',
        potensiHasil: '8 - 15 kg / pohon dewasa',
        alasanRekomendasi:
            'Komoditas buah bernilai ekonomi sangat tinggi. Atap greenhouse melindunginya 100% dari jamur hujan.',
        kebutuhanLuas: 'Dianjurkan luas ≥ 200 m² (sistem para-para / pergola)',
      ));
    }

    return list;
  }

  /// Rekomendasi Perangkat Sensor & Aktuator IoT Sesuai Standar Smart Greenhouse
  static List<IotRecommendation> getIotRecommendations() {
    return const [
      IotRecommendation(
        namaPerangkat: 'Sensor Suhu & Kelembapan Udara (DHT22 / SHT31)',
        tipe: 'Sensor Lingkungan',
        spesifikasi: 'Rentang suhu -40 s.d 80°C, RH 0-100%, akurasi ±0.5°C',
        fungsiUtama: 'Memantau iklim mikro ruang greenhouse guna mencegah stres panas tanaman.',
        nilaiIdeal: 'Suhu 24 - 30°C, Kelembapan 65 - 75%',
      ),
      IotRecommendation(
        namaPerangkat: 'Capacitive Soil Moisture Sensor v1.2',
        tipe: 'Sensor Media Tanam',
        spesifikasi: 'Output analog anti-korosi resistan korosi air nutrisi',
        fungsiUtama: 'Mendeteksi kadar kejenuhan air dan larutan nutrisi pada cocopeat / tanah.',
        nilaiIdeal: 'Kelembapan 55 - 75% (Aktifkan pompa jika < 45%)',
      ),
      IotRecommendation(
        namaPerangkat: 'Sensor Intensitas Cahaya (BH1750 Lux Meter / LDR)',
        tipe: 'Sensor Radiasi',
        spesifikasi: 'Rentang 1 - 65535 Lux, komunikasi I2C akurat',
        fungsiUtama: 'Mengukur kecukupan fotosintesis dan pemicu motor paranet peneduh.',
        nilaiIdeal: '25.000 - 45.000 Lux (Fase pembesaran buah)',
      ),
      IotRecommendation(
        namaPerangkat: 'Smart Drip Irrigation Kit (Solenoid + Pompa DC)',
        tipe: 'Aktuator Otomasi',
        spesifikasi: '12V DC Pump, manifold 4 cabang dengan dripper 2L/jam',
        fungsiUtama: 'Menyalurkan air nutrisi AB Mix tepat ke zona perakaran secara terprogram.',
        nilaiIdeal: 'Frekuensi 4 - 6 kali sehari (durasi 2-3 menit)',
      ),
      IotRecommendation(
        namaPerangkat: 'Exhaust Fan & High Pressure Misting System',
        tipe: 'Aktuator Iklim',
        spesifikasi: 'Relay ESP32 4-Channel + Nozzle embun 0.2mm anti-drip',
        fungsiUtama: 'Menurunkan suhu greenhouse secara cepat saat terik siang hari.',
        nilaiIdeal: 'Aktif otomatis jika suhu sensor > 32°C',
      ),
      IotRecommendation(
        namaPerangkat: 'Mikrokontroler Utama (ESP32 NodeMCU Wi-Fi/BT)',
        tipe: 'Pusat Kontroler',
        spesifikasi: 'Dual-core 240MHz, Wi-Fi 2.4GHz, Bluetooth 4.2 BLE',
        fungsiUtama: 'Membaca telemetri sensor, eksekusi otomasi lokal, dan transmisi data ke HP.',
        nilaiIdeal: 'Transmisi tiap 5 menit (Protokol HTTP/MQTT)',
      ),
    ];
  }
}
