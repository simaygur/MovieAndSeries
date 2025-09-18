import 'package:flutter/material.dart';
import 'api_service.dart';


class MovieDetailScreen extends StatefulWidget {
  final Map<String, dynamic> movie;
  final String authToken;
  final int userId; // Kullanıcı kimliği
  const MovieDetailScreen({super.key, required this.movie, required this.authToken, required this.userId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Future<void> saveWatchHistory() async {
    try {
      if (selectedEpisodeIndex == null || episodes.isEmpty) return;
      final episode = episodes[selectedEpisodeIndex!];
      final episodeId = episode['id'] ?? episode['episodeId'] ?? episode['EpisodeId'];
      if (episodeId == null) return;
      await ApiService().addOrUpdateWatchHistory(
        authToken: widget.authToken,
        episodeId: episodeId,
        userId: widget.userId,
        remainingTime: watchedMinutes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İzleme geçmişi kaydedilemedi: $e')),
        );
      }
    }
  }
  // Tekrarlanan tanımlar kaldırıldı
    late TextEditingController notesController;
    late TextEditingController minuteController;
    bool isFavorite = false;
    bool isFinished = false;
    int watchedMinutes = 0;
    int? selectedEpisodeIndex;
    List<dynamic> episodes = [];
    bool episodesLoading = false;
    bool isLoadingFavorite = false;

    Future<void> checkFavoriteStatus() async {
      if (isLoadingFavorite) return;
      try {
        setState(() { isLoadingFavorite = true; });
        final movieId = widget.movie['id'] ?? widget.movie['movieId'] ?? widget.movie['movieID'];
        if (movieId == null) return;
        
        final result = await ApiService().checkIfFavorite(
          widget.authToken,
          widget.userId,
          movieId,
        );
        
        if (mounted) {
          setState(() {
            isFavorite = result;
            isLoadingFavorite = false;
          });
        }
      } catch (e) {
        print('Favori durumu kontrol edilemedi: $e');
        if (mounted) {
          setState(() { isLoadingFavorite = false; });
        }
      }
    }

    Future<void> toggleFavorite() async {
      if (isLoadingFavorite) return;
      try {
        setState(() { isLoadingFavorite = true; });
        final movieId = widget.movie['id'] ?? widget.movie['movieId'] ?? widget.movie['movieID'];
        if (movieId == null) {
          throw Exception('Film ID\'si bulunamadı');
        }
        
        print('\n=== FAVORİ İŞLEMİ BAŞLATILIYOR ===');
        print('Film ID: $movieId');
        print('User ID: ${widget.userId}');
        print('Mevcut favori durumu: $isFavorite');

        print('\nAPI çağrısı yapılıyor...');
        if (isFavorite) {
          print('Favorilerden kaldırılıyor...');
          await ApiService().removeFromFavorites(
            widget.authToken,
            widget.userId,
            movieId,
          );
          print('Favorilerden kaldırma başarılı!');
        } else {
          print('Favorilere ekleniyor...');
          await ApiService().addToFavorites(
            widget.authToken,
            widget.userId,
            movieId,
          );
          print('Favorilere ekleme başarılı!');
        }

        if (mounted) {
          setState(() {
            isFavorite = !isFavorite;
            isLoadingFavorite = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFavorite ? 'Favorilere eklendi' : 'Favorilerden kaldırıldı'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('Favori işlemi başarısız: $e');
        if (mounted) {
          setState(() { isLoadingFavorite = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Favori işlemi başarısız: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }

    @override
    void initState() {
      super.initState();
      notesController = TextEditingController();
      minuteController = TextEditingController(text: watchedMinutes.toString());
      // Favori durumunu kontrol et
      checkFavoriteStatus();
      minuteController.addListener(() {
        final val = minuteController.text;
        setState(() {
          watchedMinutes = int.tryParse(val) ?? 0;
        });
        saveWatchHistory();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final movie = widget.movie;
        print('Detaylı film verisi:');
        movie.forEach((key, value) {
          print('$key: $value');
        });
        
        if (movie['episodes'] is List && (movie['episodes'] as List).isNotEmpty) {
          print('Film nesnesinde bölümler zaten var');
          setState(() {
            episodes = List.from(movie['episodes']);
            selectedEpisodeIndex = 0;
          });
        } else if (movie['id'] != null || movie['movieId'] != null || movie['movieID'] != null) {
          final movieId = movie['id'] ?? movie['movieId'] ?? movie['movieID'];
          print('Film ID bulundu: $movieId (Tipi: ${movieId.runtimeType})');
          fetchEpisodesFromApi(movieId);
        } else {
          print('HATA: Film ID\'si bulunamadı!');
          print('Mevcut alanlar: ${movie.keys.join(', ')}');
        }
      });
    }

    void fetchEpisodesFromApi(dynamic movieId) async {
      setState(() { episodesLoading = true; });
      try {
        // MovieId'nin tipini ve değerini kontrol edelim
        print('MovieId type: ${movieId.runtimeType}');
        print('MovieId value: $movieId');
        
        // MovieId'yi integer'a çevirmeyi deneyelim
        int parsedMovieId;
        if (movieId is String) {
          parsedMovieId = int.parse(movieId);
        } else {
          parsedMovieId = movieId as int;
        }
        
        print('Fetching episodes for parsed movieId: $parsedMovieId');
        final fetched = await ApiService().fetchEpisodesForMovie(widget.authToken, parsedMovieId);
        print('Fetched episodes: $fetched');
        
        setState(() {
          episodes = fetched;
          selectedEpisodeIndex = fetched.isNotEmpty ? 0 : null;
          episodesLoading = false;
        });
      } catch (e, stackTrace) {
        print('Error fetching episodes: $e');
        print('Stack trace: $stackTrace');
        setState(() { 
          episodesLoading = false;
          episodes = [];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bölümler yüklenemedi: $e')),
          );
        }
      }
    }

    @override
    void dispose() {
      notesController.dispose();
      minuteController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      print('MovieDetailScreen movie: \\n${widget.movie}');
      final movie = widget.movie;
      if (movie.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Film Detay')),
          body: const Center(child: Text('Film verisi bulunamadı.')),
        );
      }
      final String? posterPath = movie['poster_path'];
      final String imageUrl = posterPath != null
          ? 'https://image.tmdb.org/t/p/w500$posterPath'
          : 'https://via.placeholder.com/150x225?text=Afiş+Yok';
      final String title = movie['title'] ?? movie['name'] ?? 'Başlık Yok';
      final String overview = movie['overview'] ?? 'Açıklama yok.';

      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: isLoadingFavorite
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
              onPressed: toggleFavorite,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  imageUrl,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                overview,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text('Notlarım:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Buraya notunuzu yazın...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isFinished,
                    onChanged: (val) {
                      setState(() {
                        isFinished = val ?? false;
                      });
                    },
                  ),
                  const Text('Tamamlandı olarak işaretle'),
                ],
              ),
              const SizedBox(height: 16),
              const Text('İzleme Dakikası:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: minuteController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'dk',
                  ),
                  onChanged: (val) {
                    setState(() {
                      watchedMinutes = int.tryParse(val) ?? 0;
                    });
                    saveWatchHistory();
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (episodesLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (episodes.isNotEmpty) ...[
                const Text('Bölüm Seç:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<int>(
                  value: selectedEpisodeIndex,
                  hint: const Text('Bölüm seç'),
                  items: List.generate(episodes.length, (index) {
                    final ep = episodes[index];
                    final epName = ep['name'] ?? 'Bölüm ${index + 1}';
                    return DropdownMenuItem(
                      value: index,
                      child: Text(epName),
                    );
                  }),
                  onChanged: (val) {
                    setState(() {
                      selectedEpisodeIndex = val;
                    });
                    saveWatchHistory();
                  },
                ),
                const SizedBox(height: 16),
                if (selectedEpisodeIndex != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Seçili Bölüm: ${episodes[selectedEpisodeIndex!]['name'] ?? 'Bölüm ${selectedEpisodeIndex! + 1}'}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                const Text('Tüm Bölümler:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    final ep = episodes[index];
                    final epName = ep['name'] ?? 'Bölüm ${index + 1}';
                    final isSelected = selectedEpisodeIndex == index;
                    return ListTile(
                      title: Text(
                        epName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue : null,
                        ),
                      ),
                      selected: isSelected,
                      tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                      onTap: () {
                        setState(() {
                          selectedEpisodeIndex = index;
                        });
                      },
                    );
                  },
                ),
              ]
              else if (!episodesLoading && episodes.isEmpty) ...[
                const Text('Bölüm bulunamadı.', style: TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      );
    }
  }