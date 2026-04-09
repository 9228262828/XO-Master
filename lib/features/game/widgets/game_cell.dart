import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/constants.dart';

class GameCell extends StatefulWidget {
  final int index;
  final Player player;
  final bool isWinningCell;
  final GameState gameState;
  final VoidCallback onTap;

  const GameCell({
    super.key,
    required this.index,
    required this.player,
    required this.isWinningCell,
    required this.gameState,
    required this.onTap,
  });

  @override
  State<GameCell> createState() => _GameCellState();
}

class _GameCellState extends State<GameCell>
    with TickerProviderStateMixin {
  late AnimationController _markController;
  late AnimationController _tapController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();
    _markController = AnimationController(
      duration: AppConstants.cellAnimDuration,
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _markController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _markController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    if (widget.player != Player.none) {
      _markController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant GameCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.player != Player.none && oldWidget.player == Player.none) {
      _markController.forward(from: 0.0);
    }
    if (widget.player == Player.none && oldWidget.player != Player.none) {
      _markController.reset();
    }
  }

  @override
  void dispose() {
    _markController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.player == Player.none &&
        widget.gameState == GameState.playing) {
      _tapController.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    _tapController.reverse();
  }

  void _handleTapCancel() {
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlayable =
        widget.player == Player.none && widget.gameState == GameState.playing;

    Color bgColor;
    Color borderColor;
    double borderWidth;

    if (widget.isWinningCell && widget.gameState == GameState.won) {
      bgColor = AppColors.winColor.withOpacity(isDark ? 0.15 : 0.1);
      borderColor = AppColors.winColor.withOpacity(0.6);
      borderWidth = 2.5;
    } else {
      bgColor = isDark
          ? AppColors.cardDark.withOpacity(0.5)
          : Colors.white;
      borderColor = AppColors.grid(isDark);
      borderWidth = 1.5;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: isPlayable ? widget.onTap : null,
      child: ScaleTransition(
        scale: _tapScale,
        child: AnimatedContainer(
          duration: AppConstants.uiTransition,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: isPlayable
                ? [
                    BoxShadow(
                      color: AppColors.primary(isDark).withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.player != Player.none
                ? FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: _buildMark(),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildMark() {
    final color = widget.isWinningCell
        ? AppColors.winColor
        : (widget.player == Player.x ? AppColors.playerX : AppColors.playerO);

    return LayoutBuilder(
      builder: (context, constraints) {
        final markSize = constraints.maxWidth * 0.52;
        if (widget.player == Player.x) {
          return CustomPaint(
            size: Size(markSize, markSize),
            painter: _XPainter(color: color, strokeWidth: markSize * 0.12),
          );
        }
        return CustomPaint(
          size: Size(markSize, markSize),
          painter: _OPainter(color: color, strokeWidth: markSize * 0.12),
        );
      },
    );
  }
}

class _XPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _XPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final m = size.width * 0.1;
    canvas.drawLine(Offset(m, m), Offset(size.width - m, size.height - m), paint);
    canvas.drawLine(Offset(size.width - m, m), Offset(m, size.height - m), paint);
  }

  @override
  bool shouldRepaint(covariant _XPainter old) =>
      color != old.color || strokeWidth != old.strokeWidth;
}

class _OPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  _OPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width / 2) * 0.82,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _OPainter old) =>
      color != old.color || strokeWidth != old.strokeWidth;
}
