import 'package:flutter/material.dart';
import 'api_service.dart';

class FavoritesScreen extends StatefulWidget {
  final String authToken;
  final int userId;
  const FavoritesScreen({super.key, required this.authToken, required this.userId});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<dynamic>> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = ApiService().fetchFavorites(widget.authToken, userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoriler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _favorites = ApiService().fetchFavorites(widget.authToken, userId: widget.userId);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _favorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hata: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _favorites = ApiService().fetchFavorites(widget.authToken, userId: widget.userId);
                      });
                    },
                    child: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Favorileriniz boş',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            final favorites = snapshot.data!;
            return ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                final bool isMovie = item['movieName'] != null;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  elevation: 5,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMovie ? Colors.blue[100] : Colors.purple[100],
                      child: Icon(
                        isMovie ? Icons.movie : Icons.tv,
                        color: isMovie ? Colors.blue[900] : Colors.purple[900],
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item['movieName'] ?? item['seriesName'] ?? 'Başlık Yok',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Favoriler yüklenemedi.'));
          }
        },
      ),
    );
  }
}
