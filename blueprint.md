
# Blueprint: Aplikasi Koperasi Mahasiswa

## 1. Ikhtisar Proyek

Aplikasi Koperasi Mahasiswa adalah aplikasi seluler yang dirancang untuk mengelola operasi dan keanggotaan koperasi di lingkungan mahasiswa. Aplikasi ini menyediakan fitur untuk otentikasi pengguna, manajemen produk, pencatatan transaksi, dan pelaporan keuangan.

## 2. Gaya, Desain, dan Fitur yang Diimplementasikan

### **Tema dan Gaya Utama**

*   **Palet Warna:** Menggunakan `Colors.brown` sebagai warna primer, menciptakan nuansa yang hangat, profesional, dan dapat dipercaya.
*   **Tipografi:**
    *   Menggunakan paket `google_fonts` untuk gaya teks yang modern dan mudah dibaca.
    *   **Judul Aplikasi (`AppBar`):** `GoogleFonts.montserrat` dengan `fontWeight: FontWeight.bold` untuk kesan yang kuat dan jelas.
    *   **Teks Utama:** `GoogleFonts.latoTextTheme` untuk konten di seluruh aplikasi, memberikan keterbacaan yang sangat baik.
*   **Desain `AppBar`:** Konsisten di seluruh aplikasi dengan latar belakang gradien dari `Colors.brown[700]` ke `Colors.brown[900]`, memberikan tampilan yang premium dan modern.

### **Fungsionalitas Utama**

1.  **Otentikasi Pengguna (\`lib/auth/\`)**
    *   Menggunakan Firebase Authentication.
    *   Halaman login dengan email dan kata sandi.
    *   Halaman pendaftaran untuk pengguna baru.
    *   `AuthWrapper` secara otomatis mengarahkan pengguna ke halaman yang sesuai (login atau dasbor) berdasarkan status otentikasi mereka.

2.  **Dasbor Utama (\`lib/views/dashboard_page.dart\`)**
    *   Menampilkan ringkasan informasi penting.
    *   Menyediakan navigasi utama ke fitur-fitur lain seperti "Manajemen Produk", "Riwayat Penjualan", dan "Laporan Keuangan".
    *   Menyertakan tombol logout.

3.  **Manajemen Produk (\`lib/views/products/\`)**
    *   Menampilkan daftar produk dari koleksi `products` di Firestore.
    *   **CRUD Penuh:** Pengguna dapat menambah, melihat, memperbarui, dan menghapus data produk.
    *   **Pencarian Produk:** Fitur pencarian *real-time* untuk menyaring produk berdasarkan nama.

4.  **Manajemen Penjualan (\`lib/views/penjualan/\`)**
    *   Menampilkan riwayat penjualan dari koleksi `sales`.
    *   **CRUD Penuh:** Pengguna dapat membuat, memperbarui, dan menghapus catatan penjualan.
    *   **Filter & Ekspor:** Memungkinkan pemfilteran data penjualan berdasarkan rentang tanggal dan mengekspor hasilnya ke file CSV.

5.  **Laporan Keuangan Terpusat (\`lib/views/rekap/rekap_page.dart\`)**
    *   **Akses:** Dapat diakses melalui tombol **"Keuangan"** di halaman Dasbor.
    *   **Struktur Tab:** Halaman ini dibagi menjadi dua bagian utama menggunakan `TabBar`:
        *   **Tab Pemasukan:**
            *   Menampilkan data dari koleksi `sales`.
            *   Mengelompokkan semua pemasukan (penjualan) berdasarkan hari.
            *   Setiap grup harian ditampilkan dalam `ExpansionTile` untuk menunjukkan total pendapatan hari itu dan detail setiap transaksi di dalamnya.
        *   **Tab Pengeluaran:**
            *   Menampilkan data dari koleksi `withdrawals`.
            *   Menampilkan setiap item pengeluaran dalam kartu individual.
            *   **CRUD Penuh untuk Pengeluaran.**

6.  **Manajemen Gambar dengan Cloudinary (\`lib/services/cloudinary_service.dart\`)**
    *   **Migrasi dari Firebase Storage:** Sistem manajemen gambar telah sepenuhnya dimigrasikan ke Cloudinary untuk optimasi dan transformasi gambar yang lebih baik.
    *   **Layanan Terpusat:** `CloudinaryService` menangani semua logika unggah gambar untuk nota pengeluaran dan gambar produk.
    *   **Penyimpanan Metadata:** URL gambar (`secure_url`) dan ID unik (`public_id`) disimpan di Firestore untuk setiap gambar yang diunggah. Ini memungkinkan manajemen gambar yang lebih baik, termasuk kemungkinan penghapusan di masa depan.
    *   **Upload Preset:** Menggunakan sistem *unsigned upload* Cloudinary dengan *upload preset* (`kopma_preset`) untuk keamanan dan kesederhanaan dari sisi klien.

## 3. Rencana Saat Ini

**Status:** Selesai.

**Tugas yang Diselesaikan:**

*   **Migrasi Penuh ke Cloudinary:** Mengganti seluruh fungsionalitas unggah, pembaruan, dan penyimpanan gambar dari Firebase Storage ke Cloudinary. Ini mencakup:
    *   Penambahan `cloudinary_public`.
    *   Pembuatan `CloudinaryService`.
    *   Pembaruan model `Product` dan `Withdrawal` untuk menyertakan `public_id`.
    *   Refaktor halaman *create* dan *update* untuk Produk dan Pengeluaran.
    *   Pembersihan dependensi yang tidak terpakai.
*   **Validasi Ulang Kode:** Memeriksa kembali kode, termasuk `lib/views/penjualan/index_page.dart`, dan mengonfirmasi bahwa peringatan `dead_code` yang dilaporkan sebelumnya telah teratasi dengan adanya fungsi `_exportData` yang baru.

**Tugas Berikutnya:** Menunggu arahan atau laporan masalah baru dari pengguna. Proyek berada dalam keadaan stabil.
