import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../core/constants.dart';
import '../logic/game_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<GameController>();
    final size = MediaQuery.of(context).size;
    final boardSize = size.width - 48;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildAppBar(context, controller, isDark),
              const Spacer(flex: 1),
              ScoreBoard(
                scoreX: controller.scoreX,
                scoreO: controller.scoreO,
                draws: controller.draws,
                gameMode: controller.gameMode,
              ),
              const SizedBox(height: 24),
              _buildStatusBanner(controller, isDark),
              const SizedBox(height: 24),
              SizedBox(
                width: boardSize,
                height: boardSize,
                child: const GameBoard(),
              ),
              const Spacer(flex: 1),
              _buildActionButtons(context, controller, isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, GameController controller, bool isDark) {
    final modeLabel = controller.gameMode == GameMode.pvp
        ? 'Player vs Player'
        : 'vs AI (${controller.difficulty == Difficulty.easy ? "Easy" : "Medium"})';

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                modeLabel,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(GameController controller, bool isDark) {
    Color bannerColor;
    IconData bannerIcon;

    switch (controller.gameState) {
      case GameState.won:
        bannerColor = AppColors.winHighlight;
        bannerIcon = Icons.emoji_events_rounded;
        break;
      case GameState.draw:
        bannerColor = AppColors.drawHighlight;
        bannerIcon = Icons.handshake_rounded;
        break;
      case GameState.playing:
        bannerColor = controller.currentPlayer == Player.x
            ? AppColors.playerX
            : AppColors.playerO;
        bannerIcon = controller.isAiThinking
            ? Icons.smart_toy_rounded
            : Icons.play_circle_rounded;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(bannerIcon, color: bannerColor, size: 22),
          const SizedBox(width: 10),
          Text(
            controller.statusMessage,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: bannerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameController controller, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (controller.gameState != GameState.playing) ...[
          _ActionButton(
            icon: Icons.refresh_rounded,
            label: 'New Game',
            color: AppColors.primaryLight,
            isDark: isDark,
            onTap: () => controller.newGame(),
          ),
          const SizedBox(width: 12),
        ],
        _ActionButton(
          icon: Icons.restart_alt_rounded,
          label: 'Reset Scores',
          color: AppColors.accentLight,
          isDark: isDark,
          onTap: () => _showResetConfirmation(context, controller, isDark),
        ),
      ],
    );
  }

  void _showResetConfirmation(
      BuildContext context, GameController controller, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Scores?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'This will reset all scores and start a new game.',
          style: GoogleFonts.poppins(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.resetScores();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
