import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../app/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gyanodaya')),
      drawer: const AppDrawer(),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.qrScanner),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('SCAN QR'),
          ),
        ),
      ),
    );
  }
}
