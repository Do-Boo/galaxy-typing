// 사용자 게임 통계를 관리하는 서비스
// 작성: 2023-05-10
// 게임 통계를 로드, 저장 및 업데이트하는 기능 제공

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_stats.dart';

class StatsService {
  static const String _statsKey = 'game_stats';
  GameStats? _cachedStats;

  // 통계 불러오기
  Future<GameStats> loadStats() async {
    if (_cachedStats != null) {
      return _cachedStats!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);

      if (statsJson != null) {
        _cachedStats = GameStats.fromJson(json.decode(statsJson));
        return _cachedStats!;
      }
    } catch (e) {
      print('통계 로드 오류: $e');
    }

    // 기본 통계 반환 (저장된 통계가 없거나 오류 발생 시)
    _cachedStats = GameStats.empty;
    return _cachedStats!;
  }

  // 통계 저장
  Future<bool> saveStats(GameStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = json.encode(stats.toJson());

      final success = await prefs.setString(_statsKey, statsJson);
      if (success) {
        _cachedStats = stats;
      }
      return success;
    } catch (e) {
      print('통계 저장 오류: $e');
      return false;
    }
  }

  // 기본 타자 연습 세션 결과 업데이트
  Future<bool> updateBasicTypingStats({
    required int chars,
    required int correctChars,
    required int words,
    required int cpm,
    required int timeSpent,
  }) async {
    try {
      final currentStats = await loadStats();

      // 새 통계 계산
      final totalChars = currentStats.totalChars + chars;
      final totalCorrectChars = currentStats.correctChars + correctChars;
      final totalWords = currentStats.totalWords + words;
      final totalTimeSpent = currentStats.totalTimeSpent + timeSpent;

      // 최고 CPM 업데이트 (더 높은 경우에만)
      final bestCpm = cpm > currentStats.bestCpm ? cpm : currentStats.bestCpm;

      // 평균 CPM 계산
      final totalSessions = currentStats.totalSessions + 1;
      final newAvgCpm =
          ((currentStats.averageCpm * currentStats.totalSessions) + cpm) ~/
          totalSessions;

      // 새 통계 객체 생성 및 저장
      final updatedStats = currentStats.copyWith(
        totalChars: totalChars,
        correctChars: totalCorrectChars,
        totalWords: totalWords,
        bestCpm: bestCpm,
        averageCpm: newAvgCpm,
        totalTimeSpent: totalTimeSpent,
        totalSessions: totalSessions,
        lastPlayed: DateTime.now(),
      );

      return await saveStats(updatedStats);
    } catch (e) {
      print('기본 타자 연습 통계 업데이트 오류: $e');
      return false;
    }
  }

  // 시간 도전 결과 업데이트
  Future<bool> updateTimeChallengeStats({
    required int duration, // 초 단위 (30, 60, 120)
    required int score,
    required int chars,
    required int correctChars,
  }) async {
    try {
      final currentStats = await loadStats();

      // 새 통계 계산
      final totalChars = currentStats.totalChars + chars;
      final totalCorrectChars = currentStats.correctChars + correctChars;
      final totalSessions = currentStats.totalSessions + 1;

      // 시간별 최고 점수 업데이트
      int best30SecScore = currentStats.best30SecScore;
      int best60SecScore = currentStats.best60SecScore;
      int best120SecScore = currentStats.best120SecScore;

      switch (duration) {
        case 30:
          if (score > best30SecScore) best30SecScore = score;
          break;
        case 60:
          if (score > best60SecScore) best60SecScore = score;
          break;
        case 120:
          if (score > best120SecScore) best120SecScore = score;
          break;
      }

      // 새 통계 객체 생성 및 저장
      final updatedStats = currentStats.copyWith(
        totalChars: totalChars,
        correctChars: totalCorrectChars,
        best30SecScore: best30SecScore,
        best60SecScore: best60SecScore,
        best120SecScore: best120SecScore,
        totalSessions: totalSessions,
        lastPlayed: DateTime.now(),
      );

      return await saveStats(updatedStats);
    } catch (e) {
      print('시간 도전 통계 업데이트 오류: $e');
      return false;
    }
  }

  // 우주 디펜스 게임 결과 업데이트
  Future<bool> updateDefenseGameStats({
    required int score,
    required int wave,
    required int enemiesDefeated,
  }) async {
    try {
      final currentStats = await loadStats();

      // 새 통계 계산
      final totalSessions = currentStats.totalSessions + 1;
      final highestWave =
          wave > currentStats.highestWave ? wave : currentStats.highestWave;
      final highScore =
          score > currentStats.highScore ? score : currentStats.highScore;
      final totalEnemies = currentStats.totalEnemiesDefeated + enemiesDefeated;

      // 새 통계 객체 생성 및 저장
      final updatedStats = currentStats.copyWith(
        highestWave: highestWave,
        highScore: highScore,
        totalEnemiesDefeated: totalEnemies,
        totalSessions: totalSessions,
        lastPlayed: DateTime.now(),
      );

      return await saveStats(updatedStats);
    } catch (e) {
      print('우주 디펜스 게임 통계 업데이트 오류: $e');
      return false;
    }
  }

  // 통계 초기화 (앱 초기화용)
  Future<bool> resetStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_statsKey);

      if (success) {
        _cachedStats = GameStats.empty;
      }

      return success;
    } catch (e) {
      print('통계 초기화 오류: $e');
      return false;
    }
  }
}
