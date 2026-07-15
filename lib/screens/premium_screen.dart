import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final AuthService _authService = AuthService();
  bool _isProcessing = false;

  // Simulasi proses aktivasi langganan premium
  Future<void> _subscribePremium() async {
    setState(() => _isProcessing = true);

    // Simulasi loading transaksi/pembayaran selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    final success = await _authService.activatePremium();

    setState(() => _isProcessing = false);

    if (success) {
      if (!mounted) return;
      
      // Berhasil mengaktifkan premium
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.background,
          title: const Row(
            children: [
              Icon(Icons.stars, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text(
                'Selamat!',
                style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Akun kamu sekarang sudah aktif menjadi Movify PREMIUM! Nikmati semua film dan fitur premium tanpa batas.',
            style: TextStyle(color: AppColors.dark),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context, true); // Kembali ke Profile dan kirim sinyal update
              },
              child: const Text('Mulai Menonton'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark),
        title: const Text(
          'Movify Premium',
          style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian Header Promosi Premium
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.workspace_premium, size: 64, color: AppColors.background),
                  SizedBox(height: 12),
                  Text(
                    'MOVIFY PREMIUM',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900, // Diperbaiki dari FontWeight.black
                      color: AppColors.background,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Akses ke semua konten film eksklusif tanpa batasan iklan.',
                    style: TextStyle(color: AppColors.background, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Kenapa Harus Premium?',
              style: TextStyle(
                color: AppColors.dark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Keunggulan/Benefit
            _buildBenefitRow(Icons.hd_rounded, 'Kualitas Video Ultra HD (4K)'),
            _buildBenefitRow(Icons.tv_off_rounded, 'Bebas dari Gangguan Iklan (No Ads)'),
            _buildBenefitRow(Icons.download_for_offline_rounded, 'Bisa Download Film Sepuasnya'),
            _buildBenefitRow(Icons.stars_rounded, 'Akses Awal untuk Film Rilis Baru'),
            
            const SizedBox(height: 40),

            // Bagian Harga Paket & Pembelian
            Card(
              color: AppColors.secondaryBackground.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.amber, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Paket Bulanan (Promo)',
                      style: TextStyle(color: AppColors.dark, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rp 49.000',
                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: 28,
                            fontWeight: FontWeight.w900, // Diperbaiki dari FontWeight.black
                          ),
                        ),
                        Text(
                          '/bulan',
                          style: TextStyle(color: AppColors.dark, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isProcessing ? null : _subscribePremium,
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.background,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Langganan Sekarang',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Properti style yang salah di sini sudah dibuang
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.amber.withOpacity(0.1),
            child: Icon(icon, color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.dark,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}