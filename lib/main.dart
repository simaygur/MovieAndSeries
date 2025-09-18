// main.dart

import 'package:flutter/material.dart';
import 'login_screen.dart'; // Başlangıç ekranınızı import edin

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film & Dizi Takip Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false, // Debug banner'ı kaldırır
    );
  }
}