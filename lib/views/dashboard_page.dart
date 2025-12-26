import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/views/products/index_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Koperasi', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown[700]!, Colors.brown[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Keuangan',
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: _InfoBox(title: 'Pemasukan', value: 'Rp 1.250.000', icon: Icons.arrow_circle_up, iconColor: Colors.green)),
                  SizedBox(width: 16),
                  Expanded(child: _InfoBox(title: 'Pengeluaran', value: 'Rp 350.000', icon: Icons.arrow_circle_down, iconColor: Colors.red)),
                ],
              ),
              const SizedBox(height: 16),
              const _InfoBox(title: 'Saldo Saat Ini', value: 'Rp 900.000', icon: Icons.account_balance_wallet, iconColor: Colors.blue),
              const SizedBox(height: 32),
              Text(
                'Aksi Cepat',
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _ActionButton(
                    icon: Icons.shopping_cart_checkout,
                    label: 'Penjualan',
                    onTap: () {
                      // Navigate to sales page
                    },
                  ),
                  _ActionButton(
                    icon: Icons.inventory_2,
                    label: 'Produk',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductIndex()),
                      );
                    },
                  ),
                  _ActionButton(
                    icon: Icons.receipt_long,
                    label: 'Keuangan',
                    onTap: () {
                      // Navigate to finance page
                    },
                  ),
                   _ActionButton(
                    icon: Icons.groups,
                    label: 'Anggota',
                    onTap: () {
                      // Navigate to members page
                    },
                  ),
                ],
              )
            ],
          ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.lato(fontSize: 15, color: Colors.brown[800], fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[900],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.brown[600]!, Colors.brown[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
           boxShadow: [
            BoxShadow(
              color: Colors.brown[800]!.withValues(alpha:0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              label, 
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      ),
    );
  }
}
