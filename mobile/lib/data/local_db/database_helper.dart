import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tanigreen.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Naik ke versi 2 agar tabel baru otomatis ter-create
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: (db) async {
        await _seedInitialVarietas(db);
        await _seedInitialJadwal(db);
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabel Pengguna (FR-01, FR-02, FR-13)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pengguna (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_terenkripsi TEXT NOT NULL,
        salt TEXT NOT NULL,
        foto_path TEXT,
        biometrik_aktif INTEGER NOT NULL DEFAULT 0,
        saldo_token INTEGER NOT NULL DEFAULT 0,
        dibuat_pada TEXT NOT NULL
      )
    ''');

    await _createRemainingTables(db);
    await _seedInitialVarietas(db);
    await _seedInitialJadwal(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createRemainingTables(db);
      await _seedInitialVarietas(db);
    }
  }

  /// Membuat 9 tabel sisanya sesuai Bagian 8 PRD (ERD) + sync_status (FR-03)
  Future<void> _createRemainingTables(Database db) async {
    // 2. Tabel Greenhouse (FR-03, FR-04, FR-06)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS greenhouse (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pengguna_id INTEGER NOT NULL,
        nama_greenhouse TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        alamat TEXT NOT NULL,
        luas REAL NOT NULL,
        biaya_operasional_idr REAL NOT NULL DEFAULT 0,
        batas_suhu_maks REAL NOT NULL DEFAULT 35.0,
        batas_lembap_min REAL NOT NULL DEFAULT 40.0,
        status TEXT NOT NULL DEFAULT 'Normal',
        sync_status TEXT NOT NULL DEFAULT 'Menunggu Unggah'
      )
    ''');

    // 3. Tabel Varietas (FR-03, FR-09)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS varietas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_varietas TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        panduan_perawatan TEXT NOT NULL,
        estimasi_umur INTEGER NOT NULL,
        foto_path TEXT,
        sync_status TEXT NOT NULL DEFAULT 'Menunggu Unggah'
      )
    ''');

    // 4. Tabel Tanaman (FR-03, FR-11)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tanaman (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        greenhouse_id INTEGER NOT NULL,
        varietas_id INTEGER NOT NULL,
        tanggal_tanam TEXT NOT NULL,
        jumlah INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'Sehat',
        tingkat_hama TEXT NOT NULL DEFAULT 'Aman',
        catatan TEXT,
        sync_status TEXT NOT NULL DEFAULT 'Menunggu Unggah'
      )
    ''');

    // 5. Tabel SensorLog (FR-03, FR-07, FR-08)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sensor_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        greenhouse_id INTEGER NOT NULL,
        suhu REAL NOT NULL,
        kelembapan_udara REAL NOT NULL,
        kelembapan_tanah REAL NOT NULL,
        cahaya REAL NOT NULL,
        waktu_utc TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'Menunggu Unggah'
      )
    ''');

    // 6. Tabel Jadwal Perawatan (FR-03, FR-07, FR-11, FR-12)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS jadwal_perawatan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanaman_id INTEGER NOT NULL,
        jenis_perawatan TEXT NOT NULL,
        waktu_utc TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Terjadwal',
        catatan TEXT,
        sync_status TEXT NOT NULL DEFAULT 'Menunggu Unggah'
      )
    ''');

    // 7. Tabel Notifikasi (FR-12)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifikasi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pengguna_id INTEGER NOT NULL,
        greenhouse_id INTEGER,
        pesan TEXT NOT NULL,
        dibaca INTEGER NOT NULL DEFAULT 0,
        waktu TEXT NOT NULL
      )
    ''');

    // 8. Tabel BlokLog / Blockchain Simulasi (FR-13)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS blok_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        log_id INTEGER NOT NULL,
        data_log TEXT NOT NULL,
        hash TEXT NOT NULL,
        hash_sebelumnya TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // 9. Tabel SkorGame (FR-10)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS skor_game (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pengguna_id INTEGER NOT NULL,
        skor INTEGER NOT NULL,
        waktu TEXT NOT NULL
      )
    ''');

    // 10. Tabel SaranKesan (FR-05)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS saran_kesan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pengguna_id INTEGER NOT NULL,
        saran TEXT NOT NULL,
        kesan TEXT NOT NULL,
        waktu TEXT NOT NULL
      )
    ''');
  }

  /// Data awal master varietas tanaman unggul (fokus melon dan hortikultura sesuai PRD)
  Future<void> _seedInitialVarietas(Database db) async {
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM varietas'),
      ) ?? 0;
      if (count == 0) {
        final initialData = [
          {
            'nama_varietas': 'Melon Golden Emerald',
            'deskripsi': 'Kulit kuning emas dengan daging renyah manis hingga tingkat brix 14%.',
            'panduan_perawatan': 'pH optimal 6.2 - 6.8, suhu 24 - 30°C. Berikan kalium tinggi saat fase pembesaran buah.',
            'estimasi_umur': 70,
            'foto_path': null,
            'sync_status': 'Tersinkron',
          },
          {
            'nama_varietas': 'Tomat Cherry Ruby',
            'deskripsi': 'Rasa manis segar dengan kandungan likopen tinggi, sangat tahan serangan jamur daun.',
            'panduan_perawatan': 'pH optimal 6.0 - 6.8, suhu 22 - 28°C. Berikan kalsium nitrat untuk cegah busuk pantat buah.',
            'estimasi_umur': 65,
            'foto_path': null,
            'sync_status': 'Tersinkron',
          },
          {
            'nama_varietas': 'Selada Romaine Hijau',
            'deskripsi': 'Tekstur renyah cocok untuk hidroponik sistem NFT & DFT dengan sirkulasi nutrisi stabil.',
            'panduan_perawatan': 'pH optimal 5.8 - 6.5, suhu 18 - 25°C. Jaga sirkulasi oksigen terlarut dalam tandon.',
            'estimasi_umur': 35,
            'foto_path': null,
            'sync_status': 'Tersinkron',
          },
          {
            'nama_varietas': 'Cabai Rawit Hibrida',
            'deskripsi': 'Tingkat kepedasan tinggi dan produktivitas lebat sepanjang tahun.',
            'panduan_perawatan': 'pH optimal 6.0 - 7.0, suhu 25 - 32°C. Pantau serangan kutu kebul dengan sticky trap.',
            'estimasi_umur': 80,
            'foto_path': null,
            'sync_status': 'Tersinkron',
          },
        ];

        for (var item in initialData) {
          await db.insert('varietas', item);
        }
      }
    } catch (_) {}
  }


  /// Data awal master jadwal perawatan
  Future<void> _seedInitialJadwal(Database db) async {
    try {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM jadwal_perawatan'),
      ) ?? 0;
      if (count == 0) {
        final now = DateTime.now();
        final initialSchedules = [
          {
            'tanaman_id': 1,
            'jenis_perawatan': 'Pemupukan NPK Cair AB Mix',
            'waktu_utc': now.add(const Duration(hours: 2)).toUtc().toIso8601String(),
            'status': 'Prioritas',
            'catatan': 'Greenhouse A • Tomat Hidroponik',
            'sync_status': 'Tersinkron',
          },
          {
            'tanaman_id': 2,
            'jenis_perawatan': 'Pengecekan pH & EC Tandon Nutrisi',
            'waktu_utc': now.add(const Duration(hours: 6)).toUtc().toIso8601String(),
            'status': 'Terjadwal',
            'catatan': 'Greenhouse B • Selada Romaine',
            'sync_status': 'Tersinkron',
          },
          {
            'tanaman_id': 1,
            'jenis_perawatan': 'Pemangkasan Tunas Air (Pruning)',
            'waktu_utc': now.add(const Duration(days: 1)).toUtc().toIso8601String(),
            'status': 'Mendatang',
            'catatan': 'Greenhouse A • Melon Golden',
            'sync_status': 'Tersinkron',
          },
          {
            'tanaman_id': 3,
            'jenis_perawatan': 'Panen Raya Perdana Batch #2',
            'waktu_utc': now.add(const Duration(days: 3)).toUtc().toIso8601String(),
            'status': 'Panen',
            'catatan': 'Greenhouse C • Cabai Rawit',
            'sync_status': 'Tersinkron',
          },
        ];

        for (var item in initialSchedules) {
          await db.insert('jadwal_perawatan', item);
        }
      }
    } catch (_) {}
  }

  // ===========================================================================
  // 1. BAGIAN PENGGUNA (FR-01, FR-02, FR-05, FR-13)
  // ===========================================================================
  Future<int> insertUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('pengguna', user.toMap());
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'pengguna',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await instance.database;
    final maps = await db.query('pengguna', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  Future<int> updateBiometricStatus(int userId, bool isActive) async {
    final db = await instance.database;
    return await db.update(
      'pengguna',
      {'biometrik_aktif': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> updateUserPhoto(int userId, String fotoPath) async {
    final db = await instance.database;
    return await db.update(
      'pengguna',
      {'foto_path': fotoPath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> addRewardToken(int userId, int additionalTokens) async {
    final db = await instance.database;
    final user = await getUserById(userId);
    if (user == null) return 0;
    final newBalance = user.saldoToken + additionalTokens;
    return await db.update(
      'pengguna',
      {'saldo_token': newBalance},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // ===========================================================================
  // 2. BAGIAN GREENHOUSE (FR-03, FR-04, FR-06, FR-11)
  // ===========================================================================
  Future<int> insertGreenhouse(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('greenhouse', row);
  }

  Future<List<Map<String, dynamic>>> getGreenhousesByUser(int userId) async {
    final db = await instance.database;
    return await db.query(
      'greenhouse',
      where: 'pengguna_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  Future<int> updateGreenhouse(int id, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update('greenhouse', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteGreenhouse(int id) async {
    final db = await instance.database;
    return await db.delete('greenhouse', where: 'id = ?', whereArgs: [id]);
  }

  // ===========================================================================
  // 3. BAGIAN VARIETAS & TANAMAN (FR-03, FR-09, FR-11)
  // ===========================================================================
  Future<int> insertVarietas(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('varietas', row);
  }

  Future<List<Map<String, dynamic>>> getAllVarietas() async {
    final db = await instance.database;
    return await db.query('varietas', orderBy: 'id DESC');
  }

  Future<int> insertTanaman(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('tanaman', row);
  }

  Future<List<Map<String, dynamic>>> getTanamanByGreenhouse(int ghId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT t.*, v.nama_varietas, v.estimasi_umur, g.nama_greenhouse 
      FROM tanaman t
      LEFT JOIN varietas v ON t.varietas_id = v.id
      LEFT JOIN greenhouse g ON t.greenhouse_id = g.id
      WHERE t.greenhouse_id = ?
      ORDER BY t.id DESC
    ''', [ghId]);
  }

  Future<List<Map<String, dynamic>>> getAllTanamanWithDetails(int userId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT t.*, v.nama_varietas, g.nama_greenhouse, g.alamat
      FROM tanaman t
      INNER JOIN greenhouse g ON t.greenhouse_id = g.id
      LEFT JOIN varietas v ON t.varietas_id = v.id
      WHERE g.pengguna_id = ?
      ORDER BY t.id DESC
    ''', [userId]);
  }

  /// FR-11: Pencarian komprehensif greenhouse dan tanaman yang dimiliki user
  Future<List<Map<String, dynamic>>> searchGreenhouseAndPlants(int userId, String query) async {
    final db = await instance.database;
    final cleanQuery = '%${query.trim().toLowerCase()}%';
    return await db.rawQuery('''
      SELECT g.id, g.nama_greenhouse AS judul, g.alamat AS subjudul, g.status, 'Greenhouse' AS kategori, 'Lahan' AS tag
      FROM greenhouse g
      WHERE g.pengguna_id = ? AND (LOWER(g.nama_greenhouse) LIKE ? OR LOWER(g.alamat) LIKE ?)
      UNION ALL
      SELECT t.id, v.nama_varietas AS judul, ('Di: ' || g.nama_greenhouse) AS subjudul, t.status, 'Tanaman' AS kategori, ('Hama: ' || t.tingkat_hama) AS tag
      FROM tanaman t
      INNER JOIN greenhouse g ON t.greenhouse_id = g.id
      LEFT JOIN varietas v ON t.varietas_id = v.id
      WHERE g.pengguna_id = ? AND (LOWER(v.nama_varietas) LIKE ? OR LOWER(t.status) LIKE ? OR LOWER(t.tingkat_hama) LIKE ?)
    ''', [userId, cleanQuery, cleanQuery, userId, cleanQuery, cleanQuery, cleanQuery]);
  }

  // ===========================================================================
  // 4. BAGIAN SENSOR LOG (FR-07, FR-08)
  // ===========================================================================
  Future<int> insertSensorLog(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('sensor_log', row);
  }

  Future<List<Map<String, dynamic>>> getSensorLogsByGreenhouse(int ghId) async {
    final db = await instance.database;
    return await db.query(
      'sensor_log',
      where: 'greenhouse_id = ?',
      whereArgs: [ghId],
      orderBy: 'id DESC',
      limit: 50,
    );
  }

  // ===========================================================================
  // 5. BAGIAN JADWAL PERAWATAN (FR-07, FR-11, FR-12)
  // ===========================================================================
  Future<int> insertJadwal(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('jadwal_perawatan', row);
  }

  Future<List<Map<String, dynamic>>> getJadwalByUser(int userId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT j.*, t.status AS status_tanaman, v.nama_varietas, g.nama_greenhouse, g.id AS greenhouse_id
      FROM jadwal_perawatan j
      INNER JOIN tanaman t ON j.tanaman_id = t.id
      INNER JOIN greenhouse g ON t.greenhouse_id = g.id
      LEFT JOIN varietas v ON t.varietas_id = v.id
      WHERE g.pengguna_id = ?
      ORDER BY j.waktu_utc ASC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getAllJadwalList() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT j.*, 
             COALESCE(g.nama_greenhouse, 'Greenhouse A') AS nama_greenhouse,
             COALESCE(v.nama_varietas, 'Melon Golden') AS nama_varietas
      FROM jadwal_perawatan j
      LEFT JOIN tanaman t ON j.tanaman_id = t.id
      LEFT JOIN greenhouse g ON t.greenhouse_id = g.id
      LEFT JOIN varietas v ON t.varietas_id = v.id
      ORDER BY j.waktu_utc ASC
    ''');
  }

  Future<int> deleteJadwal(int id) async {
    final db = await instance.database;
    return await db.delete('jadwal_perawatan', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateJadwalStatus(int id, String status) async {
    final db = await instance.database;
    return await db.update(
      'jadwal_perawatan',
      {'status': status, 'sync_status': 'Menunggu Unggah'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===========================================================================
  // 6. BAGIAN NOTIFIKASI (FR-12)
  // ===========================================================================
  Future<int> insertNotifikasi(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('notifikasi', row);
  }

  Future<List<Map<String, dynamic>>> getNotifikasiByUser(int userId) async {
    final db = await instance.database;
    return await db.query(
      'notifikasi',
      where: 'pengguna_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  Future<int> markNotifikasiAsRead(int id) async {
    final db = await instance.database;
    return await db.update(
      'notifikasi',
      {'dibaca': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===========================================================================
  // 7. BAGIAN BLOCKCHAIN HASH CHAIN (FR-13)
  // ===========================================================================
  Future<Map<String, dynamic>?> getLastBlokLog() async {
    final db = await instance.database;
    final res = await db.query('blok_log', orderBy: 'id DESC', limit: 1);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<int> insertBlokLog(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('blok_log', row);
  }

  Future<List<Map<String, dynamic>>> getAllBlokLogs() async {
    final db = await instance.database;
    return await db.query('blok_log', orderBy: 'id ASC');
  }

  // ===========================================================================
  // 8. BAGIAN MINI GAME SKOR (FR-10)
  // ===========================================================================
  Future<int> insertSkorGame(int userId, int skor) async {
    final db = await instance.database;
    return await db.insert('skor_game', {
      'pengguna_id': userId,
      'skor': skor,
      'waktu': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<int> getHighScore(int userId) async {
    final db = await instance.database;
    final res = await db.rawQuery(
      'SELECT MAX(skor) as max_skor FROM skor_game WHERE pengguna_id = ?',
      [userId],
    );
    if (res.isNotEmpty && res.first['max_skor'] != null) {
      return res.first['max_skor'] as int;
    }
    return 0;
  }

  // ===========================================================================
  // 9. BAGIAN SARAN & KESAN PAM (FR-05)
  // ===========================================================================
  Future<int> insertSaranKesan(int userId, String saran, String kesan) async {
    final db = await instance.database;
    return await db.insert('saran_kesan', {
      'pengguna_id': userId,
      'saran': saran,
      'kesan': kesan,
      'waktu': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSaranKesanByUser(int userId) async {
    final db = await instance.database;
    return await db.query(
      'saran_kesan',
      where: 'pengguna_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  // ===========================================================================
  // 10. SINKRONISASI OFFLINE KE ONLINE / SUPABASE (FR-03)
  // ===========================================================================
  Future<void> markAllSynced(String tableName) async {
    final db = await instance.database;
    await db.update(
      tableName,
      {'sync_status': 'Tersinkron'},
      where: 'sync_status = ?',
      whereArgs: ['Menunggu Unggah'],
    );
  }
}
