// 게임 설정을 저장하는 모델 클래스
// 작성: 2023-05-10
// 업데이트: 2024-06-02 (다국어 지원 추가)
// 사용자 설정을 관리하기 위한 데이터 모델

/// 난이도 레벨
enum DifficultyLevel {
  /// 쉬움 - 짧고 단순한 단어
  easy,

  /// 보통 - 일반적인 단어
  medium,

  /// 어려움 - 복잡한 단어 및 특수문자
  hard,
}

/// 게임 유형
enum GameType {
  /// 기본 타자 연습
  basicPractice,

  /// 시간 도전
  timeChallenge,

  /// 우주 디펜스
  spaceDefense,
}

/// 언어 설정
enum LanguageOption {
  /// 한국어
  korean,

  /// 영어
  english,
}

enum SoundEffectLevel { off, low, medium, high }

enum GameTheme { space, neon, minimalist }

class GameSettings {
  // 게임 난이도
  final DifficultyLevel difficulty;

  // 사운드 효과 레벨
  final SoundEffectLevel soundEffects;

  // 배경 음악 볼륨 (0.0 ~ 1.0)
  final double musicVolume;

  // 사용자 입력 진동 피드백 활성화 여부
  final bool hapticFeedback;

  // 테마 설정
  final GameTheme theme;

  // 사용자 이름
  final String username;

  // 사용자 정의 단어 세트
  final List<String> customWordSets;

  // 동작 접근성 모드 (더 큰 버튼, 더 쉬운 입력)
  final bool accessibilityMode;

  // 고대비 모드
  final bool highContrastMode;

  // 자동 저장 간격 (초)
  final int autoSaveInterval;

  // 언어 설정
  final LanguageOption language;

  // 생성자
  GameSettings({
    this.difficulty = DifficultyLevel.medium,
    this.soundEffects = SoundEffectLevel.medium,
    this.musicVolume = 0.5,
    this.hapticFeedback = true,
    this.theme = GameTheme.space,
    this.username = '우주 여행자',
    this.customWordSets = const [],
    this.accessibilityMode = false,
    this.highContrastMode = false,
    this.autoSaveInterval = 60,
    this.language = LanguageOption.korean,
  });

  // JSON에서 객체 생성 팩토리 메서드
  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      difficulty: DifficultyLevel.values[json['difficulty'] ?? 1],
      soundEffects: SoundEffectLevel.values[json['soundEffects'] ?? 2],
      musicVolume: json['musicVolume']?.toDouble() ?? 0.5,
      hapticFeedback: json['hapticFeedback'] ?? true,
      theme: GameTheme.values[json['theme'] ?? 0],
      username: json['username'] ?? '우주 여행자',
      customWordSets: List<String>.from(json['customWordSets'] ?? []),
      accessibilityMode: json['accessibilityMode'] ?? false,
      highContrastMode: json['highContrastMode'] ?? false,
      autoSaveInterval: json['autoSaveInterval'] ?? 60,
      language: json['language'] != null
          ? LanguageOption.values[json['language']]
          : LanguageOption.korean,
    );
  }

  // 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.index,
      'soundEffects': soundEffects.index,
      'musicVolume': musicVolume,
      'hapticFeedback': hapticFeedback,
      'theme': theme.index,
      'username': username,
      'customWordSets': customWordSets,
      'accessibilityMode': accessibilityMode,
      'highContrastMode': highContrastMode,
      'autoSaveInterval': autoSaveInterval,
      'language': language.index,
    };
  }

  // 설정 업데이트를 위한 복사 메서드
  GameSettings copyWith({
    DifficultyLevel? difficulty,
    SoundEffectLevel? soundEffects,
    double? musicVolume,
    bool? hapticFeedback,
    GameTheme? theme,
    String? username,
    List<String>? customWordSets,
    bool? accessibilityMode,
    bool? highContrastMode,
    int? autoSaveInterval,
    LanguageOption? language,
  }) {
    return GameSettings(
      difficulty: difficulty ?? this.difficulty,
      soundEffects: soundEffects ?? this.soundEffects,
      musicVolume: musicVolume ?? this.musicVolume,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      theme: theme ?? this.theme,
      username: username ?? this.username,
      customWordSets: customWordSets ?? this.customWordSets,
      accessibilityMode: accessibilityMode ?? this.accessibilityMode,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      language: language ?? this.language,
    );
  }

  // 기본 설정 객체
  static GameSettings get defaults => GameSettings();
}
