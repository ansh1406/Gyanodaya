import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _auth = AuthService();
  String? _phone;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _auth.currentUser();
    setState(() {
      _phone = user?.phone;
    });
  }

  Future<void> _logout() async {
    await _auth.logout();
    setState(() {
      _phone = null;
    });
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(child: Text('Gyanodaya')),
          ListTile(
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(Routes.home);
            },
          ),
          if (_phone == null) ...[
            ListTile(
              title: const Text('Login'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.login);
              },
            ),
            ListTile(
              title: const Text('Signup'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.signup);
              },
            ),
          ] else ...[
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.profile);
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ]
        ],
      ),
    );
  }
}


