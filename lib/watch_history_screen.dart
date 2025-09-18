import 'package:flutter/material.dart';
import 'api_service.dart';
class WatchHistoryScreen extends StatefulWidget {
  final String authToken;
  final int userId;
  const WatchHistoryScreen({Key? key, required this.authToken, required this.userId}) : super(key: key);

  @override
  State<WatchHistoryScreen> createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  // İzleme geçmişi verisi için Future tanımlaması
  late Future<List<dynamic>> _watchHistory;

  @override
  void initState() {
    super.initState();
    // API'den izleme geçmişini çek
    _watchHistory = ApiService().fetchWatchHistory(widget.authToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İzleme Geçmişi'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _watchHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(child: Text('İzleme geçmişiniz boş.'));
            }
            final history = snapshot.data!;
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final String? posterPath = item['poster_path'];
                final String imageUrl = posterPath != null
                    ? ApiService().getImageUrl(posterPath)
                    : 'https://via.placeholder.com/150x225?text=Afiş+Yok';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  elevation: 5,
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
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? item['name'] ?? 'Başlık Yok',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'İzleme Tarihi: ${item['watched_at']}',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('İzleme geçmişi bulunamadı.'));
          }
        },
      ),
    );
  }
}
