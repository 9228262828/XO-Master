import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/constants.dart';

class WinLineOverlay extends StatefulWidget {
  final List<int> winningLine;

  const WinLineOverlay({super.key, required this.winningLine});

  @override
  State<WinLineOverlay> createState() => _WinLineOverlayState();
}

class _WinLineOverlayState extends State<WinLineOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.winLineDuration,
      vsync: this,
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        return CustomPaint(
          painter: _WinLinePainter(
            winningLine: widget.winningLine,
            progress: _progress.value,
          ),
        );
      },
    );
  }
}

class _WinLinePainter extends CustomPainter {
  final List<int> winningLine;
  final double progress;

  _WinLinePainter({required this.winningLine, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (winningLine.length != 3) return;

    final cellW = size.width / 3;
    final cellH = size.height / 3;

    Offset center(int idx) {
      final row = idx ~/ 3;
      final col = idx % 3;
      return Offset(col * cellW + cellW / 2, row * cellH + cellH / 2);
    }

    final start = center(winningLine.first);
    final end = center(winningLine.last);
    final currentEnd = Offset.lerp(start, end, progress)!;

    // Glow layer
    final glow = Paint()
      ..color = AppColors.winColor.withOpacity(0.25 * progress)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawLine(start, currentEnd, glow);

    // Main line
    final line = Paint()
      ..color = AppColors.winColor.withOpacity(0.9)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, currentEnd, line);
  }

  @override
  bool shouldRepaint(covariant _WinLinePainter old) =>
      progress != old.progress;
}
