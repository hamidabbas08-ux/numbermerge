import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_cell.dart';
import '../models/game_state.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';

enum MoveDirection { up, down, left, right }

class GameController extends ChangeNotifier {
  final StorageService _storageService;
  final AdService _adService;
  final Random _random = Random();
  final int gridSize = 4;

  late GameState _currentState;
  GameState? _previousState; // انڈو (Undo) کے لیے پچھلی حالت

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _darkTheme = true;

  GameController(this._storageService, this._adService) {
    _soundEnabled = _storageService.getSoundEnabled();
    _musicEnabled = _storageService.getMusicEnabled();
    _darkTheme = _storageService.getDarkThemeEnabled();
    
    _loadOrInitGame();
  }

  // گیٹرز (Getters)
  GameState get state => _currentState;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get darkTheme => _darkTheme;
  AdService get adService => _adService;

  void _loadOrInitGame() {
    final savedState = _storageService.loadGameState();
    if (savedState != null) {
      _currentState = savedState;
    } else {
      _resetState();
    }
  }

  void _resetState() {
    _currentState = GameState(
      cells: [],
      score: 0,
      highScore: _storageService.getHighScore(),
      coins: _storageService.getCoins(),
      level: _storageService.getLevel(),
      xp: _storageService.getXp(),
      isGameOver: false,
      isWon: false,
    );
    _addRandomCell();
    _addRandomCell();
  }

  void resetGame() {
    _previousState = null;
    _resetState();
    _storageService.saveGameState(_currentState);
    notifyListeners();
  }

  // نیا ہندسہ بورڈ پر شامل کرنا (2 یا 4)
  void _addRandomCell() {
    List<Map<String, int>> emptyPositions = [];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (!_cellExistsAt(r, c)) {
          emptyPositions.add({'row': r, 'col': c});
        }
      }
    }

    if (emptyPositions.isNotEmpty) {
      final pos = emptyPositions[_random.nextInt(emptyPositions.length)];
      final value = _random.nextDouble() < 0.9 ? 2 : 4;
      final newCell = GameCell(
        id: DateTime.now().microsecondsSinceEpoch.toString() + _random.nextInt(1000).toString(),
        value: value,
        row: pos['row']!,
        col: pos['col']!,
        isNew: true,
      );
      
      List<GameCell> updatedCells = List.from(_currentState.cells)..add(newCell);
      _currentState = _currentState.copyWith(cells: updatedCells);
    }
  }

  bool _cellExistsAt(int r, int c) {
    return _currentState.cells.any((cell) => cell.row == r && cell.col == c);
  }

  // سوائپ موومنٹ کی لاجک (Swipe Logic)
  void move(MoveDirection direction) {
    if (_currentState.isGameOver) return;

    // ایکشن سے پہلے موجودہ حالت کو انڈو کے لیے محفوظ کریں
    _previousState = _currentState;

    List<GameCell> currentCells = _currentState.cells.map((c) => c.copyWith(isMerged: false, isNew: false)).toList();
    bool moved = false;
    int mergedScore = 0;

    for (int i = 0; i < gridSize; i++) {
      List<GameCell> line = [];
      if (direction == MoveDirection.left || direction == MoveDirection.right) {
        line = currentCells.where((c) => c.row == i).toList();
        line.sort((a, b) => direction == MoveDirection.left ? a.col.compareTo(b.col) : b.col.compareTo(a.col));
      } else {
        line = currentCells.where((c) => c.col == i).toList();
        line.sort((a, b) => direction == MoveDirection.up ? a.row.compareTo(b.row) : b.row.compareTo(a.row));
      }

      List<GameCell> newLine = [];
      for (int j = 0; j < line.length; j++) {
        if (j + 1 < line.length && line[j].value == line[j + 1].value) {
          int newValue = line[j].value * 2;
          mergedScore += newValue;
          
          newLine.add(line[j].copyWith(
            value: newValue,
            isMerged: true,
          ));
          j++; // اگلا سیل سکپ کریں کیونکہ وہ ضم ہو چکا ہے
          moved = true;
        } else {
          newLine.add(line[j]);
        }
      }

      // نئی پوزیشنز سیٹ کرنا
      for (int j = 0; j < newLine.length; j++) {
        int targetRow = (direction == MoveDirection.left || direction == MoveDirection.right) ? i : (direction == MoveDirection.up ? j : gridSize - 1 - j);
        int targetCol = (direction == MoveDirection.left || direction == MoveDirection.right) ? (direction == MoveDirection.left ? j : gridSize - 1 - j) : i;

        if (newLine[j].row != targetRow || newLine[j].col != targetCol) {
          moved = true;
        }

        currentCells = currentCells.map((c) {
          if (c.id == newLine[j].id) {
            return c.copyWith(row: targetRow, col: targetCol, value: newLine[j].value, isMerged: newLine[j].isMerged);
          }
          return c;
        }).toList();
      }
    }

    if (moved) {
      _currentState = _currentState.copyWith(cells: currentCells);
      _addRandomCell();
      _updateScoreAndXP(mergedScore);
      _checkGameOver();
      _storageService.saveGameState(_currentState);
      notifyListeners();
    }
  }

  void _updateScoreAndXP(int gainedScore) {
    if (gainedScore <= 0) return;

    int newScore = _currentState.score + gainedScore;
    int newHighScore = newScore > _currentState.highScore ? newScore : _currentState.highScore;
    if (newHighScore > _currentState.highScore) {
      _storageService.setHighScore(newHighScore);
    }

    int newXp = _currentState.xp + gainedScore;
    int currentLevel = _currentState.level;
    int nextLevelThreshold = currentLevel * 1500;

    int newCoins = _currentState.coins;
    if (newXp >= nextLevelThreshold) {
      currentLevel += 1;
      newCoins += 50; // لیول اپ ہونے پر 50 کوائنز انعام
      _storageService.setLevel(currentLevel);
      _storageService.setCoins(newCoins);
    }

    _storageService.setXp(newXp);

    _currentState = _currentState.copyWith(
      score: newScore,
      highScore: newHighScore,
      xp: newXp,
      level: currentLevel,
      coins: newCoins,
    );
  }

  void _checkGameOver() {
    if (_currentState.cells.length < gridSize * gridSize) return;

    // چیک کریں کہ کیا کوئی ہندسہ ضم ہو سکتا ہے
    for (var cell in _currentState.cells) {
      for (var other in _currentState.cells) {
        if (cell.id != other.id && cell.value == other.value) {
          if ((cell.row == other.row && (cell.col - other.col).abs() == 1) ||
              (cell.col == other.col && (cell.row - other.row).abs() == 1)) {
            return; // ابھی چال باقی ہے
          }
        }
      }
    }

    _currentState = _currentState.copyWith(isGameOver: true);
  }

  // انڈو (Undo) سسٹم - قیمت 20 کوائنز
  bool undoMove() {
    if (_previousState != null && _currentState.coins >= 20) {
      int updatedCoins = _currentState.coins - 20;
      _storageService.setCoins(updatedCoins);
      _currentState = _previousState!.copyWith(coins: updatedCoins);
      _previousState = null;
      _storageService.saveGameState(_currentState);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ہنٹ (Hint) سسٹم - کم ترین قیمت والے دو سیلز کو خودکار ضم کرنا - قیمت 50 کوائنز
  bool useHint() {
    if (_currentState.coins < 50 || _currentState.isGameOver) return false;

    List<GameCell> sortedCells = List.from(_currentState.cells)..sort((a, b) => a.value.compareTo(b.value));
    
    for (var cell in sortedCells) {
      for (var other in _currentState.cells) {
        if (cell.id != other.id && cell.value == other.value) {
          if ((cell.row == other.row && (cell.col - other.col).abs() == 1) ||
              (cell.col == other.col && (cell.row - other.row).abs() == 1)) {
            
            // ان دونوں سیلز کو ضم کر دیں
            int targetRow = cell.row;
            int targetCol = cell.col;
            int newValue = cell.value * 2;

            List<GameCell> updatedCells = _currentState.cells
                .where((c) => c.id != cell.id && c.id != other.id)
                .toList();

            updatedCells.add(GameCell(
              id: cell.id,
              value: newValue,
              row: targetRow,
              col: targetCol,
              isMerged: true,
              isNew: false,
            ));

            int updatedCoins = _currentState.coins - 50;
            _storageService.setCoins(updatedCoins);

            _currentState = _currentState.copyWith(
              cells: updatedCells,
              coins: updatedCoins,
            );

            _updateScoreAndXP(newValue);
            _storageService.saveGameState(_currentState);
            notifyListeners();
            return true;
          }
        }
      }
    }
    return false;
  }

  // ایڈز دیکھ کر فری کوائنز حاصل کرنا
  void watchAdForCoins() {
    _adService.showRewardedAd(() {
      int updatedCoins = _currentState.coins + 100; // ایڈ دیکھنے پر 100 فری کوائنز
      _storageService.setCoins(updatedCoins);
      _currentState = _currentState.copyWith(coins: updatedCoins);
      _storageService.saveGameState(_currentState);
      notifyListeners();
    }, () {});
  }

  // سیٹنگز تبدیل کرنے کے طریقے
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _storageService.setSoundEnabled(_soundEnabled);
    notifyListeners();
  }

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    _storageService.setMusicEnabled(_musicEnabled);
    notifyListeners();
  }

  void toggleTheme() {
    _darkTheme = !_darkTheme;
    _storageService.setDarkThemeEnabled(_darkTheme);
    notifyListeners();
  }
}
