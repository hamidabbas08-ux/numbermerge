import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameController>(
      builder: (context, controller, child) {
        final state = controller.state;
        final isDark = controller.darkTheme;

        // تھیم کے مطابق رنگوں کا انتخاب
        final backgroundColor = isDark ? const Color(0xFF121216) : const Color(0xFFFAF8EF);
        final textColor = isDark ? Colors.white : const Color(0xFF776E65);
        final cardColor = isDark ? const Color(0xFF1E1E26) : const Color(0xFFBBADA0);

        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < -200) {
                  controller.move(MoveDirection.up);
                } else if (details.primaryVelocity! > 200) {
                  controller.move(MoveDirection.down);
                }
              },
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < -200) {
                  controller.move(MoveDirection.left);
                } else if (details.primaryVelocity! > 200) {
                  controller.move(MoveDirection.right);
                }
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        // ٹاپ کنٹرول بار (تھیم، ری اسٹارٹ اور کوائنز)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Merge Puzzle',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF776E65),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: textColor),
                                  onPressed: controller.toggleTheme,
                                ),
                                IconButton(
                                  icon: Icon(Icons.refresh, color: textColor),
                                  onPressed: controller.resetGame,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // اسکور اور لیول کارڈز
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard('SCORE', '${state.score}', cardColor, isDark),
                            _buildStatCard('BEST', '${state.highScore}', cardColor, isDark),
                            _buildStatCard('COINS', '${state.coins} 🪙', cardColor, isDark),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // لیول پروگریس بار
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'LVL ${state.level}',
                                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: (state.xp % (state.level * 1500)) / (state.level * 1500),
                                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark ? const Color(0xFF1ABC9C) : const Color(0xFF8E44AD),
                                    ),
                                    minHeight: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // مرکزی گیم بورڈ
                        Expanded(
                          child: Center(
                            child: GameBoard(
                              cells: state.cells,
                              gridSize: controller.gridSize,
                              isDark: isDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // پاور اپس اور ایڈز بٹنز ایکشن بار
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.undo,
                              label: 'Undo (20)',
                              onPressed: () {
                                final success = controller.undoMove();
                                if (!success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Not enough coins for Undo!')),
                                  );
                                }
                              },
                              color: const Color(0xFFE67E22),
                            ),
                            _buildActionButton(
                              icon: Icons.lightbulb,
                              label: 'Hint (50)',
                              onPressed: () {
                                final success = controller.useHint();
                                if (!success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No possible merges or not enough coins!')),
                                  );
                                }
                              },
                              color: const Color(0xFFF1C40F),
                            ),
                            _buildActionButton(
                              icon: Icons.video_library,
                              label: 'Free Coins',
                              onPressed: controller.watchAdForCoins,
                              color: const Color(0xFF2ECC71),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // گیم اوور اسکرین اوورلے (Game Over Overlay)
                  if (state.isGameOver)
                    Container(
                      color: Colors.black.withOpacity(0.85),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'GAME OVER',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Final Score: ${state.score}',
                              style: const TextStyle(fontSize: 24, color: Colors.white70),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9B59B6),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: controller.resetGame,
                              icon: const Icon(Icons.replay, color: Colors.white),
                              label: const Text(
                                'Try Again',
                                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor, bool isDark) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : const Color(0xFFEEE4DA),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
