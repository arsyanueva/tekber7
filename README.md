# Field Master - Kelompok 7 (Teknologi Berkembang C)

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

**Field Master** adalah aplikasi mobile berbasis Flutter yang memudahkan pengguna untuk mencari, melihat detail, dan menyewa lapangan olahraga (seperti Lapangan Futsal, Badminton) secara online. Aplikasi ini terintegrasi dengan **Supabase** sebagai backend untuk autentikasi pengguna, manajemen database, dan penyimpanan data.

---

## 📱 Unduh Aplikasi (APK)

Jika Anda hanya ingin mencoba aplikasi tanpa menjalankan *source code*, Anda dapat mengunduh file APK versi terbaru melalui halaman **Releases**.

### Cara Instalasi di Android:
1. Masuk ke halaman **[Releases](../../releases)** di repository ini.
2. Pilih versi terbaru (`v1.1`).
3. Klik pada **Assets** dan unduh file bernama `Field-Master.apk`.
4. Pindahkan file tersebut ke HP Android Anda (atau download langsung dari HP).
5. Buka file APK tersebut untuk memulai instalasi.
6. Jika muncul peringatan keamanan, pilih **Settings** dan aktifkan **"Allow from this source"** (Izinkan dari sumber ini).
7. Klik **Install** dan tunggu hingga selesai.

---

## ✨ Fitur Utama

Aplikasi ini memiliki dua peran pengguna (*role*) dengan fitur yang berbeda:

### 1. Sebagai Penyewa (Renter)
* **Autentikasi Pengguna:** Login dan Register aman menggunakan Email & Password.
* **Pencarian & Filter:** Cari lapangan berdasarkan nama, lokasi (Kota), dan urutkan berdasarkan harga termurah atau fasilitas terlengkap.
* **Detail Lapangan:** Melihat foto galeri, daftar fasilitas, harga per jam, dan rating lapangan.
* **Sistem Booking:** Memilih tanggal dan slot jam sewa secara *real-time*, serta simulasi pembayaran.
* **Manajemen Pesanan:** Melihat riwayat pemesanan (status Berlangsung & Riwayat Selesai).
* **Ulasan & Rating:** Memberikan ulasan dan bintang untuk lapangan yang telah selesai disewa.
* **Profil Pengguna:** Mengubah data diri, foto profil, dan password.

### 2. Sebagai Pemberi Sewa (Owner)
* **Autentikasi Pengguna:** Login dan Register khusus pemilik lapangan.
* **Manajemen Lapangan:** Menambahkan lapangan baru, mengunggah foto, menentukan harga, dan mendeskripsikan fasilitas.
* **Dashboard Owner:** Melihat daftar lapangan yang dikelola.
* **Manajemen Pesanan Masuk:** Melihat siapa saja yang menyewa lapangan milik owner.
* **Ulasan & Rating:** Membaca ulasan dari penyewa dan membalas ulasan tersebut (*Reply Review*).
* **Profil Pengguna:** Mengubah data diri dan password.

---

## 💻 Persyaratan Sistem (Untuk Developer)

Sebelum mengembangkan atau menjalankan *source code*, pastikan telah menginstal:

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi terbaru stable)
* Dart SDK
* VS Code atau Android Studio
* Emulator Android/iOS atau Perangkat Fisik
* Git

---

## 🛠️ Cara Instalasi (Source Code)

Ikuti langkah ini jika Anda ingin menjalankan proyek di lingkungan pengembangan (local machine):

1. **Clone Repository**
   Salin proyek ini ke komputer lokal:
   ```bash
   git clone [https://github.com/username-kamu/field_master.git](https://github.com/username-kamu/field_master.git)
   cd field_master

2. **Instal Dependensi**
Masuk ke folder proyek dan unduh semua library yang dibutuhkan:
```bash
flutter pub get

```


3. **Konfigurasi Supabase**
Aplikasi ini membutuhkan koneksi ke Supabase. Pastikan file `lib/main.dart` (atau file environment config Anda) sudah memiliki URL dan Anon Key yang benar.
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);

```


4. **Jalankan Aplikasi**
Pastikan emulator sudah berjalan atau HP terhubung via USB:
```bash
flutter run

```



---

## 📂 Struktur Folder

Berikut adalah gambaran struktur direktori proyek **Field Master**:

```text
lib/
├── config/                  # Konfigurasi aplikasi
│   ├── theme.dart           # Tema aplikasi (warna, font global)
│   └── constants.dart       # Konstanta (API Keys, padding default)
│
├── models/                  # Representasi data (Database Schema)
│   ├── booking_model.dart   # Model pemesanan
│   ├── field_model.dart     # Model lapangan
│   ├── review_model.dart    # Model ulasan/rating
│   └── user_model.dart      # Model pengguna
│
├── providers/               # State Management (Provider)
│   └── review_provider.dart # State untuk manajemen review
│
├── routes/                  # Navigasi
│   └── app_routes.dart      # Daftar nama rute dan map navigasi
│
├── screens/                 # Halaman-halaman UI (Views)
│   ├── auth/                # Fitur Autentikasi (Login/Register/OTP)
│   ├── booking/             # Fitur Pemesanan & Payment Gateway
│   ├── home/                # Fitur Utama (Beranda & Dashboard)
│   │   ├── add_field_screen.dart
│   │   ├── home_screen.dart
│   │   ├── home_owner_screen.dart
│   │   └── ...
│   ├── password/            # Fitur Ganti/Lupa Password
│   ├── review/              # Fitur Ulasan & Reply
│   ├── profile/             # Fitur Profil User
│   └── welcome/             # Layar Pembuka (Splash/Welcome)
│
├── services/                # Logika Bisnis & API (Supabase)
│   ├── auth_service.dart    # Auth logic
│   ├── booking_service.dart # Booking logic
│   └── review_service.dart  # Review logic
│
├── utils/                   # Fungsi bantuan (Helpers)
│   ├── app_colors.dart      # Palet warna
│   └── refund_helper.dart      
│
├── widgets/                 # Komponen UI Reusable
│   ├── field_card.dart      
│   ├── review_list_section.dart 
│   └── star_rating_display.dart     
│
└── main.dart                # Entry Point Aplikasi

```

---

## 👥 Anggota Kelompok

**Kelompok 7 - Teknologi Berkembang C**

| NRP | Nama |
| --- | --- |
| 5026231089 | Yusuf Acala S. S. K. |
| 5026231121 | Rian Chairul Ichsan |
| 5026231099 | Arsya Nueva D. |
| 5026231179 | M. Hammam A |
| 5026231229 | Lailatul Fitaliqoh |
| 5026231232 | Bara Ardiwinata |

---
