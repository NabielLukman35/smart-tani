# Smart Tani (TaniGreen) 🌿
> **Aplikasi Mobile Pertanian Cerdas, Manajemen Smart Greenhouse & Riset Agronomi**  
> *Mata Kuliah Pemrograman Aplikasi Mobile (PAM)*

Smart Tani (TaniGreen) adalah platform terpadu bagi petani muda dan peneliti budidaya tanaman untuk mengelola lingkungan greenhouse, telemetri sensor IoT, pencatatan rantai suplai berbasis simulasi blockchain, asisten konsultasi AI, serta edukasi gamifikasi pertanian.

---

## 🚀 Fitur Utama & Kesesuaian PRD

Aplikasi ini dibangun untuk memenuhi seluruh Kebutuhan Fungsional (*Functional Requirements*) pada PRD:

| ID | Fitur Utama | Deskripsi Implementasi Teknis |
|:---:|:---|:---|
| **FR-01** | **Autentikasi & Sesi** | Registrasi & Login dengan **algoritma enkripsi custom** (Salt + XOR Shift + Permutasi Blok) tanpa Firebase. Sesi pengguna dikelola via `SharedPreferences`. |
| **FR-02** | **Biometrik** | Login instan menggunakan sensor sidik jari (*fingerprint*) atau Face ID via package `local_auth` dengan fallback kata sandi. |
| **FR-03** | **Database Lokal & Sinkronisasi** | Arsitektur *offline-first* menggunakan **SQLite** (`sqflite`) dengan 10 tabel relasional lengkap dan status `sync_status = 'Menunggu Unggah'` yang siap disinkronkan ke Backend REST API. |
| **FR-04** | **Peta OSM & GPS (LBS)** | Pemetaan titik koordinat greenhouse berbasis OpenStreetMap (`flutter_map` + `geolocator`) dan *Reverse Geocoding* Nominatim OSM dengan header `User-Agent`. |
| **FR-05** | **Navigasi 3 Menu** | Bottom Navigation Bar konsisten dengan 3 menu: **Beranda (Dashboard)**, **Profil Akun**, dan **Saran & Kesan PAM**. |
| **FR-06** | **Konversi Mata Uang** | Konversi estimasi biaya operasional greenhouse dari IDR ke **USD, EUR, GBP** menggunakan Frankfurter API dengan *local caching* offline. |
| **FR-07** | **Konversi Waktu 4 Zona** | Penyimpanan waktu log berbasis UTC dan konversi offline ke zona waktu **WIB (UTC+7)**, **WITA (UTC+8)**, **WIT (UTC+9)**, dan **London** via package `timezone`. |
| **FR-08** | **Monitoring Sensor IoT** | Pemantauan multi-sensor (DHT22 suhu udara, kelembapan udara & tanah, serta LDR intensitas cahaya) dengan konfigurasi ambang batas otomatis dan pemicu peringatan. |
| **FR-09** | **Asisten AI & LLM** | Konsultasi agronomi, diagnosa penyakit, dan rekomendasi nutrisi cerdas terintegrasi Google Gemini AI Studio API. |
| **FR-10** | **Edukasi Game & Gamifikasi** | Kuis agronomi interaktif untuk menguji pemahaman budidaya, pencatatan rekor skor di SQLite, dan sistem reward *Token Petani*. |
| **FR-11** | **Pencarian & Filter** | Pencarian multi-kategori untuk greenhouse, komoditas varietas, tingkat serangan hama, dan basis pengetahuan agronomi. |
| **FR-12** | **Notifikasi Lokal** | Peringatan instan pada antarmuka saat sensor melewati batas kritis atau jadwal perawatan tiba (tanpa Firebase Cloud Messaging). |
| **FR-13** | **Simulasi Blockchain** | Keterlacakan riwayat perawatan (*supply chain traceability*) dengan audit rantai blok **SHA-256** (`hash = SHA-256(data + prev_hash + timestamp)`) yang *immutable*. |

---

## 📁 Struktur Direktori

```text
smart-tani/
├── backend/                        # REST API Server (Node.js / Express)
│   ├── src/
│   │   ├── controllers/            # Controller Auth, Greenhouse & Sync
│   │   ├── middlewares/            # JWT Auth & Error Handling
│   │   ├── routes/                 # Endpoint Routing
│   │   ├── services/               # AI Service (Gemini) & Blockchain Hash
│   │   └── utils/                  # Enkripsi Kustom & JWT Helper
│   ├── .env.example
│   ├── package.json
│   └── server.js
├── docs/
│   └── API.md                      # Dokumentasi Endpoint Lengkap
├── mobile/                         # Aplikasi Mobile (Flutter 3.x)
│   ├── assets/
│   │   ├── .env                    # Konfigurasi Lokal
│   │   └── .env.example
│   ├── lib/
│   │   ├── core/                   # Tema (Dark Lime), Helper Timezone, Valuta, Enkripsi
│   │   ├── data/                   # SQLite Database Helper & Model Entitas
│   │   ├── presentation/           # Antarmuka Halaman & Provider State Management
│   │   └── main.dart
│   ├── test/                       # Unit & Widget Test
│   └── pubspec.yaml
└── README.md
```

---

## 🛠️ Panduan Menjalankan Aplikasi

### 1. Prasyarat Lingkungan
* **Flutter SDK**: 3.5.0 atau lebih tinggi
* **Dart SDK**: 3.5.0 atau lebih tinggi
* **Android Studio / VS Code / Antigravity IDE** dengan Android Emulator
* *(Opsional untuk Backend)*: **Node.js** v18+ dan **npm**

---

### 2. Menjalankan Aplikasi Mobile (Flutter)

1. Masuk ke direktori `mobile`:
   ```powershell
   cd mobile
   ```

2. Ambil dependensi pub:
   ```powershell
   flutter pub get
   ```

3. Jalankan pengujian dan analisis kode:
   ```powershell
   flutter analyze
   flutter test
   ```

4. Jalankan pada Android Emulator:
   ```powershell
   flutter devices
   flutter run -d <DEVICE_ID>
   ```

---

### 3. Menjalankan Backend REST API (Opsional)

1. Masuk ke direktori `backend`:
   ```powershell
   cd backend
   ```

2. Pasang dependensi Node.js:
   ```powershell
   npm install
   ```

3. Jalankan server:
   ```powershell
   npm run dev
   # atau
   npm start
   ```
   Server akan aktif di `http://localhost:3000` (atau `http://10.0.2.2:3000` dari Android Emulator).

---

## 🔒 Konfigurasi Environment (`.env`)

Template file `.env.example` telah disediakan pada folder `mobile/assets/` dan `backend/`.
* Untuk mengaktifkan Gemini AI secara riil, masukkan API Key dari [Google AI Studio](https://aistudio.google.com/) ke baris:
  ```env
  GEMINI_API_KEY=AIzaSy...
  ```
* Jika API Key dibiarkan kosong, asisten AI secara otomatis beralih ke *Smart Rule-Based Agronomy Engine* bawaan sehingga fitur tetap dapat didemonstrasikan dengan lancar.

---

## 👥 Tim Pengembang
* Mata Kuliah: **Pemrograman Aplikasi Mobile**
* Repositori: [https://github.com/NabielLukman35/smart-tani](https://github.com/NabielLukman35/smart-tani)
