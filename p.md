# DOKUMEN SPESIFIKASI PROYEK: DailyLingo 
**(English Audio Diary & Fluency Tracker)**

## 1. Deskripsi Eksekutif
**DailyLingo** adalah aplikasi jurnal harian (*diary*) berbasis *mobile* yang dirancang untuk melatih kemampuan menulis (*writing*) dan kelancaran berbicara (*speaking fluency*) dalam bahasa Inggris. Pengguna mencatat aktivitas harian mereka dalam bahasa Inggris, lalu merekam suara mereka saat membacakan catatan tersebut dengan bantuan fitur *Teleprompter Auto-Scroll*. Aplikasi ini mengevaluasi pelafalan sekaligus melatih pengguna untuk berbicara dengan kecepatan yang konstan (*Words Per Minute*).

## 2. Arsitektur & Pemetaan Kriteria Penilaian

### A. Autentikasi Pengguna (Firebase Auth - 5%)
* **Fitur:** Layar *Login* dan *Register* terpusat.
* **Mekanisme:** Menggunakan Email dan Password via Firebase Authentication.
* **Fungsi:** Mengamankan privasi jurnal pengguna agar data hanya dapat diakses oleh akun yang bersangkutan, serta menjadi fondasi *User ID* untuk pencadangan data teks ke *cloud*.

### B. Manajemen Jurnal (CRUD Relational DB - 10%)
* **Fitur:** Sistem pencatatan buku harian utama.
* **Mekanisme:** Menggunakan database relasional lokal (**SQLite**) melalui *package* `sqflite`.
* **Struktur Tabel `diary_logs`:**
    * `id` (Primary Key, Integer)
    * `date` (Timestamp / Text)
    * `title` (Text)
    * `content` (Text - Teks jurnal bahasa Inggris)
    * `local_audio_path` (Text - Direktori lokal file audio di memori internal HP)
* **Operasi CRUD:**
    * *Create:* Membuat entri teks baru beserta referensi file audio lokal.
    * *Read:* Menampilkan daftar jurnal berdasarkan tanggal (*List View*).
    * *Update:* Mengedit teks jika ada kesalahan tata bahasa (*grammar*).
    * *Delete:* Menghapus entri teks beserta file rekaman lokalnya.

### C. Perekaman Suara & Teleprompter (Resource Smartphone - 5%)
* **Fitur:** Perekam suara internal (*built-in*) yang dilengkapi dengan *Teleprompter Auto-Scroll* untuk latihan kelancaran membaca.
* **Mekanisme Perekaman:** Memanfaatkan **Microphone** via *package* `record`. Output file audio (`.m4a` atau `.mp3`) disimpan murni **secara lokal di penyimpanan internal *smartphone*** menggunakan `path_provider` (tidak menyedot kuota internet/server).
* **Mekanisme Teleprompter:** * Pengguna mengatur target kecepatan berbicara menggunakan *Slider* berformat **WPM** (*Words Per Minute*), misalnya dari 100 WPM hingga 200 WPM.
    * Menggunakan `ScrollController.animateTo()`, aplikasi akan menggulirkan teks ke atas secara otomatis dengan durasi kalkulasi matematis (`Total Kata / Kecepatan WPM`). Jika pengguna membaca terlalu lambat, teks akan tertinggal.

### D. Sinkronisasi Awan (Storing Data in Firebase - 5%)
* **Fitur:** Pencadangan data jurnal teks (*Cloud Text Sync*).
* **Mekanisme:** Menggunakan **Cloud Firestore** (NoSQL Database) - *Gratis pada Spark Plan*. 
* **Logika:** Setiap kali pengguna menyimpan entri di SQLite, aplikasi akan mengirimkan salinan data teks (`title`, `content`, `date`) ke koleksi Firestore di bawah dokumen spesifik milik *User ID* tersebut. File audio **tidak** diunggah, melainkan tetap di HP.

### E. Pengingat Harian (Notifications - 5%)
* **Fitur:** Sistem *push-notification* lokal terjadwal.
* **Mekanisme:** Menggunakan `flutter_local_notifications`. Diatur agar muncul setiap malam hari.
* **Teks Notifikasi:** *"Time for your DailyLingo! What did you do today? Let's write and speak it out."*

---

## 3. Alur Kerja Aplikasi (User Flow)

1.  **Akses:** Pengguna membuka aplikasi dan melakukan *login* (Firebase Auth).
2.  **Dashboard Utama:** Muncul daftar jurnal yang pernah dibuat. Jika kosong, pengguna menekan *Floating Action Button* "+" (Tambah).
3.  **Drafting (Writing):**
    * Pengguna mengetik aktivitas hari ini dalam bahasa Inggris.
    * *Contoh Entri (Personalized):* "Today, I had a meeting with my dospem. We discussed my literature review on eBPF as observability. I also mapped out Sharma's paper using Litmaps to find the research gap. It was productive but quite challenging."
4.  **Teleprompter Mode (Speaking):**
    * Pengguna mengatur *Slider* kecepatan (contoh: 130 WPM).
    * Pengguna menekan tombol **"Record"**.
    * Mikrofon mulai merekam, dan secara bersamaan **teks akan bergulir ke atas secara otomatis**. Pengguna harus membaca mengejar laju guliran tersebut.
    * Tekan **"Stop"** setelah selesai. File audio tersimpan di latar belakang ke direktori memori HP.
5.  **Penyimpanan (Syncing):**
    * Pengguna menekan **"Save"**.
    * Sistem menyimpan teks dan *path* audio ke **SQLite**, dan mencadangkan teksnya ke **Firestore**.
6.  **Evaluasi:** Pengguna dapat memutar kembali rekaman suara dari *dashboard* sambil membaca teks untuk mengevaluasi pelafalan.

---

## 4. Panduan Rencana Eksekusi (Sprint 2 Minggu)

**Minggu 1: Fondasi Lokal (UI, CRUD, & Logika Teleprompter)**
* **Hari 1-2:** Inisialisasi *project* Flutter, struktur folder *Clean Architecture*, dan desain UI (Halaman Login, Dashboard, Form Input, Layar Teleprompter).
* **Hari 3-5:** Implementasi `sqflite` (Database Relasional). Pastikan Create, Read, Update, dan Delete berjalan lancar.
* **Hari 6-7:** Integrasi `record`, `path_provider`, dan logika algoritma `ScrollController` (Teleprompter Auto-scroll berdasarkan kalkulasi WPM). 

**Minggu 2: Integrasi Cloud, Notifikasi, & Persiapan Rilis**
* **Hari 8-9:** Setup Firebase via Firebase CLI. Aktifkan *Authentication*, buat logika Register/Login di aplikasi.
* **Hari 10-11:** Aktifkan *Cloud Firestore*. Buat *trigger* agar data SQLite tersinkronisasi (hanya teksnya) ke koleksi Firestore saat tombol *Save* ditekan.
* **Hari 12:** Implementasi `flutter_local_notifications` untuk pengingat jadwal menulis.
* **Hari 13-14 (Demo & GitHub - 10%):** * *Screen record* aplikasi Anda: Tunjukkan proses Login -> Menulis Jurnal -> **Mendemonstrasikan teks bergulir saat merekam suara** -> Tunjukkan data masuk ke SQLite (tampil di UI) -> Buka *browser* dan tunjukkan teks masuk ke konsol Firebase Firestore.
    * Unggah ke GitHub beserta dokumen spesifikasi ini sebagai `README.md`.