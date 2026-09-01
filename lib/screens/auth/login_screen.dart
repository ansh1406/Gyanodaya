import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../app/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text;
    setState(() {
      _loading = true;
    });
    final ok = await _auth.login(phone: phone, password: pass);
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    if (ok) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Mobile number'), keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _login, child: _loading ? const CircularProgressIndicator() : const Text('Login')),
        ]),
      ),
    );
  }
}
