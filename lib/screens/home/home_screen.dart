import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../app/routes.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  String? _name;
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _loadUser();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _auth.currentUser();
    if (mounted) {
      setState(() {
        _name = (user?.displayName?.isNotEmpty == true)
            ? user!.displayName
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    const navy = Color(0xFF1E293B);
    const subtleGray = Color(0xFF64748B);

    return Scaffold(
      appBar: AppBar(title: const Text('Gyanodaya')),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFEFF6FF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 28),

                      // ── Greeting ────────────────────────────────────────
                      Text(
                        _name != null ? 'Hi, $_name 👋' : 'Welcome 👋',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: navy,
                          letterSpacing: 0.1,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Hero heading ────────────────────────────────────
                      const Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: navy,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Gyanodaya',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: primary,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Illustration card ───────────────────────────────
                      Center(
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 340),
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha:0.10),
                                blurRadius: 30,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/icons/icon.png',
                            height: 180,
                            fit: BoxFit.contain,
                            semanticLabel: 'Gyanodaya — knowledge awakening',
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // ── Tagline ─────────────────────────────────────────
                      const Text(
                        'Learn. Explore. Grow.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: navy,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your journey towards knowledge starts here.\nDiscover engaging lessons and build your skills at your own pace.',
                        style: TextStyle(
                          fontSize: 15,
                          color: subtleGray,
                          height: 1.55,
                        ),
                      ),

                      const SizedBox(height: 44),

                      // ── Start Learning CTA ──────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(Routes.qrScanner),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Start Learning',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded, size: 22),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
