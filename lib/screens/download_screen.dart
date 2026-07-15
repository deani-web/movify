import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/download_service.dart';
import '../utils/colors.dart';
import 'detail_screen.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  final DownloadService _downloadService = DownloadService();
  List<Movie> _downloadedMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    final list = await _downloadService.getDownloadedMovies();
    setState(() {
      _downloadedMovies = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Downloads', style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.dark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _downloadedMovies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_for_offline_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada film yang di-download',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _downloadedMovies.length,
                  itemBuilder: (context, index) {
                    final movie = _downloadedMovies[index];
                    return Card(
                      color: AppColors.secondaryBackground,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(movie.posterUrl, width: 50, fit: BoxFit.cover),
                        ),
                        title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Tersedia Offline', style: TextStyle(color: Colors.green)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _downloadService.removeFromDownloads(movie.id);
                            _loadDownloads();
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetailScreen(movie: movie)),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}