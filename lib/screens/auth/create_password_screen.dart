import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../app/routes.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String phone;
  const CreatePasswordScreen({super.key, required this.phone});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final p = _passwordController.text;
    final c = _confirmController.text;
    if (p.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }
    if (p != c) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() {
      _loading = true;
    });
    final ok = await _auth.register(phone: widget.phone, password: p);
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    if (ok) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account already exists')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Create a password for ${widget.phone}'),
          const SizedBox(height: 12),
          TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 12),
          TextField(controller: _confirmController, decoration: const InputDecoration(labelText: 'Confirm Password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _create, child: _loading ? const CircularProgressIndicator() : const Text('Create Account')),
        ]),
      ),
    );
  }
}
