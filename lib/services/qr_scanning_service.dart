import 'package:mobile_scanner/mobile_scanner.dart';

/// A thin wrapper around `MobileScannerController` so screens don't depend
/// directly on the package API. The service is responsible only for
/// controlling the camera and stopping the scanner on demand.
class QrScanningService {
  final MobileScannerController controller;

  QrScanningService({MobileScannerController? controller}) : controller = controller ?? MobileScannerController();

  void start() => controller.start();

  void stop() => controller.stop();

  void dispose() => controller.dispose();
}
