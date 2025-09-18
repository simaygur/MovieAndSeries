
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'movie_detail_screen.dart';

class MoviesScreen extends StatefulWidget {
  final String authToken;
  final int userId;
  const MoviesScreen({Key? key, required this.authToken, required this.userId}) : super(key: key);

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late Future<List<dynamic>> _movies;
  late Future<List<dynamic>> _genres;
  String? _selectedGenre;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _genres = ApiService().fetchGenresFromMyApi(widget.authToken);
    _movies = ApiService().fetchMoviesFromMyApi(widget.authToken);
  }

  void _onGenreSelected(String? newGenreId) {
    setState(() {
      _selectedGenre = newGenreId;
      _searchController.clear();
      if (newGenreId != null) {
        _movies = ApiService().fetchMoviesByGenre(widget.authToken, newGenreId);
      } else {
        _movies = ApiService().fetchMoviesFromMyApi(widget.authToken);
      }
    });
  }
  
  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        // Eğer arama kutusu boşsa tüm filmleri yeniden yükle
        _movies = ApiService().fetchMoviesFromMyApi(widget.authToken);
      } else {
        // Tekil arama API'sini kullanarak hem filmleri hem de dizileri ara
        _movies = ApiService().searchMoviesAndSeries(widget.authToken, query).then((results) {
          // Gelen sonuçlar arasından sadece filmleri filtrele (item['title'] ile kontrol)
          final moviesOnly = results.where((item) => item['title'] != null).toList();
          return moviesOnly;
        });
      }
      _selectedGenre = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filmler'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                labelText: 'Film Ara',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: _genres,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Türler yüklenirken hata oluştu: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final genres = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _selectedGenre,
                    hint: const Text('Tür Seçiniz'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tüm Türler'),
                      ),
                      ...genres.map((genre) {
                        return DropdownMenuItem(
                          value: genre['id']?.toString(),
                          child: Text(genre['name']),
                        );
                      }).toList(),
                    ],
                    onChanged: _onGenreSelected,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _movies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Film bulunamadı.'));
                  }
                  final movies = snapshot.data!;
                  return ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      final String? posterPath = movie['poster_path'];
                      final String imageUrl = posterPath != null
                          ? ApiService().getImageUrl(posterPath)
                          : 'https://via.placeholder.com/150x225?text=Afiş+Yok';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailScreen(movie: movie, authToken: widget.authToken, userId: widget.userId),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    imageUrl,
                                    width: 100,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie['name'] ?? movie['title'] ?? 'Başlık Yok',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'IMDB Puanı: ${movie['vote_average']?.toStringAsFixed(1) ?? 'N/A'}',
                                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        movie['overview'] ?? 'Film özeti mevcut değil.',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('Film bulunamadı.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}