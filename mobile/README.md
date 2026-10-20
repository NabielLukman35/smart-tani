# TaniGreen Mobile

## Menjalankan di Android Emulator

1. Pastikan Flutter, Android Studio, Android SDK, dan Android Emulator sudah terpasang.
2. Buka Android Studio, lalu di **Device Manager** jalankan sebuah virtual device.
3. Dari PowerShell, masuk ke folder `mobile` dan jalankan:

   ```powershell
   cd "C:\path\ke\smart tani\mobile"
   flutter pub get
   flutter devices
   flutter run -d emulator-5554
   ```

   Ganti `emulator-5554` dengan ID Android yang ditampilkan oleh `flutter devices`.
   Jika tidak ada Android device, pastikan emulator sudah selesai booting dan statusnya
   bukan `offline`.

Untuk membuat APK debug tanpa menjalankan emulator:

```powershell
flutter build apk --debug
```

APK dibuat di `build\app\outputs\flutter-apk\app-debug.apk`.
