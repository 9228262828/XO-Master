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

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark).withOpacity(isDark ? 0.4 : 1.0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.grid(isDark).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary(isDark).withOpacity(isDark ? 0.08 : 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
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
                  gameState: controller.gameState,
                  onTap: () => controller.makeMove(index),
                );
              },
            ),
            if (controller.winningLine.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: WinLineOverlay(
                    winningLine: controller.winningLine,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
