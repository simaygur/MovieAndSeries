import 'package:flutter/material.dart';
class ProfileScreen extends StatefulWidget {
  final String authToken;
  final int userId;
  const ProfileScreen({Key? key, required this.authToken, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // TODO: Kullanıcı bilgilerini çekmek için API çağrısı eklenecek
  // TODO: Bilgileri düzenleme mantığı eklenecek
  // TODO: Çıkış yapma mantığı eklenecek

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Profil Sayfası',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: null, // Çıkış yapma fonksiyonu buraya gelecek
              child: Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
