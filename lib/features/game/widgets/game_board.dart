import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';

import '../logic/game_controller.dart';
import 'game_cell.dart';
import 'win_line_painter.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<GameController>();

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.primaryLight).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildGrid(context, controller, isDark),
            if (controller.winningLine.isNotEmpty)
              Positioned.fill(
                child: WinLineOverlay(
                  winningLine: controller.winningLine,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, GameController controller, bool isDark) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return GameCell(
          index: index,
          player: controller.board[index],
          isWinningCell: controller.winningLine.contains(index),
          isLastPlayed: controller.lastPlayedCell == index,
          gameState: controller.gameState,
          onTap: () => controller.makeMove(index),
        );
      },
    );
  }
}
