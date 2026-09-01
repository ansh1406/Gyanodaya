import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scanner/qr_scanner_screen.dart';
import '../screens/video/video_player_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/create_password_screen.dart';
import '../screens/profile/profile_screen.dart';

class Routes {
  static const splash = '/';
  static const home = '/home';
  static const qrScanner = '/scanner';
  static const videoPlayer = '/video';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const createPassword = '/create-password';
  static const profile = '/profile';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case qrScanner:
        return MaterialPageRoute(builder: (_) => const QrScannerScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case otp:
        final phoneArg = settings.arguments;
        if (phoneArg is String) return MaterialPageRoute(builder: (_) => OtpScreen(phone: phoneArg));
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Missing phone'))));
      case createPassword:
        final phoneArg2 = settings.arguments;
        if (phoneArg2 is String) return MaterialPageRoute(builder: (_) => CreatePasswordScreen(phone: phoneArg2));
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Missing phone'))));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case videoPlayer:
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(videoId: args));
        }
        return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Center(child: Text('Missing videoId'))));
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Center(child: Text('Unknown route'))));
    }
  }
}
