// 통계 컨트롤러
// 작성: 2024-05-15
// 사용자의 타이핑 통계를 관리하는 컨트롤러

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_data.dart';

/// 사용자의 타이핑 통계를 관리하는 컨트롤러
class StatsController with ChangeNotifier {
  // 싱글톤 인스턴스
  static StatsController? _instance;

  // SharedPreferences 인스턴스
  late SharedPreferences _prefs;

  // 설정 키 값들
  static const String _keySessionHistory = 'session_history';
  static const String _keyTotalTimeSpent = 'total_time_spent';
  static const String _keyHighestCpm = 'highest_cpm';
  static const String _keyHighestAccuracy = 'highest_accuracy';
  static const String _keyHighestWave = 'highest_wave';
  static const String _keyHighestScore = 'highest_score';

  // 통계 데이터
  List<SessionData> _sessionHistory = [];
  int _totalTimeSpent = 0; // 분 단위
  int _highestCpm = 0;
  double _highestAccuracy = 0.0;
  int _highestWave = 0;
  int _highestScore = 0;

  // 생성자 (private)
  StatsController._create();

  // 팩토리 생성자
  factory StatsController() {
    _instance ??= StatsController._create();
    return _instance!;
  }

  // 초기화 메서드
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadStats();
  }

  // 통계 로드
  void _loadStats() {
    _totalTimeSpent = _prefs.getInt(_keyTotalTimeSpent) ?? 0;
    _highestCpm = _prefs.getInt(_keyHighestCpm) ?? 0;
    _highestAccuracy = _prefs.getDouble(_keyHighestAccuracy) ?? 0.0;
    _highestWave = _prefs.getInt(_keyHighestWave) ?? 0;
    _highestScore = _prefs.getInt(_keyHighestScore) ?? 0;

    // 세션 히스토리 로드
    final sessionHistoryJson = _prefs.getStringList(_keySessionHistory) ?? [];
    _sessionHistory = sessionHistoryJson
        .map((json) => SessionData.fromJson(jsonDecode(json)))
        .toList();

    notifyListeners();
  }

  // 통계 저장
  Future<void> _saveStats() async {
    await _prefs.setInt(_keyTotalTimeSpent, _totalTimeSpent);
    await _prefs.setInt(_keyHighestCpm, _highestCpm);
    await _prefs.setDouble(_keyHighestAccuracy, _highestAccuracy);
    await _prefs.setInt(_keyHighestWave, _highestWave);
    await _prefs.setInt(_keyHighestScore, _highestScore);

    // 세션 히스토리 저장
    final sessionHistoryJson =
        _sessionHistory.map((session) => jsonEncode(session.toJson())).toList();
    await _prefs.setStringList(_keySessionHistory, sessionHistoryJson);
  }

  /// 기본 연습 세션 저장
  Future<void> saveBasicPracticeSession({
    required int chars,
    required int correctChars,
    required int timeSpent,
  }) async {
    final cpm = timeSpent > 0 ? (chars * 60 / timeSpent).round() : 0;
    final accuracy = chars > 0 ? (correctChars / chars * 100) : 0.0;

    final session = SessionData(
      type: SessionType.basicPractice,
      dateTime: DateTime.now(),
      timeSpent: timeSpent,
      charsTyped: chars,
      correctChars: correctChars,
      cpm: cpm,
      accuracy: accuracy,
    );

    _sessionHistory.insert(0, session); // 최신 세션을 맨 앞에 추가
    if (_sessionHistory.length > 100) {
      // 최대 100개 세션 유지
      _sessionHistory.removeLast();
    }

    // 통계 업데이트
    _totalTimeSpent += timeSpent;
    if (cpm > _highestCpm) {
      _highestCpm = cpm;
    }
    if (accuracy > _highestAccuracy) {
      _highestAccuracy = accuracy;
    }

    await _saveStats();
    notifyListeners();
  }

  // 시간 도전 세션 저장
  Future<void> saveTimeChallengeSession({
    required int chars,
    required int correctChars,
    required int words,
    required int cpm,
    required int timeSpent,
  }) async {
    final accuracy = chars > 0 ? (correctChars / chars * 100) : 0.0;

    final session = SessionData(
      type: SessionType.timeChallenge,
      dateTime: DateTime.now(),
      timeSpent: timeSpent,
      charsTyped: chars,
      correctChars: correctChars,
      wordsTyped: words,
      cpm: cpm,
      accuracy: accuracy,
    );

    _sessionHistory.insert(0, session);
    if (_sessionHistory.length > 100) {
      _sessionHistory.removeLast();
    }

    // 통계 업데이트
    _totalTimeSpent += timeSpent;
    if (cpm > _highestCpm) {
      _highestCpm = cpm;
    }
    if (accuracy > _highestAccuracy) {
      _highestAccuracy = accuracy;
    }

    await _saveStats();
    notifyListeners();
  }

  // 우주 디펜스 세션 저장
  Future<void> saveDefenseModeSession({
    required int score,
    required int wave,
    required int defeated,
  }) async {
    final session = SessionData(
      type: SessionType.spaceDefense,
      dateTime: DateTime.now(),
      timeSpent: wave * 30, // 웨이브당 약 30초로 추정
      score: score,
      wave: wave,
      enemiesDefeated: defeated,
    );

    _sessionHistory.insert(0, session);
    if (_sessionHistory.length > 100) {
      _sessionHistory.removeLast();
    }

    // 통계 업데이트
    _totalTimeSpent += session.timeSpent;
    if (score > _highestScore) {
      _highestScore = score;
    }
    if (wave > _highestWave) {
      _highestWave = wave;
    }

    await _saveStats();
    notifyListeners();
  }

  // 모든 통계 삭제
  Future<void> clearAllStats() async {
    _sessionHistory.clear();
    _totalTimeSpent = 0;
    _highestCpm = 0;
    _highestAccuracy = 0.0;
    _highestWave = 0;
    _highestScore = 0;

    await _saveStats();
    notifyListeners();
  }

  // === 데이터 접근 메서드 ===

  // 모든 세션
  List<SessionData> get allSessions => List.unmodifiable(_sessionHistory);

  // 최근 세션
  List<SessionData> get recentSessions => _sessionHistory.take(10).toList();

  // 기본 연습 세션
  List<SessionData> get basicPracticeSessions => _sessionHistory
      .where((s) => s.type == SessionType.basicPractice)
      .toList();

  // 시간 도전 세션
  List<SessionData> get timeChallengeSessions => _sessionHistory
      .where((s) => s.type == SessionType.timeChallenge)
      .toList();

  // 우주 디펜스 세션
  List<SessionData> get defenseModeSessions =>
      _sessionHistory.where((s) => s.type == SessionType.spaceDefense).toList();

  // === 통계 접근 메서드 ===

  // 총 세션 수
  int get totalSessionCount => _sessionHistory.length;

  // 총 입력 문자 수
  int get totalCharTyped =>
      _sessionHistory.fold(0, (sum, session) => sum + session.charsTyped);

  // 총 연습 시간 (분)
  int get totalTimeSpent => _totalTimeSpent;

  // 총 단어 수
  int get totalWordsTyped =>
      _sessionHistory.fold(0, (sum, session) => sum + session.wordsTyped);

  // 평균 CPM
  int get averageCpm {
    if (_sessionHistory.isEmpty) return 0;

    final cpmSessions = _sessionHistory.where((s) => s.cpm > 0).toList();

    if (cpmSessions.isEmpty) return 0;

    final totalCpm = cpmSessions.fold(0, (sum, session) => sum + session.cpm);
    return totalCpm ~/ cpmSessions.length;
  }

  // 기본 연습 평균 CPM
  double get basicPracticeAvgCpm {
    final sessions = basicPracticeSessions;
    if (sessions.isEmpty) return 0;

    final totalCpm = sessions.fold(0, (sum, session) => sum + session.cpm);
    return totalCpm / sessions.length;
  }

  // 시간 도전 평균 CPM
  double get timeChallengeAvgCpm {
    final sessions = timeChallengeSessions;
    if (sessions.isEmpty) return 0;

    final totalCpm = sessions.fold(0, (sum, session) => sum + session.cpm);
    return totalCpm / sessions.length;
  }

  // 우주 디펜스 평균 CPM
  double get defenseModeAvgCpm {
    final sessions = defenseModeSessions;
    if (sessions.isEmpty) return 0;

    // 우주 디펜스는 점수를 기준으로 CPM 계산
    final totalScore = sessions.fold(0, (sum, session) => sum + session.score);
    final totalTime =
        sessions.fold(0, (sum, session) => sum + session.timeSpent);

    if (totalTime <= 0) return 0;
    return totalScore / totalTime * 60;
  }

  // 정확도 (%)
  double get accuracy {
    if (_sessionHistory.isEmpty) return 0;

    final accuracySessions =
        _sessionHistory.where((s) => s.accuracy > 0).toList();

    if (accuracySessions.isEmpty) return 0;

    final totalAccuracy =
        accuracySessions.fold(0.0, (sum, session) => sum + session.accuracy);
    return totalAccuracy / accuracySessions.length;
  }

  // 최고 웨이브
  int get highestWave => _highestWave;

  // 최고 점수
  int get highestScore => _highestScore;

  // 일평균 세션 수
  double get dailyAvgSessions {
    if (_sessionHistory.isEmpty) return 0;

    // 첫 세션과 가장 최근 세션 사이의 일수 계산
    final firstSession = _sessionHistory.last.dateTime;
    final latestSession = _sessionHistory.first.dateTime;
    final daysDifference = latestSession.difference(firstSession).inDays;

    if (daysDifference <= 0) return _sessionHistory.length.toDouble();
    return _sessionHistory.length / (daysDifference + 1);
  }

  // 일평균 연습 시간
  double get dailyAvgTimeSpent {
    if (_sessionHistory.isEmpty) return 0;

    // 첫 세션과 가장 최근 세션 사이의 일수 계산
    final firstSession = _sessionHistory.last.dateTime;
    final latestSession = _sessionHistory.first.dateTime;
    final daysDifference = latestSession.difference(firstSession).inDays;

    if (daysDifference <= 0) return _totalTimeSpent.toDouble();
    return _totalTimeSpent / (daysDifference + 1);
  }

  // 일평균 CPM
  double get dailyAvgCpm {
    // 마지막 7일간의 평균 CPM
    final last7Days = DateTime.now().subtract(Duration(days: 7));

    final recentSessions =
        _sessionHistory.where((s) => s.dateTime.isAfter(last7Days)).toList();

    if (recentSessions.isEmpty) return averageCpm.toDouble();

    final totalCpm =
        recentSessions.fold(0, (sum, session) => sum + session.cpm);
    return totalCpm / recentSessions.length;
  }

  // CPM 성장률 (%)
  double get cpmImprovementPercent {
    // 현재 주의 평균 CPM을 이전 주의 평균 CPM과 비교
    final currentWeekStart =
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final lastWeekStart = currentWeekStart.subtract(Duration(days: 7));

    final currentWeekSessions = _sessionHistory
        .where((s) => s.dateTime.isAfter(currentWeekStart))
        .toList();

    final lastWeekSessions = _sessionHistory
        .where((s) =>
            s.dateTime.isAfter(lastWeekStart) &&
            s.dateTime.isBefore(currentWeekStart))
        .toList();

    if (lastWeekSessions.isEmpty) return 0;

    final currentWeekAvgCpm = currentWeekSessions.isEmpty
        ? 0
        : currentWeekSessions.fold(0, (sum, session) => sum + session.cpm) /
            currentWeekSessions.length;

    final lastWeekAvgCpm =
        lastWeekSessions.fold(0, (sum, session) => sum + session.cpm) /
            lastWeekSessions.length;

    if (lastWeekAvgCpm <= 0) return 0;
    return (currentWeekAvgCpm - lastWeekAvgCpm) / lastWeekAvgCpm * 100;
  }
}
