import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class StorageService {
  static const String _keyGameState = 'number_merge_game_state';
  static const String _keyHighScore = 'number_merge_high_score';
  static const String _keyCoins = 'number_merge_coins';
  static const String _keySound = 'number_merge_sound';
  static const String _keyMusic = 'number_merge_music';
  static const String _keyDarkTheme = 'number_merge_dark_theme';
  static const String _keyLevel = 'number_merge_level';
  static const String _keyXp = 'number_merge_xp';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Future<bool> saveGameState(GameState state) async {
    final String jsonStr = jsonEncode(state.toJson());
    return await _prefs.setString(_keyGameState, jsonStr);
  }

  GameState? loadGameState() {
    final String? jsonStr = _prefs.getString(_keyGameState);
    if (jsonStr == null) return null;
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GameState.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  Future<bool> clearGameState() async {
    return await _prefs.remove(_keyGameState);
  }

  int getHighScore() {
    return _prefs.getInt(_keyHighScore) ?? 0;
  }

  Future<bool> setHighScore(int score) async {
    return await _prefs.setInt(_keyHighScore, score);
  }

  int getCoins() {
    return _prefs.getInt(_keyCoins) ?? 100;
  }

  Future<bool> setCoins(int coins) async {
    return await _prefs.setInt(_keyCoins, coins);
  }

  int getLevel() {
    return _prefs.getInt(_keyLevel) ?? 1;
  }

  Future<bool> setLevel(int level) async {
    return await _prefs.setInt(_keyLevel, level);
  }

  int getXp() {
    return _prefs.getInt(_keyXp) ?? 0;
  }

  Future<bool> setXp(int xp) async {
    return await _prefs.setInt(_keyXp, xp);
  }

  bool getSoundEnabled() {
    return _prefs.getBool(_keySound) ?? true;
  }

  Future<bool> setSoundEnabled(bool enabled) async {
    return await _prefs.setBool(_keySound, enabled);
  }

  bool getMusicEnabled() {
    return _prefs.getBool(_keyMusic) ?? true;
  }

  Future<bool> setMusicEnabled(bool enabled) async {
    return await _prefs.setBool(_keyMusic, enabled);
  }

  bool getDarkThemeEnabled() {
    return _prefs.getBool(_keyDarkTheme) ?? true;
  }

  Future<bool> setDarkThemeEnabled(bool enabled) async {
    return await _prefs.setBool(_keyDarkTheme, enabled);
  }
}
