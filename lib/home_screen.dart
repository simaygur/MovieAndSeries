// home_screen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'api_service.dart';
import 'movie_detail_screen.dart';
import 'series_detail_screen.dart';
import 'movies_screen.dart';
import 'series_screen.dart';
import 'search_screen.dart'; // Bu satırı kontrol edin!
import 'watch_history_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String authToken;
  final int userId;
  const HomeScreen({super.key, required this.authToken, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MainContentScreen(authToken: widget.authToken, userId: widget.userId),
      MoviesScreen(authToken: widget.authToken, userId: widget.userId),
      SeriesScreen(authToken: widget.authToken, userId: widget.userId),
      SearchScreen(authToken: widget.authToken, userId: widget.userId),
      WatchHistoryScreen(authToken: widget.authToken, userId: widget.userId),
      FavoritesScreen(authToken: widget.authToken, userId: widget.userId),
      ProfileScreen(authToken: widget.authToken, userId: widget.userId),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Filmler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'Diziler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Ara',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Geçmiş',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}


class MainContentScreen extends StatefulWidget {
  final String authToken;
  final int userId;
  const MainContentScreen({Key? key, required this.authToken, required this.userId}) : super(key: key);

  @override
  State<MainContentScreen> createState() => _MainContentScreenState();
}

class _MainContentScreenState extends State<MainContentScreen> {
  late Future<List<dynamic>> _trendingItems;
  late Future<List<dynamic>> _watchHistory;
  late Future<List<dynamic>> _popularMovies;
  late Future<List<dynamic>> _popularSeries;

  @override
  void initState() {
    super.initState();
    _trendingItems = _fetchTrendingItems();
    _watchHistory = ApiService().fetchWatchHistory(widget.authToken);
    _popularMovies = ApiService().fetchMoviesFromMyApi(widget.authToken);
    _popularSeries = ApiService().fetchSeriesFromMyApi(widget.authToken);
  }

  Future<List<dynamic>> _fetchTrendingItems() async {
    final movies = await ApiService().fetchMoviesFromMyApi(widget.authToken);
    final series = await ApiService().fetchSeriesFromMyApi(widget.authToken);
    return [...movies, ...series];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<dynamic>>(
              future: _trendingItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data != null) {
                  final items = snapshot.data!;
                  return CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: false,
                      aspectRatio: 16 / 9,
                      viewportFraction: 1.0,
                      height: MediaQuery.of(context).size.height * 0.4,
                    ),
                    items: items.map((item) {
                      final String? posterPath = item['poster_path'];
                      final String imageUrl = posterPath != null
                          ? ApiService().getImageUrl(posterPath)
                          : 'https://via.placeholder.com/150x225?text=Afiş+Yok';
                      
                      final String title = item['title'] ?? item['name'] ?? 'Başlık Yok';

                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              if (item['title'] != null) {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: item, authToken: widget.authToken, userId: widget.userId)));
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SeriesDetailScreen(series: item, authToken: widget.authToken)));
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(horizontal: 0.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                  },
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return const Center(child: Text('Trend içerik bulunamadı.'));
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'İzlemeye Devam Et',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            _buildHorizontalList('İzleme geçmişi çekilirken hata oluştu.', _watchHistory),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Popüler Filmler',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            _buildHorizontalList('Popüler filmler çekilirken hata oluştu.', _popularMovies),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Popüler Diziler',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            _buildHorizontalList('Popüler diziler çekilirken hata oluştu.', _popularSeries),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(String errorMessage, Future<List<dynamic>> future) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data != null) {
          final items = snapshot.data!;
          return SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final String? posterPath = item['poster_path'];
                final String imageUrl = posterPath != null
                    ? ApiService().getImageUrl(posterPath)
                    : 'https://via.placeholder.com/150x225?text=Afiş+Yok';
                
                final String title = item['title'] ?? item['name'] ?? 'Başlık Yok';

                return GestureDetector(
                  onTap: () {
                    if (item['title'] != null) { // Film
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: item, authToken: widget.authToken, userId: widget.userId)));
                    } else { // Dizi
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SeriesDetailScreen(series: item, authToken: widget.authToken)));
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 10.0),
                    width: 150,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            imageUrl,
                            width: 150,
                            height: 225,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 150,
                                height: 225,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Center(child: Text(errorMessage));
        }
      },
    );
  }
}