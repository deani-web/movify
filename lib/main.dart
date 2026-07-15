import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
      ),
      // Menggunakan FutureBuilder untuk mengecek status session login saat aplikasi pertama kali dibuka
      home: FutureBuilder<Map<String, dynamic>?>(
        future: authService.getLoggedInUser(),
        builder: (context, snapshot) {
          // Tampilkan loading screen dengan tema warna kamu selagi mengecek SharedPreferences
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          }
          
          // Jika sudah pernah login (data user ditemukan), langsung arahkan ke HomeScreen
          if (snapshot.hasData && snapshot.data != null) {
            return HomeScreen();
          }
          
          // Jika belum login atau session kosong, arahkan ke LoginScreen terlebih dahulu
          return const LoginScreen();
        },
      ),
    );
  }
}