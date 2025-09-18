// lib/watch_history_service.dart

import 'dart:async';

class WatchHistoryService {
  // İzleme geçmişini simüle eden bir liste
  final List<Map<String, dynamic>> _mockWatchHistory = [
    {
      'title': 'Başlangıç Filmi',
      'poster_path': '/y4w2aGf9K3T4w3E3B5B2C6C4F1C5F2C.jpg',
      'vote_average': 7.8,
      'overview': 'Bu, uygulamanızın izleme geçmişi için bir başlangıç filmi örneğidir.'
    },
    {
      'title': 'Örnek Film 2',
      'poster_path': '/xN4yH0J0V9N8W7S6S5S4S3S2D1G3D5D9.jpg',
      'vote_average': 8.2,
      'overview': 'İzleme geçmişi listesini doldurmak için başka bir örnek film.'
    },
    // Buraya daha fazla film ekleyebilirsiniz
  ];

  // İzleme geçmişini çeken fonksiyon
  Future<List<dynamic>> getWatchHistory() async {
    // Gerçek bir API çağrısını simüle etmek için 1 saniye bekler
    await Future.delayed(const Duration(seconds: 1));
    return _mockWatchHistory;
  }
}