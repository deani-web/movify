import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class DownloadService {
  static const String _downloadKey = 'downloaded_movies';

  // Mengambil daftar film yang berhasil di-download dari SharedPreferences
  Future<List<Movie>> getDownloadedMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? moviesString = prefs.getString(_downloadKey);
      
      if (moviesString == null) {
        return [];
      }
      
      final List<dynamic> decodedList = json.decode(moviesString);
      return decodedList.map((item) {
        // Menggunakan fromJson jika ada, jika tidak, lakukan parsing manual yang aman
        return _parseMovie(item);
      }).toList();
    } catch (e) {
      print("Error loading downloaded movies: $e");
      return [];
    }
  }

  // Menyimpan film baru ke dalam daftar download lokal
  Future<void> addToDownloads(Movie movie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Movie> currentDownloads = await getDownloadedMovies();
      
      // Cek apakah film sudah di-download sebelumnya agar tidak duplikat
      if (!currentDownloads.any((item) => item.id == movie.id)) {
        currentDownloads.add(movie);
        
        final List<Map<String, dynamic>> encodedList = currentDownloads.map((item) {
          return _movieToMap(item);
        }).toList();

        final String encodedData = json.encode(encodedList);
        await prefs.setString(_downloadKey, encodedData);
      }
    } catch (e) {
      print("Error adding movie to downloads: $e");
    }
  }

  // Menghapus film dari daftar download lokal
  Future<void> removeFromDownloads(int movieId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Movie> currentDownloads = await getDownloadedMovies();
      
      currentDownloads.removeWhere((item) => item.id == movieId);
      
      final List<Map<String, dynamic>> encodedList = currentDownloads.map((item) {
        return _movieToMap(item);
      }).toList();

      final String encodedData = json.encode(encodedList);
      await prefs.setString(_downloadKey, encodedData);
    } catch (e) {
      print("Error removing movie from downloads: $e");
    }
  }

  // Cek apakah film tertentu sudah di-download
  Future<bool> isDownloaded(int movieId) async {
    final currentDownloads = await getDownloadedMovies();
    return currentDownloads.any((item) => item.id == movieId);
  }

  // ================= HELPER METHODS UNTUK SERIALISASI DATA =================
  
  // Fungsi cadangan untuk parsing data JSON -> Objek Movie jika model belum full support
  Movie _parseMovie(Map<String, dynamic> map) {
    try {
      // Mencoba menggunakan method standard generator fromJson jika tersedia
      return Movie.fromJson(map);
    } catch (_) {
      // Fallback manual berdasarkan variabel umum di kelas Movie
      return Movie(
        id: map['id'] ?? 0,
        title: map['title'] ?? '',
        overview: map['overview'] ?? '',
        posterPath: map['posterPath'] ?? map['poster_path'] ?? '',
        backdropPath: map['backdropPath'] ?? map['backdrop_path'] ?? '',
        voteAverage: (map['voteAverage'] ?? map['vote_average'] ?? 0.0).toDouble(),
        releaseDate: map['releaseDate'] ?? map['release_date'] ?? '',
        // Field tambahan opsional yang mungkin ada di detail screen kamu
        runtime: map['runtime'],
        status: map['status'],
      );
    }
  }

  // Fungsi cadangan untuk mengubah Objek Movie -> Map JSON
  Map<String, dynamic> _movieToMap(Movie movie) {
    try {
      // Mencoba memanggil method toJson jika tersedia di model Movie-mu
      return (movie as dynamic).toJson();
    } catch (_) {
      // Fallback manual memetakan data ke Map
      return {
        'id': movie.id,
        'title': movie.title,
        'overview': movie.overview,
        'posterPath': movie.posterPath,
        'backdropPath': movie.backdropPath,
        'voteAverage': movie.voteAverage,
        'releaseDate': movie.releaseDate,
        'runtime': movie.runtime,
        'status': movie.status,
      };
    }
  }
}