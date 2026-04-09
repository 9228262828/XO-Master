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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreCard(
          context,
          label: gameMode == GameMode.pvai ? 'YOU (X)' : 'X',
          score: scoreX,
          color: AppColors.playerX,
          isDark: isDark,
        ),
        _buildScoreCard(
          context,
          label: 'DRAW',
          score: draws,
          color: AppColors.drawHighlight,
          isDark: isDark,
        ),
        _buildScoreCard(
          context,
          label: gameMode == GameMode.pvai ? 'AI (O)' : 'O',
          score: scoreO,
          color: AppColors.playerO,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    BuildContext context, {
    required String label,
    required int score,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              '$score',
              key: ValueKey<int>(score),
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
