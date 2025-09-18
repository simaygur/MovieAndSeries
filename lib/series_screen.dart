import 'package:flutter/material.dart';
import 'api_service.dart';
import 'series_detail_screen.dart'; // Dizinin bölümleri için yeni sayfa

class SeriesScreen extends StatefulWidget {
  final String authToken;
  final int userId;
  const SeriesScreen({Key? key, required this.authToken, required this.userId}) : super(key: key);

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  late Future<List<dynamic>> _series;
  late Future<List<dynamic>> _genres;
  String? _selectedGenre;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _genres = ApiService().fetchGenresFromMyApi(widget.authToken);
    _series = ApiService().fetchSeriesFromMyApi(widget.authToken);
  }

  void _onGenreSelected(String? newGenreId) {
    setState(() {
      _selectedGenre = newGenreId;
      _searchController.clear();
      if (newGenreId != null) {
        _series = ApiService().fetchSeriesByGenre(widget.authToken, newGenreId);
      } else {
        _series = ApiService().fetchSeriesFromMyApi(widget.authToken);
      }
    });
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        // Eğer arama kutusu boşsa tüm dizileri yeniden yükle
        _series = ApiService().fetchSeriesFromMyApi(widget.authToken);
      } else {
        // Tekil arama API'sini kullanarak hem filmleri hem de dizileri ara
        _series = ApiService().searchMoviesAndSeries(widget.authToken, query).then((results) {
          // Gelen sonuçlar arasından sadece dizileri filtrele (item['title'] == null veya 'name' ile kontrol)
          final seriesOnly = results.where((item) => item['title'] == null).toList();
          return seriesOnly;
        });
      }
      _selectedGenre = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diziler'),
      ),
      body: Column(
          children: [
      Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onSubmitted: _onSearch,
        decoration: InputDecoration(
          labelText: 'Dizi Ara',
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
    future: _series,
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
    return Center(child: Text('Hata: ${snapshot.error}'));
    } else if (snapshot.hasData) {
    if (snapshot.data == null || snapshot.data!.isEmpty) {
    return const Center(child: Text('Dizi bulunamadı.'));
    }
    final series = snapshot.data!;
    return ListView.builder(
    itemCount: series.length,
    itemBuilder: (context, index) {
    final show = series[index];
    final String? posterPath = show['poster_path'];
    final String imageUrl = posterPath != null
    ? ApiService().getImageUrl(posterPath)
        : 'https://via.placeholder.com/150x225?text=Afiş+Yok';

    return GestureDetector(
    onTap: () {
    // Dizinin bölümlerini gösterecek yeni bir sayfaya yönlendir
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => SeriesDetailScreen(series: show, authToken: widget.authToken),
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
    show['name'] ?? 'Başlık Yok',
    style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    ),
    const SizedBox(height: 5),
    Text(
    'IMDB Puanı: ${show['vote_average']?.toStringAsFixed(1) ?? 'N/A'}',
    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
    ),
    const SizedBox(height: 5),
    Text(
    show['overview'] ?? 'Dizi özeti mevcut değil.',
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
    return const Center(child: Text('Dizi bulunamadı.'));
    }
    },
    ),
    )],
    ),
    );
    }
}