import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _displayController = TextEditingController();
  String? _phone;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _auth.currentUser();
    if (!mounted) return;
    setState(() {
      _phone = user?.phone;
      _displayController.text = user?.displayName ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _displayController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_phone == null) return;
    setState(() {
      _loading = true;
    });
    await _auth.updateProfile(phone: _phone!, displayName: _displayController.text.trim());
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(controller: _displayController, decoration: const InputDecoration(labelText: 'Display Name')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ]),
      ),
    );
  }
}
