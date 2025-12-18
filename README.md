# tekber7
**Kelompok 7 - Teknologi Berkembang C**

# Field Master

**Field Master** adalah aplikasi mobile berbasis Flutter yang memudahkan pengguna untuk mencari, melihat detail, dan menyewa lapangan olahraga (seperti Lapangan Futsal, Badminton) secara online. Aplikasi ini terintegrasi dengan **Supabase** sebagai backend untuk autentikasi pengguna, manajemen database, dan penyimpanan data.

## Fitur Utama
Field Master juga memiliki beberapa fitur utama, yaitu:

**1. Sebagai Penyewa**
* **Autentikasi Pengguna:** Login dan Register menggunakan Email & Password.
* **Pencarian & Filter:** Cari lapangan berdasarkan nama, lokasi (Kota), dan urutkan berdasarkan harga atau fasilitas.
* **Detail Lapangan:** Melihat foto, fasilitas, harga, dan rating lapangan.
* **Sistem Booking:** Memilih tanggal dan jam sewa, serta simulasi pembayaran.
* **Manajemen Pesanan:** Melihat riwayat pemesanan (Berlangsung & Riwayat).
* **Ulasan & Rating:** Memberikan ulasan dan rating untuk lapangan yang telah selesai disewa.
* **Profil Pengguna:** Mengubah data diri dan password.

**2. Sebagai Pemberi Sewa**
* **Autentikasi Pengguna:** Login dan Register menggunakan Email & Password.
* **Menambahkan Lapanagn:** Menambahkan lapangan yang available untuk disewa, dan mengisi deskripsi lapangan termasuk harga sewa, dsb.
* **Detail Lapangan:** Melihat foto, fasilitas, harga, dan rating lapangan.
* **Manajemen Pesanan:** Melihat riwayat pemesanan yang dilakukan oleh penyewa.
* **Ulasan & Rating:** Melihat ulasan dan rating untuk lapangan yang telah selesai disewa.
* **Profil Pengguna:** Mengubah data diri dan password.
---

## Persyaratan Sistem

Sebelum memulai, pastikan telah menginstal:

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi terbaru stable)
* Dart SDK
* VS Code atau Android Studio
* Emulator Android/iOS atau Perangkat Fisik

---

## Cara Instalasi

1.  **Clone Repository**
    Salin proyek ini ke komputer lokal:
    ```bash
    git clone [https://github.com/username-kamu/field_master.git](https://github.com/username-kamu/field_master.git)
    cd field_master
    ```
2.  **Instal Dependensi**
    Masuk ke folder proyek dan unduh semua library yang dibutuhkan:
    ```bash
    flutter pub get
    ```
3.  **Konfigurasi Supabase**
    Pastikan file `lib/main.dart` sudah memiliki URL dan Anon Key Supabase yang benar.
    ```dart
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
    ```
---

## Cara Menjalankan

1.  **Buka Emulator** atau sambungkan perangkat fisik via USB.
2.  Pastikan perangkat terdeteksi:
    ```bash
    flutter devices
    ```
3.  **Jalankan Aplikasi:**
    ```bash
    flutter run
    ```
    *(Gunakan `flutter run -v` jika ingin melihat log verbose untuk debugging)*

---

## 📂 Struktur Folder

Berikut adalah gambaran struktur direktori proyek **Field Master**:

```text
lib/
├── config/                  # Konfigurasi aplikasi
│   ├── theme.dart           # Tema aplikasi (warna, font global)
│   └── constants.dart       # Konstanta (misal: API Keys, ukuran padding default)
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
│   ├── auth/                # Fitur Autentikasi
│   │   ├── login_email_screen.dart
│   │   ├── login_method_screen.dart
│   │   ├── register_email_screen.dart
│   │   ├── role_selection_screen.dart
│   │   └── verify_otp_screen.dart
│   │
│   ├── booking/             # Fitur Pemesanan
│   │   ├── booking_cancel_success_screen.dart
│   │   ├── booking_detail_screen.dart
│   │   ├── booking_history_screen.dart
│   │   ├── booking_summary_screen.dart
│   │   ├── cancel_booking_screen.dart
│   │   ├── confirm_cancel_screen.dart
│   │   ├── confirm_reschedule_screen.dart
│   │   ├── payment_gateway_screen.dart
│   │   ├── payment_success_screen.dart
│   │   ├── reschedule_booking_screen.dart
│   │   └── reschedule_success_screen.dart
│   │
│   ├── home/                # Fitur Utama (Beranda & Pencarian)
│   │   ├── add_field_screenhome_screen.dart
│   │   ├── all_fields_screen.dart
│   │   ├── change_profile_screen.dart
│   │   ├── field_detail_screen.dart
│   │   ├── home_owner_screen.dart
│   │   ├── home_screen.dart
│   │   └── profile_screen.dart
│   │
│   ├── password/               
│   │   ├── change_password_screen.dart
│   │   └── forget_password_screen.dart
│   │
│   ├── review/              # Fitur Ulasan
│   │   ├── reply_review_screen.dart
│   │   └── review_form_screen.dart
│   │
│   ├── profile/             # Fitur Profil User
│   │   ├── profile_screen.dart
│   │   └── edit_profile_screen.dart
│   │
│   └── welcome/             # Layar Pembuka
│   │  └── welcome_screen.dart
│   │
│   └── temp_loading_screen.dart
│   
├── services/                # Logika Bisnis & API (Supabase)
│   ├── auth_service.dart    # Login, Register, Logout ke Supabase
│   ├── booking_service.dart # Insert/Update booking
│   └── review_service.dart  # Submit & Fetch review
│
├── utils/                   # Fungsi bantuan (Helpers)
│   ├── app_colors.dart      # Palet warna (Hex codes)
│   └── refund_helper.dart      
│
├── widgets/                 # Komponen UI yang bisa dipakai ulang (Global)
│   ├── field_card.dart      # Kartu tampilan lapangan
│   ├── review_list_section.dart 
│   └── star_rating_display.dart     # Ikon bintang rating
│
└── main.dart                # Titik masuk aplikasi (Entry Point)

```
Anggota Kelompok:
1. Yusuf Acala S. S. K. - 5026231089
2. Rian Chairul Ichsan - 5026231121
3. Arsya Nueva D. - 5026231099
4. M. Hammam A - 5026231179
5. Lailatul Fitaliqoh - 5026231229
6. Bara Ardiwinata - 5026231232
