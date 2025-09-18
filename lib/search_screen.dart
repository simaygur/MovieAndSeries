import 'package:flutter/material.dart';
class SearchScreen extends StatefulWidget {
  final Map<String, dynamic>? movie;
  final String? authToken;
  final int? userId;
  const SearchScreen({Key? key, this.movie, this.authToken, this.userId}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // TODO: Search ekranı için gerekli değişkenler ve metotlar buraya eklenecek.

  @override
  Widget build(BuildContext context) {
    // TODO: Search ekranı arayüzü buraya eklenecek.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arama'),
      ),
      body: const Center(
        child: Text('Arama ekranı henüz uygulanmadı.'),
      ),
    );
  }
}