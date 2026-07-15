import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class WatchlistService {
  static const String _key = 'watchlist';

  // 1. Mengambil semua data watchlist yang tersimpan di SharedPreferences
  Future<List<Movie>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? watchlistJson = prefs.getString(_key);
    
    if (watchlistJson == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(watchlistJson);
      return decoded.map((item) => Movie.fromJson(item)).toList();
    } catch (e) {
      // Jika terjadi error parser / data corrupt, kembalikan list kosong
      return [];
    }
  }

  // 2. Menambahkan film baru ke dalam watchlist
  Future<void> addToWatchlist(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Movie> watchlist = await getWatchlist();
    
    // Gunakan toString() untuk mengantisipasi jika tipe data ID tidak sama
    final bool alreadyExists = watchlist.any(
      (item) => item.id.toString() == movie.id.toString(),
    );

    if (!alreadyExists) {
      watchlist.add(movie);
      final String encodedData = json.encode(
        watchlist.map((m) => m.toJson()).toList(),
      );
      // Tambahkan await untuk memastikan data benar-benar tertulis di memori
      await prefs.setString(_key, encodedData);
    }
  }

  // 3. Menghapus film dari watchlist berdasarkan ID
  Future<void> removeFromWatchlist(dynamic movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Movie> watchlist = await getWatchlist();
    
    watchlist.removeWhere(
      (item) => item.id.toString() == movieId.toString(),
    );
    
    final String encodedData = json.encode(
      watchlist.map((m) => m.toJson()).toList(),
    );
    // Tambahkan await untuk memastikan proses hapus tersinkronisasi di lokal
    await prefs.setString(_key, encodedData);
  }

  // 4. Mengecek apakah suatu film sudah terdaftar di watchlist atau belum
  Future<bool> isInWatchlist(dynamic movieId) async {
    final List<Movie> watchlist = await getWatchlist();
    return watchlist.any(
      (item) => item.id.toString() == movieId.toString(),
    );
  }
}