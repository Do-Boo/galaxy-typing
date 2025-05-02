// 게임 통계를 저장하는 모델 클래스
// 작성: 2023-05-10
// 사용자의 게임 플레이 통계를 저장하고 관리하기 위한 데이터 모델

class GameStats {
  // 기본 타자 연습 통계
  final int totalChars; // 입력한 총 문자 수
  final int correctChars; // 정확하게 입력한 문자 수
  final int totalWords; // 입력한 총 단어 수
  final int bestCpm; // 최고 CPM (Characters Per Minute)
  final int averageCpm; // 평균 CPM
  final int totalTimeSpent; // 총 연습 시간 (초)

  // 시간 도전 통계
  final int best30SecScore; // 30초 도전 최고 점수
  final int best60SecScore; // 60초 도전 최고 점수
  final int best120SecScore; // 120초 도전 최고 점수

  // 우주 디펜스 게임 통계
  final int highestWave; // 최고 웨이브
  final int totalEnemiesDefeated; // 처치한 총 적 수
  final int highScore; // 최고 점수

  // 전체 통계
  final int totalSessions; // 총 세션 수
  final DateTime lastPlayed; // 마지막 플레이 날짜/시간

  // 생성자
  GameStats({
    this.totalChars = 0,
    this.correctChars = 0,
    this.totalWords = 0,
    this.bestCpm = 0,
    this.averageCpm = 0,
    this.totalTimeSpent = 0,
    this.best30SecScore = 0,
    this.best60SecScore = 0,
    this.best120SecScore = 0,
    this.highestWave = 0,
    this.totalEnemiesDefeated = 0,
    this.highScore = 0,
    this.totalSessions = 0,
    DateTime? lastPlayed,
  }) : this.lastPlayed = lastPlayed ?? DateTime.now();

  // JSON에서 객체 생성 팩토리 메서드
  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      totalChars: json['totalChars'] ?? 0,
      correctChars: json['correctChars'] ?? 0,
      totalWords: json['totalWords'] ?? 0,
      bestCpm: json['bestCpm'] ?? 0,
      averageCpm: json['averageCpm'] ?? 0,
      totalTimeSpent: json['totalTimeSpent'] ?? 0,
      best30SecScore: json['best30SecScore'] ?? 0,
      best60SecScore: json['best60SecScore'] ?? 0,
      best120SecScore: json['best120SecScore'] ?? 0,
      highestWave: json['highestWave'] ?? 0,
      totalEnemiesDefeated: json['totalEnemiesDefeated'] ?? 0,
      highScore: json['highScore'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      lastPlayed:
          json['lastPlayed'] != null
              ? DateTime.parse(json['lastPlayed'])
              : DateTime.now(),
    );
  }

  // 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'totalChars': totalChars,
      'correctChars': correctChars,
      'totalWords': totalWords,
      'bestCpm': bestCpm,
      'averageCpm': averageCpm,
      'totalTimeSpent': totalTimeSpent,
      'best30SecScore': best30SecScore,
      'best60SecScore': best60SecScore,
      'best120SecScore': best120SecScore,
      'highestWave': highestWave,
      'totalEnemiesDefeated': totalEnemiesDefeated,
      'highScore': highScore,
      'totalSessions': totalSessions,
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  // 정확도 계산 (퍼센트)
  int get accuracy {
    if (totalChars == 0) return 100;
    return ((correctChars / totalChars) * 100).round();
  }

  // 새로운 통계를 적용한 객체 생성 (불변성 유지)
  GameStats copyWith({
    int? totalChars,
    int? correctChars,
    int? totalWords,
    int? bestCpm,
    int? averageCpm,
    int? totalTimeSpent,
    int? best30SecScore,
    int? best60SecScore,
    int? best120SecScore,
    int? highestWave,
    int? totalEnemiesDefeated,
    int? highScore,
    int? totalSessions,
    DateTime? lastPlayed,
  }) {
    return GameStats(
      totalChars: totalChars ?? this.totalChars,
      correctChars: correctChars ?? this.correctChars,
      totalWords: totalWords ?? this.totalWords,
      bestCpm: bestCpm ?? this.bestCpm,
      averageCpm: averageCpm ?? this.averageCpm,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      best30SecScore: best30SecScore ?? this.best30SecScore,
      best60SecScore: best60SecScore ?? this.best60SecScore,
      best120SecScore: best120SecScore ?? this.best120SecScore,
      highestWave: highestWave ?? this.highestWave,
      totalEnemiesDefeated: totalEnemiesDefeated ?? this.totalEnemiesDefeated,
      highScore: highScore ?? this.highScore,
      totalSessions: totalSessions ?? this.totalSessions,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  // 기본 통계 객체
  static GameStats get empty => GameStats();
}
