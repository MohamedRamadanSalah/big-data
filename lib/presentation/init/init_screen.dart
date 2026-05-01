import 'package:flutter/material.dart';
import '../../data/database/db_helper.dart';
import '../search/search_screen.dart';

/// Shown on first launch while the 486 MB database is copied from
/// the asset bundle to the device's writable storage.
/// On subsequent launches the DB is already there, so this screen
/// resolves in milliseconds and the user sees no delay.
class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0;
  String _statusText = 'Preparing database…';
  bool _done = false;

  // Pulse animation for the logo
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _init();
  }

  Future<void> _init() async {
    await DbHelper.ensureDatabase(
      onProgress: (p) {
        if (!mounted) return;
        setState(() {
          _progress = p;
          if (p < 0.5) {
            _statusText = 'Reading database…';
          } else if (p < 1.0) {
            _statusText = 'Writing to device…';
          } else {
            _statusText = 'Ready!';
          }
        });
      },
    );

    if (!mounted) return;
    setState(() => _done = true);

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const SearchScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF13141F), Color(0xFF1C2340)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Animated logo ─────────────────────────────────────────────
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F6BFF),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F6BFF).withAlpha(120),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.manage_search_rounded,
                      color: Colors.white, size: 52),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'PageSearch',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE8EAF6),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Your local knowledge base',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFFE8EAF6).withAlpha(140),
                ),
              ),

              const Spacer(flex: 2),

              // ── Progress section ─────────────────────────────────────────
              if (!_done) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress > 0 ? _progress : null,
                          minHeight: 6,
                          backgroundColor: const Color(0xFF252839),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4F6BFF)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _statusText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8B8FA8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Only happens once on first launch',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF8B8FA8).withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF4F6BFF), size: 36),
                const SizedBox(height: 8),
                const Text('Ready!',
                    style: TextStyle(
                        color: Color(0xFF4F6BFF),
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ],

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
