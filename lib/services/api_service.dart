
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String apiKey = '3fd2be6f0c70a2a598f084ddfb75487c';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getTrendingMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((item) => Movie.fromJson(item))
          .toList();
    }
    throw Exception('Failed to load trending movies');
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((item) => Movie.fromJson(item))
          .toList();
    }
    throw Exception('Failed to load now playing movies');
  }

  Future<List<Movie>> getUpcomingMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/upcoming?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((item) => Movie.fromJson(item))
          .toList();
    }
    throw Exception('Failed to load upcoming movies');
  }

  Future<List<TVSeries>> getPopularTVSeries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/popular?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((item) => TVSeries.fromJson(item))
          .toList();
    }
    throw Exception('Failed to load popular TV series');
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromJson(data);
    }
    throw Exception('Failed to load movie details');
  }

  Future<List<Cast>> getMovieCredits(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId/credits?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['cast'] as List)
          .map((item) => Cast.fromJson(item))
          .toList();
    }
    throw Exception('Failed to load movie credits');
  }

  Future<List<Video>> getMovieVideos(int movieId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((item) => Video.fromJson(item))
          .toList();
    }
    throw Exception('Failed to load movie videos');
  }

  Future<List<Genre>> getGenres() async {
    final response = await http.get(
      Uri.parse('$baseUrl/genre/movie/list?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['genres'] as List)
          .map((item) => Genre.fromJson(item))
          .toList();
    }
    throw Exception('Failed to load genres');
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((item) => Movie.fromJson(item))
          .toList();
    }
    throw Exception('Failed to search movies');
  }

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/discover/movie?api_key=$apiKey&with_genres=$genreId'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((item) => Movie.fromJson(item))
          .toList();
    }
    throw Exception('Failed to load movies by genre');
  }

  Future<TVSeries> getTVDetails(int tvId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$tvId?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return TVSeries.fromJson(data);
    }
    throw Exception('Failed to load TV details');
  }

  Future<List<Cast>> getTVCredits(int tvId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$tvId/credits?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['cast'] as List)
          .map((item) => Cast.fromJson(item))
          .toList();
    }
    throw Exception('Failed to load TV credits');
  }

  Future<List<Video>> getTVVideos(int tvId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/$tvId/videos?api_key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((item) => Video.fromJson(item))
          .toList();
    }
    throw Exception('Failed to load TV videos');
  }
}
