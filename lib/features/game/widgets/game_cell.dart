import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/constants.dart';

class GameCell extends StatefulWidget {
  final int index;
  final Player player;
  final bool isWinningCell;
  final bool isLastPlayed;
  final GameState gameState;
  final VoidCallback onTap;

  const GameCell({
    super.key,
    required this.index,
    required this.player,
    required this.isWinningCell,
    required this.isLastPlayed,
    required this.gameState,
    required this.onTap,
  });

  @override
  State<GameCell> createState() => _GameCellState();
}

class _GameCellState extends State<GameCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(covariant GameCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.player != Player.none && oldWidget.player == Player.none) {
      _controller.forward(from: 0.0);
    }
    if (widget.player == Player.none && oldWidget.player != Player.none) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    if (widget.isWinningCell && widget.gameState == GameState.won) {
      bgColor = AppColors.winHighlight.withOpacity(0.15);
    } else {
      bgColor = isDark
          ? AppColors.cardDark.withOpacity(0.6)
          : AppColors.backgroundLight;
    }

    return GestureDetector(
      onTap: widget.player == Player.none && widget.gameState == GameState.playing
          ? widget.onTap
          : null,
      child: AnimatedContainer(
        duration: AppConstants.animationDuration,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isWinningCell
                ? AppColors.winHighlight.withOpacity(0.5)
                : (isDark ? AppColors.gridLineDark : AppColors.gridLineLight),
            width: widget.isWinningCell ? 2.5 : 1.5,
          ),
        ),
        child: Center(
          child: widget.player != Player.none
              ? FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildMark(isDark),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMark(bool isDark) {
    if (widget.player == Player.x) {
      return CustomPaint(
        size: const Size(48, 48),
        painter: XPainter(
          color: widget.isWinningCell
              ? AppColors.winHighlight
              : AppColors.playerX,
        ),
      );
    } else if (widget.player == Player.o) {
      return CustomPaint(
        size: const Size(48, 48),
        painter: OPainter(
          color: widget.isWinningCell
              ? AppColors.winHighlight
              : AppColors.playerO,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class XPainter extends CustomPainter {
  final Color color;
  XPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final margin = size.width * 0.15;
    canvas.drawLine(
      Offset(margin, margin),
      Offset(size.width - margin, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(margin, size.height - margin),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant XPainter oldDelegate) =>
      color != oldDelegate.color;
}

class OPainter extends CustomPainter {
  final Color color;
  OPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final margin = size.width * 0.15;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width / 2) - margin,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant OPainter oldDelegate) =>
      color != oldDelegate.color;
}
