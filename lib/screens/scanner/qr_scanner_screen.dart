import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/qr_video_map.dart';
import '../../app/routes.dart';
import '../../services/qr_scanning_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final TextEditingController _controller = TextEditingController();
  final QrScanningService _service = QrScanningService();
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null) return;

    _handled = true;
    _service.stop();

    final videoId = qrVideoMap[code];
    if (videoId != null) {
      Navigator.of(context).pushNamed(Routes.videoPlayer, arguments: videoId).then((_) {
        // allow scanning again when returning
        _handled = false;
        _service.start();
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Unknown QR'),
          content: const Text('The scanned QR does not map to any video.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))
          ],
        ),
      ).then((_) {
        _handled = false;
        _service.start();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scan QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: MobileScanner(
                controller: _service.controller,
                onDetect: _onDetect,
                errorBuilder: (BuildContext context, MobileScannerException error) {
                  return AlertDialog(
                    title: const Text('Camera permission'),
                    content: const Text(
                        'Camera permission was denied. QR scanning requires camera access.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'))
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
