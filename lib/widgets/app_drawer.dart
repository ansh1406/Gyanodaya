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
  String? _name;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _auth.currentUser();
    setState(() {
      _phone = user?.phone;
      _name = user?.displayName;
      if(_name == "") _name = null;
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
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Image.asset('assets/icons/icon.png', width: 100, height: 100),
                    const SizedBox(height: 8),
                    const Text(
                      'Gyanodaya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_name != null)
                  Text(
                    " Hi, $_name !",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (_phone != null)
                  Text(
                    " $_phone",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(Routes.home);
            },
          ),
          if (_phone == null) ...[
            ListTile(
              leading: const Icon(Icons.login_outlined),
              title: const Text('Login'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.login);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text('Signup'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.signup);
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Profile'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(Routes.profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        ],
      ),
    );
  }
}
