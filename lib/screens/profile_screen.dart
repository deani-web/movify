import 'dart:convert'; // Ditambahkan untuk encode/decode base64 gambar
import 'dart:typed_data'; // Ditambahkan untuk penanganan bytes gambar
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import 'premium_screen.dart';
import 'download_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  
  String _fullName = "dea";
  String _email = "dea@gmail.com";
  bool _isPremiumUser = false;
  bool _isLoading = true;
  
  // Menggunakan Uint8List agar kompatibel penuh di Web & Mobile tanpa crash dart:io
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadProfileImage(); // Muat foto profil yang tersimpan saat inisialisasi
  }

  // Muat status premium dari service
  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final isPremium = await _authService.isUserPremium();
      setState(() {
        _isPremiumUser = isPremium;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Muat data foto profil berbentuk Base64 dari SharedPreferences
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? base64String = prefs.getString('profile_image_base64');
    
    if (base64String != null) {
      setState(() {
        _profileImageBytes = base64Decode(base64String);
      });
    }
  }

  // Fungsi untuk mengambil foto dari galeri HP / Web
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500, // Kompres ukuran agar tidak terlalu berat disimpan di SharedPreferences
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        final String base64Image = base64Encode(imageBytes);
        
        final prefs = await SharedPreferences.getInstance();
        // Simpan data gambar berupa string base64 agar aman di multiplatform
        await prefs.setString('profile_image_base64', base64Image);
        
        setState(() {
          _profileImageBytes = imageBytes;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Dialog penawaran berlangganan jika user gratisan mencoba mengklik My Downloads
  void _showPremiumAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Fitur Khusus Premium',
              style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Menu "My Downloads" hanya dapat diakses oleh Member Premium agar bisa menonton film offline tanpa kuota.',
          style: TextStyle(color: AppColors.dark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti Saja', style: TextStyle(color: AppColors.dark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              
              final purchased = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );

              if (purchased == true) {
                _loadUserProfile(); // Refresh status premium
              }
            },
            child: const Text('Upgrade Sekarang', style: TextStyle(color: AppColors.background)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EBE1), // Background krem lembut sesuai mockup
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Color(0xFF4A0E2E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B1139)))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // ================= FOTO PROFIL (FIXED MULTIPLATFORM) =================
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF9C344), // Warna kuning dasar
                              border: Border.all(color: Colors.white, width: 3),
                              image: _profileImageBytes != null
                                  ? DecorationImage(
                                      image: MemoryImage(_profileImageBytes!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _profileImageBytes == null
                                ? const Icon(
                                    Icons.person,
                                    size: 90,
                                    color: Color(0xFF4A0E2E),
                                  )
                                : null,
                          ),
                          // Tombol edit kecil di kanan bawah foto profil
                          Container(
                            height: 36,
                            width: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6B1139), // Tombol marun
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                              onPressed: _pickImageFromGallery, // Panggil fungsi buka galeri
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ================= BADGE STATUS MEMBER PREMIUM =================
                    if (_isPremiumUser)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF0D5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber, width: 1.5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stars, color: Colors.amber, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'MEMBER PREMIUM',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade400, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline, color: Colors.grey.shade600, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'FREE MEMBER',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 28),

                    // ================= CARD INFO & DETAIL MENU (KREM) =================
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9EFE5), // Warna background krem card
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // 1. Baris Nama Lengkap
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            leading: const Icon(Icons.person_outline, color: Color(0xFF6B1139), size: 28),
                            title: const Text(
                              'Nama Lengkap',
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              _fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A0E2E),
                              ),
                            ),
                          ),
                          const Divider(height: 1, indent: 68, endIndent: 20, color: Colors.black12),

                          // 2. Baris Email
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            leading: const Icon(Icons.email_outlined, color: Color(0xFF6B1139), size: 28),
                            title: const Text(
                              'Email',
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              _email,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A0E2E),
                              ),
                            ),
                          ),
                          const Divider(height: 1, indent: 68, endIndent: 20, color: Colors.black12),

                          // 3. Baris Navigasi "My Downloads"
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: const Icon(Icons.download_for_offline_outlined, color: Color(0xFF6B1139), size: 28),
                            title: const Text(
                              'My Downloads',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A0E2E),
                              ),
                            ),
                            subtitle: const Text(
                              'Tonton film offline tanpa kuota',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!_isPremiumUser)
                                  const Icon(Icons.lock, color: Colors.amber, size: 18),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6B1139)),
                              ],
                            ),
                            onTap: () async {
                              if (_isPremiumUser) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DownloadScreen()),
                                );
                                _loadUserProfile(); 
                              } else {
                                _showPremiumAlert();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ================= BUTTON KELUAR DARI AKUN =================
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B1139),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.logout_outlined, size: 20),
                        label: const Text(
                          'Keluar dari Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: () async {
                          await _authService.logout();
                          if (mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}