import 'package:flutter/material.dart';
import '../../utils/validators.dart';
import '../../services/mock_otp_service.dart';
import '../../app/routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final phone = _phoneController.text.trim();
    if (!isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid phone number')));
      return;
    }
    setState(() {
      _loading = true;
    });
    final code = await MockOtpService.instance.requestOtp(phone);
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    // Show mock OTP for development (mock service). Do not log in production.
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Signup'),
        content: Text('You are creating new account with: $phone'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushNamed(Routes.createPassword, arguments: phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Mobile number'), keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _requestOtp, child: _loading ? const CircularProgressIndicator() : const Text('Create Account')),
        ]),
      ),
    );
  }
}

