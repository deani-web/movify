import 'package:flutter/material.dart';
import 'discover_screen.dart';
import 'tv_series_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';
import 'profile_screen.dart';
import '../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Di sini kata kunci 'const' dihapus karena constructor screen kamu belum 'const'
  final List<Widget> _screens = [
    DiscoverScreen(),
    TVSeriesScreen(),
    SearchScreen(),
    WatchlistScreen(),
    const ProfileScreen(), // Ini tetap boleh const karena ProfileScreen sudah dideklarasikan const
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.secondaryBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.dark,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'TV Series',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}