import 'package:flutter/material.dart';
import '../../models/game_cell.dart';

class GameTile extends StatefulWidget {
  final GameCell cell;
  final double size;
  final bool isDark;

  const GameTile({
    super.key,
    required this.cell,
    required this.size,
    required this.isDark,
  });

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.cell.isNew || widget.cell.isMerged) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant GameTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cell.value != oldWidget.cell.value || widget.cell.isMerged) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ہندسوں کے حساب سے پروفیشنل رنگوں کا انتخاب
  Color _getTileBackground(int value) {
    final Map<int, Color> darkColors = {
      2: const Color(0xFF2D2D3A),
      4: const Color(0xFF3E3E50),
      8: const Color(0xFFF39C12),
      16: const Color(0xFFE67E22),
      32: const Color(0xFFD35400),
      64: const Color(0xFFE74C3C),
      128: const Color(0xFFC0392B),
      256: const Color(0xFF1ABC9C),
      512: const Color(0xFF16A085),
      1024: const Color(0xFF2ECC71),
      2048: const Color(0xFF27AE60),
      4096: const Color(0xFF9B59B6),
    };

    final Map<int, Color> lightColors = {
      2: const Color(0xFFE0E0E0),
      4: const Color(0xFFCCCCCC),
      8: const Color(0xFFFFE0B2),
      16: const Color(0xFFFFCC80),
      32: const Color(0xFFFFB74D),
      64: const Color(0xFFFF8A65),
      128: const Color(0xFFFF7043),
      256: const Color(0xFF80CBC4),
      512: const Color(0xFF4DB6AC),
      1024: const Color(0xFF81C784),
      2048: const Color(0xFF66BB6A),
      4096: const Color(0xFFBA68C8),
    };

    final Map<int, Color> colors = widget.isDark ? darkColors : lightColors;
    return colors[value] ?? (widget.isDark ? const Color(0xFF8E44AD) : const Color(0xFF9C27B0));
  }

  Color _getTileTextColor(int value) {
    if (widget.isDark) {
      return Colors.white;
    } else {
      return value <= 4 ? const Color(0xFF333333) : Colors.white;
    }
  }

  double _getFontSize(int value, double tileSize) {
    if (value < 100) return tileSize * 0.45;
    if (value < 1000) return tileSize * 0.38;
    return tileSize * 0.32;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _getTileBackground(widget.cell.value),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${widget.cell.value}',
            style: TextStyle(
              fontSize: _getFontSize(widget.cell.value, widget.size),
              fontWeight: FontWeight.bold,
              color: _getTileTextColor(widget.cell.value),
            ),
          ),
        ),
      ),
    );
  }
}
