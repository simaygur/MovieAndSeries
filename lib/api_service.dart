import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {

  Future<void> addOrUpdateWatchHistory({
    required String authToken,
    required int episodeId,
    required int userId,
    required int remainingTime,
  }) async {
    final body = {
      'EpisodeId': episodeId,
      'UserId': userId,
      'RemainingTime': remainingTime,
    };
    final response = await http.post(
      Uri.parse('$watchHistoryBaseUrl'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );
    if (response.statusCode != 201) {
      throw Exception('İzleme geçmişi güncellenemedi: ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$authBaseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Giriş başarısız: ${response.statusCode}');
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$authBaseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw Exception('Şifre sıfırlama başarısız: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchSeriesEpisodes(String authToken, String seriesId) async {
    final response = await http.get(
      Uri.parse('$episodesBaseUrl/by-series/$seriesId'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data;
      if (data is Map && data.containsKey('episodes')) return data['episodes'];
      throw Exception('API yanıt formatı geçersiz veya "episodes" anahtarı bulunamadı.');
    } else {
      throw Exception('Dizi bölümleri yüklenemedi: ${response.statusCode}');
    }
  }
  Future<List<dynamic>> fetchMoviesFromMyApi(String authToken) async {
    final response = await http.get(
      Uri.parse(moviesBaseUrl),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data;
      if (data is Map && data.containsKey('movies')) return data['movies'];
      throw Exception('API yanıt formatı geçersiz veya "movies" anahtarı bulunamadı.');
    } else {
      throw Exception('Veriler yüklenemedi: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchSeriesFromMyApi(String authToken) async {
    final response = await http.get(
      Uri.parse(seriesBaseUrl),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data;
      if (data is Map && data.containsKey('series')) return data['series'];
      throw Exception('API yanıt formatı geçersiz veya "series" anahtarı bulunamadı.');
    } else {
      throw Exception('Veriler yüklenemedi: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchFavorites(String authToken, {required int userId}) async {
    try {
      final url = '$favoritesBaseUrl/$userId';
      print('\n=== Favoriler API Çağrısı ===');
      print('URL: $url');
      print('Token: $authToken');
      print('UserId: $userId');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json'
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Bulunan favori sayısı: ${data is List ? data.length : "bilinmiyor"}');
        return data;
      } else if (response.statusCode == 404) {
        print('Kullanıcı için favori bulunamadı');
        return [];
      } else {
        throw Exception('Favoriler yüklenemedi: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('\n=== Hata Detayları ===');
      print('Hata: $e');
      print('Stack Trace:\n$stackTrace');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchWatchHistory(String authToken) async {
    final response = await http.get(
      Uri.parse('$watchHistoryBaseUrl/12'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data;
      throw Exception('API yanıt formatı geçersiz veya izleme geçmişi verisi bulunamadı.');
    } else {
      throw Exception('İzleme geçmişi yüklenemedi: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchGenresFromMyApi(String authToken) async {
    final response = await http.get(
      Uri.parse(genresBaseUrl),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data;
      throw Exception('API yanıt formatı geçersiz veya tür verisi bulunamadı.');
    } else {
      throw Exception('Türler yüklenemedi: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchMoviesByGenre(String authToken, String genreId) async {
    final response = await http.get(
      Uri.parse('$moviesBaseUrl/by-genre/$genreId'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data;
      if (data is Map && data.containsKey('movies')) return data['movies'];
      throw Exception('API yanıt formatı geçersiz veya "movies" anahtarı bulunamadı.');
    } else {
      throw Exception('Türe göre filmler yüklenemedi: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchSeriesByGenre(String authToken, String genreId) async {
    final response = await http.get(
      Uri.parse('$seriesBaseUrl/by-genre/$genreId'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data;
      if (data is Map && data.containsKey('series')) return data['series'];
      throw Exception('API yanıt formatı geçersiz veya "series" anahtarı bulunamadı.');
    } else {
      throw Exception('Türe göre diziler yüklenemedi: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchEpisodesForMovie(String authToken, dynamic movieId) async {
    try {
      // API URL'sini oluştur
      final apiUrl = '$episodesBaseUrl/by-movie/$movieId';
      print('\n=== Bölüm Çağrısı Detayları ===');
      print('Request URL: $apiUrl');
      print('MovieId Type: ${movieId.runtimeType}');
      print('MovieId Value: $movieId');
      print('Token: $authToken');
      
      // API çağrısı
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json'
        },
      );
      
      print('\n=== API Yanıt Detayları ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          print('Liste olarak ${data.length} bölüm bulundu');
          return data;
        }
        if (data is Map && data.containsKey('episodes')) {
          print('Map içinde ${data['episodes'].length} bölüm bulundu');
          return data['episodes'];
        }
        print('HATA: Yanıt formatı geçersiz: $data');
        throw Exception('API yanıt formatı geçersiz');
      } else if (response.statusCode == 404) {
        print('UYARI: Bu film için bölüm bulunamadı (404)');
        return [];
      } else {
        print('HATA: Beklenmeyen status code: ${response.statusCode}');
        throw Exception('Bölümler yüklenemedi: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('\n=== Hata Detayları ===');
      print('Hata: $e');
      print('Stack Trace:\n$stackTrace');
      rethrow;
    }
  }

  Future<List<dynamic>> searchMoviesAndSeries(String authToken, String query) async {
    final response = await http.get(
      Uri.parse('$searchBaseUrl?query=$query'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) return data;
      throw Exception('API yanıt formatı geçersiz.');
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Arama başarısız oldu: ${response.statusCode}');
    }
  }
  final String _baseUrl = Platform.isAndroid ? "http://10.0.2.2:5077" : "http://localhost:5077";
  late final String moviesBaseUrl = '$_baseUrl/api/movies';
  late final String seriesBaseUrl = '$_baseUrl/api/series';
  late final String genresBaseUrl = '$_baseUrl/api/genres';
  late final String authBaseUrl = '$_baseUrl/api/auth';
  late final String searchBaseUrl = '$_baseUrl/api/search';
  late final String watchHistoryBaseUrl = '$_baseUrl/api/WatchHistory';
  late final String favoritesBaseUrl = '$_baseUrl/api/favorites';
  late final String episodesBaseUrl = '$_baseUrl/api/episodes';

  // ...tüm fonksiyonlar burada olacak...

  String getImageUrl(String posterPath) {
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  Future<void> addToFavorites(String authToken, int userId, int movieId) async {
    final response = await http.post(
      Uri.parse('$favoritesBaseUrl'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'UserId': userId,
        'MovieId': movieId,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Favorilere eklenemedi: ${response.statusCode}');
    }
  }

  Future<void> removeFromFavorites(String authToken, int userId, int movieId) async {
    final response = await http.delete(
      Uri.parse('$favoritesBaseUrl/$userId/$movieId'),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Favorilerden kaldırılamadı: ${response.statusCode}');
    }
  }

  Future<bool> checkIfFavorite(String authToken, int userId, int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$favoritesBaseUrl/$userId/check/$movieId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception('Favori durumu kontrol edilemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Favori kontrolü sırasında hata: $e');
      return false;
    }
  }
}