# tekber7
**Kelompok 7 - Teknologi Berkembang C**
A new Flutter project.

    Deskripsi proyek
    Cara instalasi
    Cara menjalankan
    Struktur folder
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

## 🚀 Cara Menjalankan

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



Anggota Kelompok:
1. Yusuf Acala S. S. K. - 5026231089
2. Rian Chairul Ichsan - 5026231121
3. Arsya Nueva D. - 5026231099
4. M. Hammam A - 5026231179
5. Lailatul Fitaliqoh - 5026231229
6. Bara Ardiwinata - 5026231232
