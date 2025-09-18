import 'package:flutter/material.dart';
import 'api_service.dart';

class SeriesDetailScreen extends StatefulWidget {
  final Map<String, dynamic> series;
  final String authToken;
  const SeriesDetailScreen({super.key, required this.series, required this.authToken});

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  late Future<List<dynamic>> _episodes;

  @override
  void initState() {
    super.initState();
    _episodes = ApiService().fetchSeriesEpisodes(widget.authToken, widget.series['id'].toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.series['name']} Bölümleri'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _episodes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Center(child: Text('Bölüm verileri boş geldi.'));
            }
            final episodes = snapshot.data!;
            return ListView.builder(
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  elevation: 5,
                  child: ListTile(
                    leading: const Icon(Icons.tv_rounded),
                    title: Text(episode['episode_name'] ?? 'Bölüm Başlığı Yok'),
                    subtitle: Text('Sezon ${episode['season_number']} - Bölüm ${episode['episode_number']}'),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Bölüm bulunamadı.'));
          }
        },
      ),
    );
  }
}
