import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Assuming you have an ApiService class in a separate file.
// You need to instantiate it to use its methods.
// For simplicity in this file, we'll place the API call logic directly.

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedDate;
  int? _selectedGender;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    const String apiUrl = 'http://localhost:5077/api/auth/register';

    final Map<String, dynamic> registerData = {
      'email': _emailController.text,
      'password': _passwordController.text,
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'phone': _phoneController.text,
      'gender': _selectedGender,
      'birthDate': _selectedDate?.toIso8601String(),
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(registerData),
      ).timeout(const Duration(seconds: 10));

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kullanıcı başarıyla kaydedildi!')),
          );
        } else {
          final String errorMessage = response.body.isNotEmpty ? response.body : 'Bilinmeyen bir hata oluştu.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $errorMessage')),
          );
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API zaman aşımına uğradı. Lütfen daha sonra tekrar deneyin.')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Ad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen adınızı girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Soyad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen soyadınızı girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen email adresinizi girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen telefon numaranızı girin';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir şifre belirleyin';
                  }
                  // Şifre uzunluğunu kontrol etme
                  if (value.length < 5) {
                    return 'Şifre en az 5 karakter olmalıdır.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Cinsiyet Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Cinsiyet'),
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Erkek')),
                  DropdownMenuItem(value: 2, child: Text('Kadın')),
                ],
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Lütfen cinsiyet seçin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Doğum Tarihi Seçici
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text(
                  _selectedDate == null
                      ? 'Doğum Tarihi Seç'
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _registerUser,
                child: const Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
