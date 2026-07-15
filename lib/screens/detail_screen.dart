import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/api_service.dart';
import '../services/watchlist_service.dart';
import '../services/auth_service.dart';
import '../services/download_service.dart'; // Import DownloadService yang sudah diperbaiki
import '../models/movie.dart';
import '../utils/colors.dart';
import 'premium_screen.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;

  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService _apiService = ApiService();
  final WatchlistService _watchlistService = WatchlistService();
  final AuthService _authService = AuthService();
  final DownloadService _downloadService = DownloadService(); // Inisialisasi DownloadService

  Movie? _movieDetails;
  List<Cast> _cast = [];
  List<Video> _videos = [];
  bool _isLoading = true;
  bool _isInWatchlist = false;

  bool _isPremiumUser = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isAlreadyDownloaded = false; // Status untuk mengecek apakah film sudah di-download sebelumnya

  YoutubePlayerController? _ytController;
  bool _hasTrailer = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    _checkWatchlist();
    _checkPremiumStatus();
    _checkDownloadStatus(); // Cek apakah film ini sudah pernah di-download
  }

  Future<void> _loadDetails() async {
    try {
      final details = await _apiService.getMovieDetails(widget.movie.id);
      final cast = await _apiService.getMovieCredits(widget.movie.id);
      final videos = await _apiService.getMovieVideos(widget.movie.id);
      setState(() {
        _movieDetails = details;
        _cast = cast;
        _videos = videos;
        _isLoading = false;
      });
      
      _initializeYoutubePlayer();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeYoutubePlayer() {
    if (_videos.isEmpty) return;

    Video? trailer;
    try {
      trailer = _videos.firstWhere(
        (v) => v.site == 'YouTube' && (v.type == 'Trailer' || v.type == 'Teaser'),
      );
    } catch (e) {
      if (_videos.isNotEmpty && _videos.first.site == 'YouTube') {
        trailer = _videos.first;
      }
    }

    if (trailer != null && trailer.key.isNotEmpty) {
      setState(() {
        _ytController = YoutubePlayerController(
          initialVideoId: trailer!.key,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            forceHD: false,
          ),
        );
        _hasTrailer = true;
      });
    }
  }

  Future<void> _checkWatchlist() async {
    final inList = await _watchlistService.isInWatchlist(widget.movie.id);
    setState(() {
      _isInWatchlist = inList;
    });
  }

  Future<void> _checkPremiumStatus() async {
    final isPremium = await _authService.isUserPremium();
    setState(() {
      _isPremiumUser = isPremium;
    });
  }

  // Cek status download film ini di database lokal
  Future<void> _checkDownloadStatus() async {
    final downloaded = await _downloadService.isDownloaded(widget.movie.id);
    setState(() {
      _isAlreadyDownloaded = downloaded;
    });
  }

  // Fungsi proses download film nyata dan menyimpannya ke local storage
  Future<void> _startDownload() async {
    if (!_isPremiumUser) {
      _showUpgradeDialog();
      return;
    }

    if (_isAlreadyDownloaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Film ini sudah berhasil di-download sebelumnya!'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    // Simulasi visual progress bar (dari 10% sampai 100%)
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      setState(() {
        _downloadProgress = i / 10;
      });
    }

    // SIMPAN KE DATABASE LOKAL SECARA NYATA
    final movieToSave = _movieDetails ?? widget.movie;
    await _downloadService.addToDownloads(movieToSave);

    setState(() {
      _isDownloading = false;
      _isAlreadyDownloaded = true; // Update status tombol menjadi "Downloaded"
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${widget.movie.title}" berhasil disimpan secara offline!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Fitur Movify Premium',
              style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Download offline hanya tersedia untuk pengguna Premium. Nikmati film tanpa kuota di mana saja dengan berlangganan!',
          style: TextStyle(color: AppColors.dark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti Saja', style: TextStyle(color: AppColors.dark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () async {
              Navigator.pop(context);
              
              final purchased = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );

              if (purchased == true) {
                _checkPremiumStatus();
              }
            },
            child: const Text('Upgrade Sekarang', style: TextStyle(color: AppColors.background)),
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    _ytController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movie = _movieDetails ?? widget.movie;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: movie.backdropUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.secondaryBackground,
                            child: const Icon(Icons.movie),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.background,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                width: 120,
                                height: 180,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  width: 120,
                                  height: 180,
                                  color: AppColors.secondaryBackground,
                                  child: const Icon(Icons.movie),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        movie.voteAverage.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (movie.releaseDate.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        movie.releaseDate,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  if (movie.runtime != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${movie.runtime} min',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  if (movie.status != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        movie.status!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  
                                  // TOMBOL WATCHLIST & INTERFACE DOWNLOAD NYATA
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          if (_isInWatchlist) {
                                            await _watchlistService
                                                .removeFromWatchlist(movie.id);
                                          } else {
                                            await _watchlistService
                                                .addToWatchlist(movie);
                                          }
                                          await _checkWatchlist();
                                        },
                                        icon: Icon(
                                          _isInWatchlist
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                        ),
                                        label: Text(
                                          _isInWatchlist
                                              ? 'In Watchlist'
                                              : 'Add to Watchlist',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      
                                      // RENDERING STATUS DOWNLOAD SENSITIF
                                      if (_isDownloading) ...[
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: LinearProgressIndicator(
                                                value: _downloadProgress,
                                                color: Colors.green,
                                                backgroundColor: AppColors.secondaryBackground,
                                                minHeight: 8,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Downloading... ${(_downloadProgress * 100).toInt()}%',
                                              style: const TextStyle(
                                                fontSize: 12, 
                                                color: AppColors.dark, 
                                                fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ],
                                        )
                                      ] else ...[
                                        ElevatedButton.icon(
                                          onPressed: _startDownload,
                                          icon: Icon(
                                            _isAlreadyDownloaded 
                                                ? Icons.check_circle 
                                                : Icons.download_for_offline,
                                            color: _isAlreadyDownloaded 
                                                ? Colors.white 
                                                : (_isPremiumUser ? Colors.green : Colors.grey),
                                          ),
                                          label: Text(
                                            _isAlreadyDownloaded 
                                                ? 'Downloaded' 
                                                : (_isPremiumUser ? 'Download Movie' : 'Premium Download'),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _isAlreadyDownloaded 
                                                ? Colors.green 
                                                : (_isPremiumUser 
                                                    ? Colors.green.withOpacity(0.15) 
                                                    : AppColors.secondaryBackground.withOpacity(0.5)),
                                            foregroundColor: _isAlreadyDownloaded 
                                                ? Colors.white 
                                                : (_isPremiumUser ? Colors.green : AppColors.dark),
                                            elevation: _isAlreadyDownloaded ? 2 : 0,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              side: BorderSide(
                                                color: _isAlreadyDownloaded 
                                                    ? Colors.green 
                                                    : (_isPremiumUser ? Colors.green : Colors.grey.shade400),
                                                width: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.overview,
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Trailer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _hasTrailer && _ytController != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: YoutubePlayer(
                                  controller: _ytController!,
                                  showVideoProgressIndicator: true,
                                  progressIndicatorColor: AppColors.primary,
                                  progressColors: const ProgressBarColors(
                                    playedColor: AppColors.primary,
                                    handleColor: Colors.amber,
                                  ),
                                ),
                              )
                            : Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Trailer tidak tersedia',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 24),
                        
                        const Text(
                          'Cast',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _cast.length,
                            itemBuilder: (context, index) {
                              final actor = _cast[index];
                              return Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedNetworkImage(
                                        imageUrl: actor.profileUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          width: 80,
                                          height: 80,
                                          color: AppColors.secondaryBackground,
                                          child: const Icon(Icons.person),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      actor.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.dark,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      actor.character,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}