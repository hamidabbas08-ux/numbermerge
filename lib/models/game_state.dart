import 'game_cell.dart';

class GameState {
  final List<GameCell> cells;
  final int score;
  final int highScore;
  final int coins;
  final int level;
  final int xp;
  final bool isGameOver;
  final bool isWon;

  const GameState({
    required this.cells,
    required this.score,
    required this.highScore,
    required this.coins,
    required this.level,
    required this.xp,
    required this.isGameOver,
    required this.isWon,
  });

  GameState copyWith({
    List<GameCell>? cells,
    int? score,
    int? highScore,
    int? coins,
    int? level,
    int? xp,
    bool? isGameOver,
    bool? isWon,
  }) {
    return GameState(
      cells: cells ?? this.cells,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      isGameOver: isGameOver ?? this.isGameOver,
      isWon: isWon ?? this.isWon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cells': cells.map((cell) => cell.toJson()).toList(),
      'score': score,
      'highScore': highScore,
      'coins': coins,
      'level': level,
      'xp': xp,
      'isGameOver': isGameOver,
      'isWon': isWon,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      cells: (json['cells'] as List<dynamic>)
          .map((cellJson) => GameCell.fromJson(cellJson as Map<String, dynamic>))
          .toList(),
      score: json['score'] as int,
      highScore: json['highScore'] as int,
      coins: json['coins'] as int,
      level: json['level'] as int,
      xp: json['xp'] as int,
      isGameOver: json['isGameOver'] as bool,
      isWon: json['isWon'] as bool,
    );
  }
}
