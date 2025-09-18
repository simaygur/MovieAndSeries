import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_screen.dart'; // HomeScreen'in bulunduğu yeni dosyayı import et
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotPasswordEmailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotPasswordEmailController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      final ApiService apiService = ApiService();
      final Map<String, dynamic> response = await apiService.login(email, password);

      if (mounted) {
        if (response.containsKey('token') && response['token'] != null) {
          // userId veya id anahtarını kontrol et
          final int? userId = response['userId'] ?? response['id'];
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kullanıcı kimliği alınamadı!')),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giriş başarılı!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(authToken: response['token'], userId: userId),
            ),
          );
        } else {
          final String errorMessage = response['message'] ?? 'Giriş başarısız.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        final String errorMessage = e.toString().contains('401')
            ? 'Email veya şifre hatalı.'
            : e.toString().contains('SocketException')
                ? 'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.'
                : 'Bir hata oluştu: ${e.toString()}';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şifremi Unuttum'),
          content: TextField(
            controller: _forgotPasswordEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email adresinizi girin',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sıfırla'),
              onPressed: () {
                _sendPasswordResetRequest(_forgotPasswordEmailController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendPasswordResetRequest(String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli bir email adresi girin.')),
      );
      return;
    }

    try {
      await ApiService().forgotPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre sıfırlama talimatları e-posta adresinize gönderildi.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Giriş Yap'),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('Hesabın yok mu? Kayıt ol'),
            ),
            TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text('Şifremi Unuttum'),
            ),
          ],
        ),
      ),
    );
  }
}