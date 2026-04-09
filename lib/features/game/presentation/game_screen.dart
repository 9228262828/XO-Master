import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../core/constants.dart';
import '../../../services/sound_service.dart';
import '../logic/game_controller.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState _prevState = GameState.playing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<GameController>();
    final sound = context.read<SoundService>();

    controller.addListener(() {
      final newState = controller.gameState;
      if (newState != _prevState) {
        if (newState == GameState.won) {
          sound.playWin();
        } else if (newState == GameState.draw) {
          sound.playDraw();
        }
        _prevState = newState;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<GameController>();
    final sound = context.read<SoundService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth - 56).clamp(200.0, 400.0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildAppBar(context, controller, isDark),
                const SizedBox(height: 20),
                ScoreBoard(
                  scoreX: controller.scoreX,
                  scoreO: controller.scoreO,
                  draws: controller.draws,
                  gameMode: controller.gameMode,
                ),
                const Spacer(flex: 1),
                _StatusBanner(controller: controller, isDark: isDark),
                const SizedBox(height: 20),
                SizedBox(
                  width: boardSize,
                  child: const GameBoard(),
                ),
                const Spacer(flex: 1),
                _buildActionButtons(context, controller, isDark, sound),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, GameController controller, bool isDark) {
    final modeLabel = controller.gameMode == GameMode.pvp
        ? 'Player vs Player'
        : 'vs AI (${controller.difficulty == Difficulty.easy ? "Easy" : "Medium"})';

    return Row(
      children: [
        _BackButton(isDark: isDark),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(isDark),
                ),
              ),
              Text(
                modeLabel,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, GameController controller,
      bool isDark, SoundService sound) {
    final isGameOver = controller.gameState != GameState.playing;

    return AnimatedSwitcher(
      duration: AppConstants.uiTransition,
      child: Row(
        key: ValueKey(isGameOver),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isGameOver) ...[
            _PillButton(
              icon: Icons.refresh_rounded,
              label: 'New Game',
              color: AppColors.primary(isDark),
              isDark: isDark,
              onTap: () {
                sound.playTap();
                controller.newGame();
              },
            ),
            const SizedBox(width: 10),
          ],
          _PillButton(
            icon: Icons.restart_alt_rounded,
            label: 'Reset',
            color: AppColors.accentLight,
            isDark: isDark,
            onTap: () => _showResetDialog(context, controller, isDark, sound),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, GameController controller,
      bool isDark, SoundService sound) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Scores?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        content: Text(
          'This will reset all scores and start a new game.',
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              sound.playTap();
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

class _BackButton extends StatelessWidget {
  final bool isDark;
  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(isDark).withOpacity(isDark ? 0.4 : 1.0),
      borderRadius: BorderRadius.circular(12),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary(isDark),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final GameController controller;
  final bool isDark;

  const _StatusBanner({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (controller.gameState) {
      case GameState.won:
        color = AppColors.winColor;
        icon = Icons.emoji_events_rounded;
        break;
      case GameState.draw:
        color = AppColors.drawColor;
        icon = Icons.handshake_rounded;
        break;
      case GameState.playing:
        color = controller.currentPlayer == Player.x
            ? AppColors.playerX
            : AppColors.playerO;
        icon = controller.isAiThinking
            ? Icons.smart_toy_rounded
            : Icons.play_circle_rounded;
        break;
    }

    return AnimatedContainer(
      duration: AppConstants.uiTransition,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              controller.statusMessage,
              key: ValueKey(controller.statusMessage),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: 18),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
