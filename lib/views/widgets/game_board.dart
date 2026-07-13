import 'package:flutter/material.dart';
import '../../models/game_cell.dart';
import 'game_tile.dart';

class GameBoard extends StatelessWidget {
  final List<GameCell> cells;
  final int gridSize;
  final bool isDark;

  const GameBoard({
    super.key,
    required this.cells,
    required this.gridSize,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // اسکرین کی چوڑائی کے مطابق بورڈ کا سائز خودکار سیٹ ہوگا تاکہ یہ ٹیبلٹ اور موبائل دونوں پر پرفیکٹ دیکھے
        final double boardWidth = constraints.maxWidth;
        const double padding = 12.0;
        final double tileSize = (boardWidth - (padding * (gridSize + 1))) / gridSize;

        return Container(
          width: boardWidth,
          height: boardWidth,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E26) : const Color(0xFFBBADA0),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(padding),
          child: Stack(
            children: [
              // بورڈ کے پچھلے حصے کے خالی خانے (Background Slots)
              ...List.generate(gridSize * gridSize, (index) {
                final int row = index ~/ gridSize;
                final int col = index % gridSize;
                return Positioned(
                  left: col * (tileSize + padding),
                  top: row * (tileSize + padding),
                  child: Container(
                    width: tileSize,
                    height: tileSize,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2A2A35) : const Color(0xFFCDC1B4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }),

              // متحرک ہندسے (Active Sliding Tiles)
              ...cells.map((cell) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  left: cell.col * (tileSize + padding),
                  top: cell.row * (tileSize + padding),
                  key: ValueKey(cell.id),
                  child: GameTile(
                    cell: cell,
                    size: tileSize,
                    isDark: isDark,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
