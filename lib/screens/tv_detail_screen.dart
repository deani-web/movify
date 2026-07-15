import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'; // Ganti url_launcher dengan package ini
import '../services/api_service.dart';
import '../models/movie.dart';
import '../utils/colors.dart';

class TVDetailScreen extends StatefulWidget {
  final TVSeries series;

  TVDetailScreen({super.key, required this.series});

  @override
  State<TVDetailScreen> createState() => _TVDetailScreenState();
}

class _TVDetailScreenState extends State<TVDetailScreen> {
  final ApiService _apiService = ApiService();
  TVSeries? _seriesDetails;
  List<Cast> _cast = [];
  List<Video> _videos = [];
  bool _isLoading = true;

  // Deklarasi controller untuk YouTube Player
  YoutubePlayerController? _ytController;
  bool _hasTrailer = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await _apiService.getTVDetails(widget.series.id);
      final cast = await _apiService.getTVCredits(widget.series.id);
      final videos = await _apiService.getTVVideos(widget.series.id);
      setState(() {
        _seriesDetails = details;
        _cast = cast;
        _videos = videos;
        _isLoading = false;
      });

      // Inisialisasi video player setelah data video selesai dimuat
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
      // Cari video dengan tipe Trailer atau Teaser dari YouTube
      trailer = _videos.firstWhere(
        (v) => v.site == 'YouTube' && (v.type == 'Trailer' || v.type == 'Teaser'),
      );
    } catch (e) {
      // Fallback: ambil video pertama jika tidak spesifik tertulis Trailer/Teaser
      if (_videos.isNotEmpty && _videos.first.site == 'YouTube') {
        trailer = _videos.first;
      }
    }

    if (trailer != null && trailer.key.isNotEmpty) {
      setState(() {
        _ytController = YoutubePlayerController(
          initialVideoId: trailer!.key,
          flags: const YoutubePlayerFlags(
            autoPlay: false, // Set ke true jika ingin trailer otomatis berputar saat dibuka
            mute: false,
            forceHD: false,
          ),
        );
        _hasTrailer = true;
      });
    }
  }

  @override
  void deactivate() {
    // Pause player jika pengguna menavigasi keluar dari halaman
    _ytController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    // Bersihkan controller dari memori
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final series = _seriesDetails ?? widget.series;
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
                          imageUrl: series.backdropUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.secondaryBackground,
                            child: const Icon(Icons.tv),
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
                                imageUrl: series.posterUrl,
                                width: 120,
                                height: 180,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  width: 120,
                                  height: 180,
                                  color: AppColors.secondaryBackground,
                                  child: const Icon(Icons.tv),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    series.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        series.voteAverage.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (series.firstAirDate.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        series.firstAirDate,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
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
                          series.overview,
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // SEKSI TRAILER LANGSUNG DI APLIKASI
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
                                          color:
                                              AppColors.secondaryBackground,
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