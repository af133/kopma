import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Koperasi', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.brown[700],
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Logout',
          )
        ],
      ),
      backgroundColor: Colors.brown[50],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// RINGKASAN KEUANGAN
            Row(
              children: const [
                Expanded(child: _InfoBox(title: 'Pemasukan', value: 'Rp 0', icon: Icons.arrow_upward, iconColor: Colors.green)),
                SizedBox(width: 12),
                Expanded(child: _InfoBox(title: 'Pengeluaran', value: 'Rp 0', icon: Icons.arrow_downward, iconColor: Colors.red)),
              ],
            ),
            const SizedBox(height: 12),
            const _InfoBox(title: 'Saldo', value: 'Rp 0', icon: Icons.account_balance, iconColor: Colors.blue),

            const SizedBox(height: 24),
            Text(
              'Aksi Cepat',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
              ),
            ),
            const SizedBox(height: 12),

            /// QUICK ACTION
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: const [
                _ActionButton(
                  icon: Icons.shopping_cart,
                  label: 'Penjualan',
                ),
                _ActionButton(
                  icon: Icons.inventory,
                  label: 'Produk',
                ),
                _ActionButton(
                  icon: Icons.account_balance_wallet,
                  label: 'Keuangan',
                ),
                 _ActionButton(
                  icon: Icons.people,
                  label: 'Anggota',
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _InfoBox({required this.title, required this.value, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withAlpha((255 * 0.1).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.lato(fontSize: 14, color: Colors.brown[700])),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[900],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.brown[700],
           boxShadow: [
            BoxShadow(
              color: Colors.brown.withAlpha((255 * 0.2).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
