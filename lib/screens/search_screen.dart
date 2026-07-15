import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_loader.dart';
import '../utils/colors.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  List<Genre> _genres = [];
  Genre? _selectedGenre;
  bool _isLoadingGenres = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadGenres();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadGenres() async {
    try {
      final genres = await _apiService.getGenres();
      setState(() {
        _genres = genres;
        _isLoadingGenres = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGenres = false;
      });
    }
  }

  Future<void> _onSearchChanged() async {
    final query = _searchController.text;
    if (query.isEmpty && _selectedGenre == null) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isSearching = true;
    });
    try {
      List<Movie> results;
      if (_selectedGenre != null) {
        results = await _apiService.getMoviesByGenre(_selectedGenre!.id);
      } else {
        results = await _apiService.searchMovies(query);
      }
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search movies...',
                  prefixIcon: Icon(Icons.search, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.secondaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              if (!_isLoadingGenres)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _genres.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text('All'),
                            selected: _selectedGenre == null,
                            onSelected: (selected) {
                              setState(() {
                                _selectedGenre = null;
                                _onSearchChanged();
                              });
                            },
                            backgroundColor: AppColors.secondaryBackground,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: _selectedGenre == null ? Colors.white : AppColors.dark,
                            ),
                          ),
                        );
                      }
                      final genre = _genres[index - 1];
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(genre.name),
                          selected: _selectedGenre?.id == genre.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedGenre = selected ? genre : null;
                              _onSearchChanged();
                            });
                          },
                          backgroundColor: AppColors.secondaryBackground,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _selectedGenre?.id == genre.id
                                ? Colors.white
                                : AppColors.dark,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 24),
              Expanded(
                child: _isSearching
                    ? _buildShimmerResults()
                    : _searchResults.isEmpty
                        ? Center(
                            child: Text('No movies found'),
                          )
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.58, // Diubah dari 0.65 ke 0.58 agar card lebih panjang ke bawah
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final movie = _searchResults[index];
                              return MovieCard(
                                movie: movie,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(movie: movie),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerResults() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58, // Disamakan menjadi 0.58 agar ukuran loader pas
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ShimmerLoader(
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}