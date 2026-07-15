import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 1. FUNGSI REGISTRASI
  // Mendaftarkan user baru ke SharedPreferences dengan field foto kosong dan default non-premium
  Future<bool> register(String name, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> usersList = prefs.getStringList('users') ?? [];
      
      // Cek apakah email yang dimasukkan sudah pernah terdaftar
      for (var userJson in usersList) {
        final Map<String, dynamic> user = jsonDecode(userJson);
        if (user['email'] == email) {
          return false; // Email sudah digunakan
        }
      }
      
      // Bungkus data user baru
      final Map<String, dynamic> newUser = {
        'name': name,
        'email': email,
        'password': password,
        'profile_image': '', // Untuk menampung path foto dari galeri
        'is_premium': false, // Default: Akun gratis biasa
      };
      
      usersList.add(jsonEncode(newUser));
      await prefs.setStringList('users', usersList);
      return true; // Registrasi sukses
    } catch (e) {
      print('Error Register: $e');
      return false;
    }
  }

  // 2. FUNGSI LOGIN
  // Memvalidasi kredensial dan menandai user aktif (menyimpan data ke session logged_in_user)
  Future<bool> login(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> usersList = prefs.getStringList('users') ?? [];
      
      for (var userJson in usersList) {
        final Map<String, dynamic> user = jsonDecode(userJson);
        if (user['email'] == email && user['password'] == password) {
          // Jika cocok, simpan data user aktif ini ke session
          await prefs.setString('logged_in_user', userJson);
          return true; // Login sukses
        }
      }
      return false; // Email atau password salah
    } catch (e) {
      print('Error Login: $e');
      return false;
    }
  }

  // 3. AMBIL DATA USER AKTIF
  // Mengecek status session login saat aplikasi dibuka atau ketika halaman profil membutuhkan data terbaru
  Future<Map<String, dynamic>?> getLoggedInUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('logged_in_user');
      if (userJson != null) {
        return jsonDecode(userJson);
      }
    } catch (e) {
      print('Error mengambil session user: $e');
    }
    return null;
  }

  // 4. UPDATE FOTO PROFIL
  // Menyimpan path foto dari galeri ke data session dan database lokal utama (users list)
  Future<bool> updateProfileImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('logged_in_user');
      if (userJson == null) return false;

      final Map<String, dynamic> currentUser = jsonDecode(userJson);
      final String targetEmail = currentUser['email'];

      // Update foto di session aktif saat ini
      currentUser['profile_image'] = imagePath;
      await prefs.setString('logged_in_user', jsonEncode(currentUser));

      // Update data di database lokal utama (daftar semua user terdaftar)
      final List<String> usersList = prefs.getStringList('users') ?? [];
      final List<String> updatedUsersList = [];

      for (var uJson in usersList) {
        final Map<String, dynamic> u = jsonDecode(uJson);
        if (u['email'] == targetEmail) {
          u['profile_image'] = imagePath;
          updatedUsersList.add(jsonEncode(u));
        } else {
          updatedUsersList.add(uJson);
        }
      }

      await prefs.setStringList('users', updatedUsersList);
      return true;
    } catch (e) {
      print('Error update foto profil: $e');
      return false;
    }
  }

  // 5. AKTIVASI MEMBER PREMIUM
  // Mengubah status akun menjadi premium (is_premium = true) baik di session maupun database lokal
  Future<bool> activatePremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('logged_in_user');
      if (userJson == null) return false;

      final Map<String, dynamic> currentUser = jsonDecode(userJson);
      final String targetEmail = currentUser['email'];

      // Set status premium menjadi true di session aktif
      currentUser['is_premium'] = true;
      await prefs.setString('logged_in_user', jsonEncode(currentUser));

      // Update di database lokal utama (users list)
      final List<String> usersList = prefs.getStringList('users') ?? [];
      final List<String> updatedUsersList = [];

      for (var uJson in usersList) {
        final Map<String, dynamic> u = jsonDecode(uJson);
        if (u['email'] == targetEmail) {
          u['is_premium'] = true;
          updatedUsersList.add(jsonEncode(u));
        } else {
          updatedUsersList.add(uJson);
        }
      }

      await prefs.setStringList('users', updatedUsersList);
      return true;
    } catch (e) {
      print('Error mengaktifkan premium: $e');
      return false;
    }
  }

  // 6. HELPER CEK STATUS PREMIUM
  // Mengembalikan nilai boolean apakah user yang sedang aktif saat ini berstatus premium atau tidak
  Future<bool> isUserPremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('logged_in_user');
      if (userJson != null) {
        final Map<String, dynamic> user = jsonDecode(userJson);
        return user['is_premium'] ?? false;
      }
    } catch (e) {
      print('Error mengecek status premium: $e');
    }
    return false;
  }

  // 7. FUNGSI LOGOUT
  // Menghapus session user aktif dari penyimpanan lokal
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('logged_in_user');
    } catch (e) {
      print('Error Logout: $e');
    }
  }
}