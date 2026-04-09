import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class WinLineOverlay extends StatefulWidget {
  final List<int> winningLine;

  const WinLineOverlay({super.key, required this.winningLine});

  @override
  State<WinLineOverlay> createState() => _WinLineOverlayState();
}

class _WinLineOverlayState extends State<WinLineOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: WinLinePainter(
            winningLine: widget.winningLine,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class WinLinePainter extends CustomPainter {
  final List<int> winningLine;
  final double progress;

  WinLinePainter({required this.winningLine, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (winningLine.length != 3) return;

    final paint = Paint()
      ..color = AppColors.winHighlight.withOpacity(0.8)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    Offset cellCenter(int index) {
      final row = index ~/ 3;
      final col = index % 3;
      return Offset(
        col * cellWidth + cellWidth / 2,
        row * cellHeight + cellHeight / 2,
      );
    }

    final start = cellCenter(winningLine.first);
    final end = cellCenter(winningLine.last);
    final currentEnd = Offset(
      start.dx + (end.dx - start.dx) * progress,
      start.dy + (end.dy - start.dy) * progress,
    );

    canvas.drawLine(start, currentEnd, paint);
  }

  @override
  bool shouldRepaint(covariant WinLinePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
