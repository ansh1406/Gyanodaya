import 'package:flutter/material.dart';
import '../../services/mock_otp_service.dart';
import '../../app/routes.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter OTP')));
      return;
    }
    setState(() {
      _loading = true;
    });
    final ok = await MockOtpService.instance.verifyOtp(widget.phone, otp);
    if (!mounted) return;
    setState(() {
      _loading = false;
    });
    if (ok) {
      Navigator.of(context).pushNamed(Routes.createPassword, arguments: widget.phone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect OTP')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('OTP was sent to ${widget.phone}'),
          const SizedBox(height: 12),
          TextField(controller: _otpController, decoration: const InputDecoration(labelText: 'Enter OTP'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _verify, child: _loading ? const CircularProgressIndicator() : const Text('Verify')),
        ]),
      ),
    );
  }
}
