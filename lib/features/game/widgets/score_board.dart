import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_theme.dart';
import '../../../core/constants.dart';

class ScoreBoard extends StatelessWidget {
  final int scoreX;
  final int scoreO;
  final int draws;
  final GameMode gameMode;

  const ScoreBoard({
    super.key,
    required this.scoreX,
    required this.scoreO,
    required this.draws,
    required this.gameMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark).withOpacity(isDark ? 0.5 : 1.0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ScoreCard(
              label: gameMode == GameMode.pvai ? 'YOU' : 'X',
              score: scoreX,
              color: AppColors.playerX,
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.grid(isDark),
          ),
          Expanded(
            child: _ScoreCard(
              label: 'DRAW',
              score: draws,
              color: AppColors.drawColor,
              isDark: isDark,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.grid(isDark),
          ),
          Expanded(
            child: _ScoreCard(
              label: gameMode == GameMode.pvai ? 'AI' : 'O',
              score: scoreO,
              color: AppColors.playerO,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final bool isDark;

  const _ScoreCard({
    required this.label,
    required this.score,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Text(
            '$score',
            key: ValueKey<int>(score),
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(isDark),
            ),
          ),
        ),
      ],
    );
  }
}
