import 'package:flutter/material.dart';
import '../services/watchlist_service.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../utils/colors.dart';
import 'detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final WatchlistService _watchlistService = WatchlistService();
  List<Movie> _watchlist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    final watchlist = await _watchlistService.getWatchlist();
    setState(() {
      _watchlist = watchlist;
      _isLoading = false;
    });
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
                'Watchlist',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: _watchlist.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 80,
                              color: AppColors.secondaryBackground,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Your watchlist is empty',
                              style: TextStyle(
                                color: AppColors.dark,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.54, // 👈 Diubah dari 0.65 ke 0.54 untuk menambah tinggi card ke bawah
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: _watchlist.length,
                        itemBuilder: (context, index) {
                          final movie = _watchlist[index];
                          return MovieCard(
                            movie: movie,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(movie: movie),
                                ),
                              ).then((_) => _loadWatchlist());
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
}