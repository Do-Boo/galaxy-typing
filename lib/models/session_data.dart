// 세션 데이터 모델
// 작성: 2024-05-15
// 사용자의 연습 세션 데이터를 관리하는 모델 클래스

/// 세션 유형
enum SessionType {
  /// 기본 타자 연습
  basicPractice,

  /// 시간 도전
  timeChallenge,

  /// 우주 디펜스
  spaceDefense,
}

/// 사용자의 타이핑 연습 세션 데이터
class SessionData {
  /// 세션 유형
  final SessionType type;

  /// 세션 날짜 및 시간
  final DateTime dateTime;

  /// 연습 시간 (분)
  final int timeSpent;

  /// 총 입력 문자 수
  final int charsTyped;

  /// 정확하게 입력한 문자 수
  final int correctChars;

  /// 총 입력 단어 수
  final int wordsTyped;

  /// 분당 입력 문자 수 (CPM)
  final int cpm;

  /// 정확도 (%)
  final double accuracy;

  /// 우주 디펜스 모드 점수
  final int score;

  /// 우주 디펜스 모드 웨이브
  final int wave;

  /// 처치한 적 수
  final int enemiesDefeated;

  /// 생성자
  SessionData({
    required this.type,
    required this.dateTime,
    required this.timeSpent,
    this.charsTyped = 0,
    this.correctChars = 0,
    this.wordsTyped = 0,
    this.cpm = 0,
    this.accuracy = 0.0,
    this.score = 0,
    this.wave = 0,
    this.enemiesDefeated = 0,
  });

  /// JSON으로부터 객체 생성
  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      type: SessionType.values[json['type'] ?? 0],
      dateTime:
          DateTime.parse(json['dateTime'] ?? DateTime.now().toIso8601String()),
      timeSpent: json['timeSpent'] ?? 0,
      charsTyped: json['charsTyped'] ?? 0,
      correctChars: json['correctChars'] ?? 0,
      wordsTyped: json['wordsTyped'] ?? 0,
      cpm: json['cpm'] ?? 0,
      accuracy: json['accuracy'] ?? 0.0,
      score: json['score'] ?? 0,
      wave: json['wave'] ?? 0,
      enemiesDefeated: json['enemiesDefeated'] ?? 0,
    );
  }

  /// 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'dateTime': dateTime.toIso8601String(),
      'timeSpent': timeSpent,
      'charsTyped': charsTyped,
      'correctChars': correctChars,
      'wordsTyped': wordsTyped,
      'cpm': cpm,
      'accuracy': accuracy,
      'score': score,
      'wave': wave,
      'enemiesDefeated': enemiesDefeated,
    };
  }
}
