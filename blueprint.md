
# Blueprint: Aplikasi Koperasi Mahasiswa

## 1. Ikhtisar Proyek

Aplikasi Koperasi Mahasiswa adalah aplikasi seluler yang dirancang untuk mengelola operasi dan keanggotaan koperasi di lingkungan mahasiswa. Aplikasi ini menyediakan fitur untuk otentikasi pengguna, melihat ringkasan keuangan, dan mengakses berbagai fungsi koperasi.

## 2. Gaya, Desain, dan Fitur yang Diimplementasikan

Versi awal aplikasi ini berfokus pada penerapan antarmuka pengguna (UI) yang modern, konsisten, dan menarik dengan tema "koperasi".

### **Tema dan Gaya Utama**

*   **Palet Warna:** Skema warna utama didasarkan pada warna `Colors.brown`. Ini memberikan nuansa yang hangat, profesional, dan dapat dipercaya.
*   **Tipografi:** Menggunakan paket `google_fonts` untuk memastikan tipografi yang bersih dan mudah dibaca di seluruh aplikasi. Font utama yang digunakan adalah `Montserrat` untuk judul dan `Lato` untuk teks isi.
*   **Latar Belakang:** Halaman otentikasi (Login dan Registrasi) menggunakan gambar latar belakang bertema finansial yang relevan (`https://images.unsplash.com/photo-1579621970795-87f91d908377?q=80&w=2070...`) untuk memperkuat identitas aplikasi.
*   **Gaya Komponen:**
    *   **Kartu (Card):** Komponen kartu digunakan secara luas untuk membungkus konten, seperti pada form login dan dasbor. Kartu memiliki sudut membulat (`borderRadius: BorderRadius.circular(16)`) dan bayangan (`elevation: 8`) untuk menciptakan efek "terangkat".
    *   **Tombol (Button):** Tombol utama menggunakan `ElevatedButton` dengan latar belakang `Colors.brown[700]` dan teks putih, memastikan kontras yang baik dan keterbacaan.
    *   **Input Fields:** `TextField` didesain dengan latar belakang yang sedikit berbeda (`Colors.brown[50]`), ikon awalan, dan tanpa garis batas untuk tampilan yang bersih.

### **Fitur yang Diimplementasikan**

1.  **Otentikasi Pengguna (Firebase Auth)**
    *   **Halaman Login (`lib/auth/login_page.dart`):**
        *   Desain modern dengan gambar latar belakang, kartu transparan, dan input field yang menarik.
        *   Fungsionalitas login menggunakan email dan password dengan Firebase Auth.
        *   Menampilkan indikator pemuatan (loading) selama proses login.
    *   **Halaman Registrasi (`lib/auth/register_page.dart`):**
        *   Desain yang konsisten dengan halaman login.
        *   Fungsionalitas pendaftaran pengguna baru dengan Firebase Auth.
        *   Menyimpan informasi pengguna tambahan (nama, email, peran) ke Firestore setelah registrasi berhasil.
    *   **Auth Wrapper (`lib/main.dart`):** Sebuah *guard* otentikasi yang secara otomatis mengarahkan pengguna ke halaman dasbor jika sudah login, atau ke halaman login jika belum.

2.  **Halaman Dasbor (`lib/pages/dashboard_page.dart`)**
    *   **AppBar Kustom:** `AppBar` dengan warna tema, judul tebal, dan tombol logout.
    *   **Ringkasan Keuangan (`_InfoBox`):**
        *   Menampilkan ringkasan visual untuk "Pemasukan", "Pengeluaran", dan "Saldo".
        *   Setiap `_InfoBox` didesain dengan ikon yang relevan dan warna berbeda untuk membedakan metrik.
    *   **Aksi Cepat (`_ActionButton`):**
        *   Sebuah `GridView` yang berisi tombol-tombol untuk navigasi cepat ke fitur-fitur utama seperti "Penjualan", "Produk", "Keuangan", dan "Anggota".
        *   Tombol-tombol ini didesain agar mudah diakses dan menarik secara visual.

## 3. Rencana Saat Ini

**Tugas: Finalisasi Desain Awal dan Penjaminan Kualitas**

*   **Tujuan:** Memastikan bahwa semua perubahan UI yang telah diimplementasikan bebas dari kesalahan dan konsisten di seluruh aplikasi.
*   **Langkah-langkah:**
    1.  **Analisis Kode:** Menjalankan `flutter analyze` untuk mendeteksi potensi masalah dalam kode.
    2.  **Pemeriksaan Fungsionalitas:** Memastikan alur otentikasi (login, registrasi, logout) berfungsi seperti yang diharapkan.
    3.  **Pemberitahuan kepada Pengguna:** Melaporkan penyelesaian tugas dan status proyek saat ini.
