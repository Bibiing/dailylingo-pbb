# DailyLingo (English Audio Diary)

## 1. Deskripsi Eksekutif

**DailyLingo** adalah aplikasi jurnal harian (_diary_) berbasis _mobile_ yang dirancang untuk melatih kemampuan menulis (_writing_) dan kelancaran berbicara (_speaking fluency_) dalam bahasa Inggris. Pengguna mencatat aktivitas harian mereka dalam bahasa Inggris, lalu merekam suara mereka saat membacakan catatan tersebut dengan bantuan fitur _Teleprompter Auto-Scroll_. Aplikasi ini mengevaluasi pelafalan sekaligus melatih pengguna untuk berbicara dengan kecepatan yang konstan (_Words Per Minute_).

## 2. Arsitektur & Pemetaan Fitur

### A. Autentikasi Pengguna

- **Fitur:** Layar _Login_ dan _Register_ terpusat.
- **Mekanisme:** Menggunakan Email/Password via Firebase Authentication.
- **Fungsi:** Mengamankan privasi pengguna agar data hanya dapat diakses oleh akun yang bersangkutan, serta menjadi fondasi untuk menyimpan _file_ audio di _cloud_.

### B. Manajemen CRUD Relational DB

- **Fitur:** Sistem pencatatan buku harian.
- **Mekanisme:** Menggunakan database relasional lokal (SQLite) melalui _package_ seperti `sqflite`.
- **Struktur Tabel `diary_logs`:**
  - `id` (Primary Key, Integer)
  - `date` (Timestamp)
  - `title` (Text)
  - `content` (Text - Teks jurnal bahasa Inggris)
  - `local_audio_path` (Text - Path lokasi file audio di memori internal HP)
- **Operasi CRUD:**
  - _Create:_ Membuat entri jurnal baru beserta referensi file audio.
  - _Read:_ Menampilkan daftar berdasarkan tanggal (berupa _List View_).
  - _Update:_ Mengedit teks jika ada kesalahan penulisan (_grammar_).
  - _Delete:_ Menghapus entri teks beserta file rekaman lokalnya.

### C. Perekaman Suara & Teleprompter

- **Fitur:** Perekam suara internal (_built-in_) yang dilengkapi dengan _Teleprompter Auto-Scroll_ untuk latihan kelancaran membaca.
- **Mekanisme Perekaman:** Memanfaatkan **Microphone** via _package_ `record`. Output file audio `.mp3` disimpan murni **secara lokal di penyimpanan internal _smartphone_** menggunakan `path_provider`.
- **Mekanisme Teleprompter:** * Pengguna mengatur target kecepatan berbicara menggunakan *Slider* berformat **WPM** (*Words Per Minute\*), misalnya dari 100 WPM hingga 200 WPM.
  - Menggunakan `ScrollController.animateTo()`, aplikasi akan menggulirkan teks ke atas secara otomatis dengan durasi kalkulasi matematis (`Total Kata / Kecepatan WPM`). Jika pengguna membaca terlalu lambat, teks akan tertinggal.

### D. Penyimpanan Awan

- **Fitur:** Pencadangan data teks (_Cloud Text Sync_).
- **Mekanisme:** Menggunakan **Cloud Firestore** (NoSQL Database).
- **Logika:** Setiap kali pengguna menyimpan entri di SQLite, aplikasi akan mengirimkan salinan data teks (`title`, `content`, `date`) ke koleksi Firestore di bawah dokumen spesifik milik _User ID_ tersebut. File audio **tidak** diunggah, melainkan tetap di HP.

### E. Pengingat Harian (Notifications)

- **Fitur:** Sistem _push-notification_ lokal terjadwal.
- **Mekanisme:** Menggunakan `flutter_local_notifications`. Diatur agar muncul setiap waktu yang disepakati pengguna.
- **Teks Notifikasi:** _"Time for your DailyLingo! What did you do today? Let's write and speak it out."_

---

## 3. Alur Kerja Aplikasi (User Flow) & Contoh Skenario

1.  **Sesi Akses:** Pengguna membuka aplikasi dan melakukan _login_ atau _register_ jika belum memiliki akun.
2.  **Dashboard Utama:** Muncul daftar jurnal yang pernah dibuat. Jika kosong, pengguna menekan _Floating Action Button_ "+" (Tambah).
3.  **Drafting (Writing):**
    - Pengguna mengetik aktivitas hari ini dalam bahasa Inggris.
    - _Contoh Entri (Personalized):_ "Today, I had a meeting with my dospem. We discussed my literature review on eBPF as observability. I also mapped out Sharma's paper using Litmaps to find the research gap. It was productive but quite challenging."
4.  **Teleprompter Mode (Speaking):**
    - Pengguna mengatur _Slider_ kecepatan (contoh: 130 WPM).
    - Pengguna menekan tombol **"Record"**.
    - Mikrofon mulai merekam, dan secara bersamaan **teks akan bergulir ke atas secara otomatis**. Pengguna harus membaca mengejar laju guliran tersebut.
    - Tekan **"Stop"** setelah selesai. File audio tersimpan di latar belakang ke direktori memori HP.
5.  **Penyimpanan (Syncing):**
    - Pengguna menekan **"Save"**.
    - Sistem menyimpan teks dan _path_ audio ke **SQLite**, dan mencadangkan teksnya ke **Firestore**.
6.  **Evaluasi:** Pengguna dapat memutar kembali rekaman suara dari _dashboard_ sambil membaca teks untuk mengevaluasi pelafalan.
