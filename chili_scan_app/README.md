# 🌶️ Chili Scan App

Aplikasi Flutter untuk membantu petani dan pelaku agribisnis menilai kematangan cabai secara cepat melalui pemindaian kamera atau galeri. UI dibuat modern dengan dukungan Riverpod untuk state management, `go_router` untuk navigasi deklaratif, dan `dio` untuk komunikasi API.

## ✨ Fitur Utama

- **Scan Cepat** – Mulai pemindaian cabai langsung dari kamera atau pilih foto dari galeri.
- **Dashboard Interaktif** – Kartu hero, statistik ringkas, dan CTA utama untuk memantau aktivitas terbaru.
- **Riwayat Scan** – Daftar histori dengan status warna, deskripsi, dan waktu pembaruan agar keputusan panen lebih akurat.
- **Desain Responsif** – Layout adaptif dengan tema warna konsisten (`primaryColor`, `backgroundColor`).
- **Arsitektur Modular** – Pemisahan jelas antara halaman, widget, layanan API, dan konstanta.

## 🧱 Struktur Proyek

```
lib/
├─ common/
│  ├─ constants/      # warna, teks, tema
│  ├─ exceptions/     # custom exception untuk API/service
│  └─ utils/          # helper umum
├─ pages/             # layar: home, scanner, auth, history, dsb
├─ providers/         # Riverpod providers (state, controller)
├─ services/          # api_client.dart, api_service.dart
└─ widgets/           # widget reusable (form input, dsb)
```

## 🚀 Menjalankan Aplikasi

1. Pastikan Flutter SDK ≥ 3.10 terpasang dan `flutter doctor` bersih.
2. Pasang dependency:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi pada emulator atau perangkat fisik:
   ```bash
   flutter run
   ```

## 🧪 Testing

Jalankan widget/unit test bawaan:

```bash
flutter test
```

## 🔧 Teknologi Kunci

- Flutter & Dart 3
- Riverpod 3 (`flutter_riverpod`, `riverpod_lint`)
- `go_router` untuk routing
- `dio` untuk networking
- Google Fonts & Material 3 widgets
