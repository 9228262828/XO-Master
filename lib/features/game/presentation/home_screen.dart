import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../core/constants.dart';
import '../../../services/theme_service.dart';
import '../logic/game_controller.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTopBar(context, isDark),
              const Spacer(flex: 2),
              _buildLogo(isDark, size),
              const Spacer(flex: 1),
              _buildMenuButtons(context, isDark),
              const Spacer(flex: 2),
              _buildFooter(isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    final themeService = context.watch<ThemeService>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => themeService.toggleTheme(),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  RotationTransition(turns: animation, child: child),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(bool isDark, Size size) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryLight,
                AppColors.accentLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'XO',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppConstants.appName,
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.appTagline,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        _MenuButton(
          icon: Icons.people_rounded,
          label: 'Player vs Player',
          sublabel: 'Play with a friend',
          color: AppColors.playerX,
          isDark: isDark,
          onTap: () => _startGame(context, GameMode.pvp),
        ),
        const SizedBox(height: 16),
        _MenuButton(
          icon: Icons.smart_toy_rounded,
          label: 'Player vs AI',
          sublabel: 'Challenge the computer',
          color: AppColors.playerO,
          isDark: isDark,
          onTap: () => _showDifficultyPicker(context, isDark),
        ),
      ],
    );
  }

  void _startGame(BuildContext context, GameMode mode, [Difficulty? difficulty]) {
    final controller = context.read<GameController>();
    controller.setGameMode(mode);
    if (difficulty != null) {
      controller.setDifficulty(difficulty);
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GameScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showDifficultyPicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Difficulty',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 24),
            _DifficultyOption(
              icon: Icons.sentiment_satisfied_rounded,
              label: 'Easy',
              description: 'For casual play',
              color: AppColors.winHighlight,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                _startGame(context, GameMode.pvai, Difficulty.easy);
              },
            ),
            const SizedBox(height: 12),
            _DifficultyOption(
              icon: Icons.psychology_rounded,
              label: 'Medium',
              description: 'A real challenge',
              color: AppColors.drawHighlight,
              isDark: isDark,
              onTap: () {
                Navigator.pop(ctx);
                _startGame(context, GameMode.pvai, Difficulty.medium);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Text(
      'Tap to start playing',
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.sublabel,
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _DifficultyOption({
    required this.icon,
    required this.label,
    required this.description,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
