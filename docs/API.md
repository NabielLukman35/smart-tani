# Dokumentasi REST API — Smart Tani (TaniGreen)

Dokumentasi ini menjelaskan spesifikasi antarmuka pemrograman aplikasi (API) untuk server backend **Smart Tani**, dirancang untuk pemenuhan kebutuhan fungsional (FR) pada PRD Mata Kuliah Pemrograman Aplikasi Mobile.

---

## 1. Konfigurasi Dasar & Base URL

* **Development (Lokal Windows/Web)**: `http://localhost:3000/api`
* **Android Emulator**: `http://10.0.2.2:3000/api`
* **Format Data**: JSON (`application/json`)
* **Autentikasi**: Bearer Token JWT pada Header `Authorization: Bearer <TOKEN>`

---

## 2. Ringkasan Endpoint

| No | Kategori | Metode | Endpoint | Deskripsi | FR Terkait |
|:---|:---|:---:|:---|:---|:---:|
| 1 | Server | `GET` | `/` | Health check status server | - |
| 2 | Auth | `POST` | `/api/auth/register` | Pendaftaran akun baru (Enkripsi Custom) | FR-01 |
| 3 | Auth | `POST` | `/api/auth/login` | Masuk akun & penerbitan token JWT | FR-01 |
| 4 | Auth | `GET` | `/api/auth/me` | Profil pengguna terotentikasi | FR-01, FR-05 |
| 5 | Sync | `POST` | `/api/sync` | Sinkronisasi batch offline ke online | FR-03 |
| 6 | Greenhouse | `GET` | `/api/greenhouses` | Daftar greenhouse tersinkron | FR-03, FR-04 |
| 7 | AI / LLM | `POST` | `/api/ai/ask` | Konsultasi agronomi cerdas (Gemini API) | FR-09 |
| 8 | Blockchain | `POST` | `/api/blockchain/verify` | Verifikasi integritas rantai log SHA-256 | FR-13 |

---

## 3. Detail Spesifikasi Endpoint

### 3.1. Autentikasi Pengguna (FR-01)

#### `POST /api/auth/register`
Mendaftarkan akun petani baru dengan algoritma enkripsi password custom (Salt + XOR Shift + Permutasi Blok).

* **Request Body:**
```json
{
  "nama": "Budi Santoso",
  "email": "budi@tanigreen.id",
  "password": "PasswordRahasia123"
}
```
* **Response (201 Created):**
```json
{
  "status": "success",
  "message": "Registrasi berhasil.",
  "data": {
    "id": 1,
    "nama": "Budi Santoso",
    "email": "budi@tanigreen.id",
    "saldoToken": 10,
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

#### `POST /api/auth/login`
Verifikasi kredensial pengguna dan menerbitkan JWT token.

* **Request Body:**
```json
{
  "email": "budi@tanigreen.id",
  "password": "PasswordRahasia123"
}
```
* **Response (200 OK):**
```json
{
  "status": "success",
  "message": "Login berhasil.",
  "data": {
    "id": 1,
    "nama": "Budi Santoso",
    "email": "budi@tanigreen.id",
    "saldoToken": 10,
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

### 3.2. Sinkronisasi Data Offline-to-Online (FR-03)

#### `POST /api/sync`
Mengunggah semua entitas data yang dibuat atau diperbarui saat offline (`sync_status == 'Menunggu Unggah'`).

* **Request Body:**
```json
{
  "userId": 1,
  "greenhouses": [
    {
      "id": 1,
      "nama_greenhouse": "Greenhouse Melon A1",
      "latitude": -7.7828,
      "longitude": 110.3670,
      "alamat": "Sleman, D.I. Yogyakarta",
      "luas": 250.0,
      "biaya_operasional_idr": 1500000
    }
  ],
  "sensorLogs": [
    {
      "greenhouse_id": 1,
      "suhu": 28.5,
      "kelembapan_udara": 68.0,
      "kelembapan_tanah": 55.0,
      "cahaya": 650.0,
      "waktu_utc": "2026-10-21T04:30:00Z"
    }
  ],
  "blocks": [
    {
      "log_id": 1,
      "data_log": "Pemupukan NPK melon buah",
      "hash": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "hash_sebelumnya": "GENESIS_BLOCK_000000",
      "timestamp": "2026-10-21T04:30:00Z"
    }
  ]
}
```
* **Response (200 OK):**
```json
{
  "status": "success",
  "message": "Seluruh data offline berhasil disinkronkan ke server pusat.",
  "summary": {
    "greenhousesSynced": 1,
    "sensorLogsSynced": 1,
    "schedulesSynced": 0,
    "blocksSynced": 1
  },
  "timestamp": "2026-10-21T04:30:05.123Z"
}
```

---

### 3.3. Asisten AI & Konsultasi Agronomi (FR-09)

#### `POST /api/ai/ask`
Mengirim prompt/pertanyaan agronomi ke Google Gemini LLM API (atau fallback smart rule-based engine).

* **Request Body:**
```json
{
  "prompt": "Berapa pH ideal untuk hidroponik tanaman melon?"
}
```
* **Response (200 OK):**
```json
{
  "status": "success",
  "reply": "Untuk tanaman hortikultura & greenhouse, rentang pH ideal larutan nutrisi adalah 5.8 - 6.5. Tanaman melon membutuhkan suhu optimal 24 - 30°C...",
  "timestamp": "2026-10-21T04:30:10.000Z"
}
```

---

### 3.4. Verifikasi Audit Blockchain (FR-13)

#### `POST /api/blockchain/verify`
Memvalidasi rantai hash SHA-256 (`hash = SHA-256(data_log + hash_sebelumnya + timestamp)`).

* **Request Body:**
```json
{
  "blocks": [
    {
      "id": 1,
      "data_log": "Log Panen Melon Golden",
      "hash": "4a53cee3b4f62e84...b981",
      "hash_sebelumnya": "GENESIS",
      "timestamp": "2026-10-21T00:00:00Z"
    }
  ]
}
```
* **Response (200 OK):**
```json
{
  "status": "success",
  "valid": true,
  "message": "Seluruh blok blockchain terverifikasi valid dan immutable",
  "totalBlocks": 1
}
```
