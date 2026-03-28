import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.38, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.22, curve: Curves.easeIn),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.32, 0.56, curve: Curves.easeOut),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.7),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.30, 0.56, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo mark
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: child,
                  ),
                ),
                child: _LogoMark(),
              ),

              const SizedBox(height: 28),

              // App name
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => Opacity(
                  opacity: _logoOpacity.value,
                  child: child,
                ),
                child: Text(
                  'SpendWise',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Tagline
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => Opacity(
                  opacity: _taglineOpacity.value,
                  child: SlideTransition(
                    position: _taglineSlide,
                    child: child,
                  ),
                ),
                child: Text(
                  'Smart Expense Tracker',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withAlpha(204),
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Pulsing dots
              AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) => Opacity(
                  opacity: _taglineOpacity.value,
                  child: child,
                ),
                child: const _PulsingDots(),
              ),

              const SizedBox(height: 52),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Wallet + Donut logo ─────────────────────────────────────────────────────
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withAlpha(70), width: 1.5),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(68, 68),
          painter: _WalletChartPainter(),
        ),
      ),
    );
  }
}

class _WalletChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wallet strip (top)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.22, w, h * 0.18),
        const Radius.circular(5),
      ),
      Paint()..color = Colors.white.withAlpha(170),
    );

    // Wallet body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.30, w, h * 0.70),
        const Radius.circular(9),
      ),
      Paint()..color = Colors.white,
    );

    // Donut chart
    final cx = w * 0.50;
    final cy = h * 0.68;
    final r  = w * 0.27;
    final ri = w * 0.11;

    void slice(double startDeg, double sweepDeg, Color color) {
      final start = startDeg * math.pi / 180;
      final sweep = sweepDeg * math.pi / 180;
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(Rect.fromCircle(center: Offset(cx, cy), radius: r),
            start, sweep, false)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    slice(-90, 162, const Color(0xFF15803D));
    slice(72,  126, Colors.white);
    slice(198,  72, const Color(0xFF86EFAC));

    // Divider lines
    final divPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (final deg in [-90.0, 72.0, 198.0]) {
      final rad = deg * math.pi / 180;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + r * math.cos(rad), cy + r * math.sin(rad)),
        divPaint,
      );
    }

    // Donut hole
    canvas.drawCircle(Offset(cx, cy), ri, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Pulsing loading dots ─────────────────────────────────────────────────────
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_c.value - i * 0.22) % 1.0).clamp(0.0, 1.0);
            final scale = 0.55 + 0.45 * math.sin(phase * math.pi).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(200),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
