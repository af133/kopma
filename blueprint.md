### Ringkasan

Aplikasi ini adalah aplikasi Flutter lintas platform (Android, iOS, Web) yang berfungsi sebagai dasbor admin internal untuk mengelola berbagai aspek operasional, termasuk:

*   **Manajemen Produk:** Menambah, melihat, memperbarui, dan menghapus data produk.
*   **Manajemen Kategori:** Mengelola kategori produk.
*   **Manajemen Inventaris:** Melacak stok produk.
*   **Dasbor Keuangan Terpadu:** Memberikan gambaran umum tentang kesehatan keuangan dengan menggabungkan catatan pemasukan (dari data penjualan) dan pengeluaran dalam satu tampilan yang terpadu dan terurut berdasarkan waktu.

### Gaya, Desain, dan Fitur

*   **Tema:** Menggunakan Material 3 dengan skema warna berbasis `Colors.deepPurple`.
*   **Tipografi:** Memanfaatkan paket `google_fonts`.
*   **Navigasi:** Menggunakan `go_router` untuk navigasi berbasis rute.
*   **Arsitektur:** Mengikuti struktur berbasis fitur (`views`, `services`, `models`).
*   **UI Components:** Memanfaatkan widget Material standar seperti `Card`, `ListTile`, `FloatingActionButton`, dan `DataTable`.
*   **Layanan Backend:** Berintegrasi dengan Firebase (Firestore) dan Cloudinary.

### Rencana Perubahan Saat Ini & Log Perbaikan

**Tugas: Merombak Halaman Keuangan & Perbaikan Bug Kestabilan Data**

1.  **Pengembangan Awal Dasbor Keuangan:**
    *   Mengimplementasikan `FinancialDashboardPage` dengan `StreamZip` untuk menggabungkan data pemasukan dan pengeluaran.
    *   **Status:** Selesai.

2.  **Perbaikan Bug #1: Logika Perhitungan Pendapatan**
    *   **Masalah:** Ditemukan bahwa total pendapatan harian dihitung secara tidak konsisten.
    *   **Solusi:** Memperbaiki logika di `FinancialService` untuk menghitung total pendapatan hanya dari data `items`.
    *   **Status:** Selesai.

3.  **Perbaikan Bug #2: Kestabilan `FinancialService`**
    *   **Masalah:** Ditemukan bahwa data yang tidak konsisten (misalnya, angka sebagai string) di database menyebabkan seluruh stream gagal, sehingga data tidak muncul.
    *   **Solusi:** Menambahkan parsing yang kuat (`_parseInt`, `_parseDouble`) dan blok `try-catch` yang lebih baik di dalam `FinancialService`.
    *   **Status:** Selesai.

4.  **Perbaikan Bug #3: Akar Masalah pada Model Data (Perbaikan Definitif)**
    *   **Masalah:** Setelah investigasi lebih dalam, ditemukan bahwa akar masalah sebenarnya terletak pada konstruktor `FinancialRecord.fromFirestore` di file model, yang tidak dapat menangani variasi format data (misalnya `cost` sebagai `String`).
    *   **Solusi:** Merombak total konstruktor `FinancialRecord.fromFirestore` dengan menambahkan *helper function* `_parseDouble` dan `_parseDate`. Ini membuat model menjadi *anti-rapuh* dan mampu mem-parsing data `cost` dan `date` dari berbagai format (`num`, `String`, `Timestamp`) tanpa gagal. Ini memastikan semua data pengeluaran yang valid dapat ditampilkan.
    *   **Status:** Selesai.
