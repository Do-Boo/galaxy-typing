// 오디오 서비스
// 작성: 2024-05-15
// 업데이트: 2024-06-20 (볼륨 제어 및 초기화 로직 개선)
// 업데이트: 2024-07-08 (오디오 로드 실패 시 폴백 메커니즘 개선 및 gameStart 소리 로직 수정)
// 업데이트: 2024-07-09 (countdown.mp3 파일 로드 오류 해결)
// 업데이트: 2024-07-10 (효과음 로드 오류 메시지 디버깅 및 Assets 클래스 활용)
// 업데이트: 2024-07-12 (countdown.mp3 로드 문제 해결 및 효과음 오류 처리 강화)
// 업데이트: 2024-07-13 (countdown.mp3가 항상 정확한 파일을 사용하도록 로드 로직 개선)
// 업데이트: 2024-07-14 (웹에서의 countdown.mp3 로드 문제 해결을 위해 직접 button_click.mp3 사용)
// 업데이트: 2024-07-15 (카운트다운 타이밍 문제 해결 및 사전 로드 강화)
// 업데이트: 2024-07-15 (카운트다운 소리 디버깅을 위해 폴백 메커니즘 제거 및 상세 로깅 추가)
// 업데이트: 2024-07-16 (모든 효과음 로드 및 재생 로직 세분화하여 오류 추적 강화)
// 업데이트: 2024-07-17 (카운트다운 및 특정 효과음 중지 메서드 추가)
// 앱의 음향 효과를 관리하는 서비스

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../controllers/settings_controller.dart';

/// 배경 음악 트랙
enum MusicTrack {
  /// 메인 화면 음악
  main,

  /// 기본 연습 음악
  basicPractice,

  /// 시간 도전 음악
  timeChallenge,

  /// 우주 디펜스 음악
  spaceDefense,
}

/// 효과음 유형
enum SoundType {
  /// 키 입력 소리
  keyPress,

  /// 단어 완성 소리
  wordComplete,

  /// 오류 소리
  error,

  /// 카운트다운 소리
  countdown,

  /// 게임 시작 소리
  gameStart,

  /// 게임 종료 소리
  gameOver,

  /// 일시 정지 소리
  pause,

  /// 시계 틱 소리
  tick,

  /// 적 파괴 소리
  enemyDestroyed,

  /// 플레이어 피격 소리
  playerHit,

  /// 웨이브 증가 소리
  waveUp,

  /// 버튼 클릭 소리
  buttonClick,

  /// 아이템 획득 소리
  itemPickup,

  /// 아이템 효과 종료 소리
  itemExpire,

  /// 아이템 사용 소리 (대폭발 등)
  itemUse,

  /// 보호막 활성화 소리
  shieldActive,
}

/// 앱의 음향 효과를 관리하는 서비스
class AudioService {
  // 싱글톤 인스턴스
  static AudioService? _instance;

  // 오디오 플레이어
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Map<SoundType, AudioPlayer> _soundPlayers = {};

  // 효과음이 이미 성공적으로 로드되었는지 추적
  final Map<SoundType, bool> _soundLoaded = {};

  // 각 효과음 유형별 실제 경로 (대체 파일 사용 시 추적용)
  final Map<SoundType, String> _actualSoundPaths = {};

  // 오류 로그 기록
  final Map<SoundType, List<String>> _errorLogs = {};

  // 현재 재생 중인 음악 트랙
  MusicTrack? _currentTrack;

  // 오디오 사용 가능 여부
  bool _audioEnabled = true;

  // 웹 환경 여부
  final bool _isWeb = kIsWeb;

  // 초기화 완료 여부
  bool _initialized = false;

  // 초기화 진행 중 여부 (이중 초기화 방지)
  bool _initializing = false;

  // 생성자
  AudioService._create() {
    // 자동 초기화는 필요할 때만 수행하도록 변경

    // 오류 로그 초기화
    for (final soundType in SoundType.values) {
      _errorLogs[soundType] = [];
    }
  }

  // 팩토리 생성자
  factory AudioService() {
    _instance ??= AudioService._create();
    return _instance!;
  }

  // 특정 효과음의 오류 로그 가져오기
  List<String> getErrorLogs(SoundType soundType) {
    return _errorLogs[soundType] ?? [];
  }

  // 오디오 서비스 중지
  void stop() {
    try {
      _musicPlayer.stop();
      _currentTrack = null;
    } catch (e) {
      if (kDebugMode) {
        print('음악 중지 오류: $e');
      }
    }
  }

  // 음악 음량 설정
  Future<void> setMusicVolume(double volume) async {
    if (!_audioEnabled) return;

    try {
      // 재생 중인 음악의 볼륨 조절
      await _musicPlayer.setVolume(volume);
      if (kDebugMode) {
        print('음악 볼륨이 설정되었습니다: $volume');
      }
    } catch (e) {
      if (kDebugMode) {
        print('음량 조절 오류: $e');
      }
    }
  }

  // 효과음 음량 설정
  Future<void> setSoundVolume(double volume) async {
    if (!_audioEnabled) return;

    try {
      // 모든 효과음 플레이어의 볼륨 조절
      for (final player in _soundPlayers.values) {
        await player.setVolume(volume);
      }
      if (kDebugMode) {
        print('효과음 볼륨이 설정되었습니다: $volume');
      }
    } catch (e) {
      if (kDebugMode) {
        print('효과음 음량 조절 오류: $e');
      }
    }
  }

  // 초기화
  Future<void> initialize() async {
    // 이미 초기화되었거나 초기화 중이면 건너뜀
    if (_initialized || _initializing) return;
    // 오디오 비활성화 상태면 초기화 건너뜀
    if (!_audioEnabled) return;

    // 초기화 중 플래그 설정
    _initializing = true;

    try {
      if (kDebugMode) {
        print('오디오 서비스 초기화 시작...');
      }

      // 효과음 플레이어 초기화
      for (final soundType in SoundType.values) {
        _soundPlayers[soundType] = AudioPlayer();
        _soundLoaded[soundType] = false; // 모든 소리를 처음에는 로드되지 않은 상태로 설정
        _actualSoundPaths[soundType] = ''; // 실제 로드된 파일 경로를 빈 문자열로 초기화
      }

      // 현재 설정값 기반으로 볼륨 초기화
      final settings = SettingsController();
      await setMusicVolume(settings.musicVolume);
      await setSoundVolume(settings.soundEffectsVolume);

      // 웹에서 오디오 초기화를 위해 더미 사운드 한 번 로드 및 재생 (볼륨 0으로)
      if (kIsWeb) {
        try {
          await _musicPlayer.setVolume(0);
          await _musicPlayer.setAsset('assets/sounds/button_click.mp3');
          await _musicPlayer.play();
          await _musicPlayer.stop();
          await _musicPlayer.setVolume(settings.musicVolume);
        } catch (e) {
          if (kDebugMode) {
            print('웹 오디오 초기화 프라이밍 오류: $e');
          }
        }
      }

      // 중요 효과음 미리 로드
      await _preloadImportantSounds();

      _initialized = true;

      if (kDebugMode) {
        print('오디오 서비스가 초기화되었습니다.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('오디오 서비스 초기화 오류: $e');
      }
    } finally {
      // 초기화 중 플래그 해제
      _initializing = false;
    }
  }

  // 중요한 효과음 미리 로드
  Future<void> _preloadImportantSounds() async {
    try {
      // 자주 사용되는 중요 효과음 미리 로드
      final importantSounds = [
        SoundType.buttonClick, // 가장 안정적인 오디오 파일 먼저 로드
        SoundType.keyPress, // 두 번째로 안정적인 오디오 파일
        SoundType.countdown, // 카운트다운 효과음도 미리 로드
        SoundType.tick, // 틱 효과음 미리 로드
        SoundType.gameOver, // 게임 종료 효과음 미리 로드
      ];

      for (final sound in importantSounds) {
        await _preloadSound(sound);
      }
    } catch (e) {
      if (kDebugMode) {
        print('중요 효과음 미리 로드 중 오류: $e');
      }
    }
  }

  // 개별 효과음 미리 로드 (코드 중복 제거를 위한 도우미 메서드)
  Future<void> _preloadSound(SoundType soundType) async {
    final player = _soundPlayers[soundType];
    if (player == null) return;

    String assetPath = _getSoundAssetPath(soundType);
    if (assetPath.isEmpty) return;

    try {
      if (kDebugMode) {
        print('효과음 로드 시도: $assetPath (유형: $soundType)');
      }

      // 로드 시도
      await player.setAsset(assetPath);
      await player.load(); // 미리 로드하여 첫 재생 지연 시간 제거

      // 파일 정보 확인
      final duration = player.duration;
      final loadTime = DateTime.now();

      _soundLoaded[soundType] = true; // 로드 성공 표시
      _actualSoundPaths[soundType] = assetPath; // 실제 로드된 파일 경로 저장

      if (kDebugMode) {
        print(
            '효과음 로드 성공: $assetPath (길이: ${duration?.inMilliseconds ?? "알 수 없음"}ms, 로드 시간: $loadTime)');
      }
    } catch (e) {
      _soundLoaded[soundType] = false; // 로드 실패 표시

      // 상세한 오류 메시지 기록
      final errorMessage = '효과음 로드 실패: $assetPath (유형: $soundType) - $e';
      _errorLogs[soundType]?.add(errorMessage);

      if (kDebugMode) {
        print(errorMessage);
        print(
            '환경: ${kIsWeb ? "웹" : "네이티브"}, 플랫폼: ${defaultTargetPlatform.toString()}');
        print('플레이어 상태: ${player.playerState.toString()}');

        // 파일 형식 문제인지 추가 분석
        if (e.toString().contains('format')) {
          print('> 파일 형식 문제 감지됨');
        }
        if (e.toString().contains('decode')) {
          print('> 디코딩 문제 감지됨');
        }
        if (e.toString().contains('unsupported')) {
          print('> 지원되지 않는 형식 감지됨');
        }
        if (soundType == SoundType.countdown) {
          print('> 카운트다운 효과음 로드 실패! 폴백 메커니즘 없이 에러 전파');
        }
      }
    }
  }

  // 각 효과음 유형에 대한 에셋 경로 반환
  String _getSoundAssetPath(SoundType soundType) {
    switch (soundType) {
      case SoundType.buttonClick:
        return 'assets/sounds/button_click.mp3';
      case SoundType.keyPress:
        return 'assets/sounds/key_press.mp3';
      case SoundType.wordComplete:
        return 'assets/sounds/word_complete.mp3';
      case SoundType.error:
        return 'assets/sounds/error.mp3';
      case SoundType.countdown:
        return 'assets/sounds/countdown.mp3';
      case SoundType.gameOver:
        return 'assets/sounds/game_over.mp3';
      case SoundType.pause:
        return 'assets/sounds/pause.mp3';
      case SoundType.tick:
        return 'assets/sounds/tick.mp3';
      case SoundType.enemyDestroyed:
        return 'assets/sounds/enemy_destroyed.mp3';
      case SoundType.playerHit:
        return 'assets/sounds/player_hit.mp3';
      case SoundType.waveUp:
        return 'assets/sounds/wave_up.mp3';
      case SoundType.itemPickup:
        return 'assets/sounds/item_pickup.mp3';
      case SoundType.itemExpire:
        return 'assets/sounds/item_expire.mp3';
      case SoundType.itemUse:
        return 'assets/sounds/item_use.mp3';
      case SoundType.shieldActive:
        return 'assets/sounds/shield_active.mp3';
      case SoundType.gameStart:
        // gameStart는 countdown 사운드를 재사용
        return 'assets/sounds/countdown.mp3';
      default:
        return '';
    }
  }

  // 배경 음악 재생
  Future<void> playMusic(MusicTrack track) async {
    if (!_audioEnabled) return; // 오디오 비활성화 상태면 실행 안함

    // 필요한 경우 초기화
    if (!_initialized) {
      await initialize();
    }

    try {
      // 이미 같은 트랙이 재생 중이면 무시
      if (_currentTrack == track && _musicPlayer.playing) {
        return;
      }

      // 설정에서 음량 가져오기
      final volume = SettingsController().musicVolume;

      // 음악이 비활성화 되어 있는지 확인
      final isMusicEnabled = SettingsController().musicEnabled;
      if (!isMusicEnabled) {
        // 음악이 비활성화된 상태라면 곡을 로드만 하고 재생하지 않음
        await _musicPlayer.stop();
        _currentTrack = null;
        return;
      }

      // 이전 음악 중지
      await _musicPlayer.stop();

      // 새 음악 로드 및 재생
      String assetPath;
      switch (track) {
        case MusicTrack.main:
          assetPath = 'assets/sounds/main_theme.mp3';
          break;
        case MusicTrack.basicPractice:
          assetPath = 'assets/sounds/practice_theme.mp3';
          break;
        case MusicTrack.timeChallenge:
          assetPath = 'assets/sounds/challenge_theme.mp3';
          break;
        case MusicTrack.spaceDefense:
          assetPath = 'assets/sounds/space_defense_theme.mp3';
          break;
      }

      try {
        await _musicPlayer.setAsset(assetPath);
        await _musicPlayer.setLoopMode(LoopMode.all);
        await _musicPlayer.setVolume(volume);
        await _musicPlayer.play();

        _currentTrack = track;
      } catch (assetError) {
        // 에셋 로드 실패 시 자세한 오류 메시지 기록
        if (kDebugMode) {
          print('음악 에셋 로드 실패: $assetPath - $assetError');
          print(
              '환경: ${kIsWeb ? "웹" : "네이티브"}, 플랫폼: ${defaultTargetPlatform.toString()}');
          print('플레이어 상태: ${_musicPlayer.playerState.toString()}');
        }

        // 오류는 그대로 전파
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) {
        print('음악 재생 오류: $e');
      }

      // 오류는 그대로 전파
      rethrow;
    }
  }

  // 효과음 재생
  Future<void> playSound(SoundType soundType) async {
    if (!_audioEnabled) return; // 오디오 비활성화 상태면 실행 안함

    // 필요한 경우 초기화
    if (!_initialized) {
      await initialize();
    }

    try {
      // 설정에서 효과음 활성화 여부 및 음량 확인
      final settings = SettingsController();
      final volume = settings.soundEffectsVolume;
      final isSoundEnabled = settings.soundEnabled;

      // 소리가 비활성화 되어 있으면 재생하지 않음
      if (!isSoundEnabled) return;

      // 타이핑 소리가 비활성화되어 있으면 키 입력 소리 무시
      if (soundType == SoundType.keyPress && !settings.typingSoundEnabled) {
        return;
      }

      // gameStart는 countdown 소리를 재사용
      if (soundType == SoundType.gameStart) {
        soundType = SoundType.countdown;
        if (kDebugMode) {
          print('gameStart 효과음은 countdown으로 대체됨');
        }
      }

      // 효과음 플레이어 가져오기
      final player = _soundPlayers[soundType];
      if (player == null) {
        if (kDebugMode) {
          print('효과음 플레이어를 찾을 수 없음: $soundType');
        }
        throw Exception('효과음 플레이어를 찾을 수 없음: $soundType');
      }

      if (kDebugMode) {
        print('효과음 재생 요청: $soundType');
      }

      // 효과음이 로드되지 않았으면 로드 시도
      if (_soundLoaded[soundType] != true) {
        await _preloadSound(soundType);
      }

      // 효과음이 로드되었는지 다시 확인
      if (_soundLoaded[soundType] == true) {
        try {
          // 음량 설정
          await player.setVolume(volume);

          // 처음부터 재생
          await player.seek(Duration.zero);

          // 재생 시작
          await player.play();

          if (kDebugMode) {
            final path = _actualSoundPaths[soundType];
            print('효과음 재생 성공: $soundType (파일: ${path ?? "알 수 없음"})');
          }
        } catch (e) {
          // 상세한 오류 메시지 기록
          final errorMessage = '효과음 재생 오류: $soundType - $e';
          _errorLogs[soundType]?.add(errorMessage);

          if (kDebugMode) {
            print(errorMessage);
            print(
                '환경: ${kIsWeb ? "웹" : "네이티브"}, 플랫폼: ${defaultTargetPlatform.toString()}');
            print('플레이어 상태: ${player.playerState.toString()}');
          }

          // 오류 전파
          throw Exception(errorMessage);
        }
      } else {
        final errorMessage = '효과음이 로드되지 않아 재생할 수 없음: $soundType';
        if (kDebugMode) {
          print(errorMessage);
        }

        // 이전 로드 오류 내역 표시
        final previousErrors = _errorLogs[soundType] ?? [];
        if (previousErrors.isNotEmpty && kDebugMode) {
          print('이전 로드 오류 내역:');
          for (final error in previousErrors) {
            print('- $error');
          }
        }

        // 오류 전파
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('효과음 재생 중 예외 발생: $e');
      }

      // 효과음 재생 실패 오류를 상위로 전파
      rethrow;
    }
  }

  // 음악 정지
  Future<void> stopMusic() async {
    if (!_audioEnabled) return; // 오디오 비활성화 상태면 실행 안함
    await _musicPlayer.stop();
    _currentTrack = null;
  }

  // 음악 일시정지
  Future<void> pauseMusic() async {
    if (!_audioEnabled) return;

    try {
      if (_musicPlayer.playing) {
        await _musicPlayer.pause();
      }
    } catch (e) {
      if (kDebugMode) {
        print('음악 일시정지 오류: $e');
      }
    }
  }

  // 음악 재개
  Future<void> resumeMusic() async {
    if (!_audioEnabled) return;

    try {
      if (!_musicPlayer.playing && _currentTrack != null) {
        await _musicPlayer.play();
      }
    } catch (e) {
      if (kDebugMode) {
        print('음악 재개 오류: $e');
      }
    }
  }

  // 음악 음량 설정 (setVolume 대신 통일된 API 제공)
  Future<void> setVolume(double volume) async {
    if (!_audioEnabled) return;

    await setMusicVolume(volume);
  }

  // 음향 전역 활성화/비활성화 설정
  void setAudioEnabled(bool enabled) {
    _audioEnabled = enabled;

    if (!enabled) {
      // 음향이 비활성화되면 모든 소리를 중지합니다.
      _musicPlayer.stop();
      for (final player in _soundPlayers.values) {
        player.stop();
      }
    }
  }

  // 특정 트랙만 허용하고 나머지는 중지하는 메서드
  Future<void> stopMusicExcept(MusicTrack allowedTrack) async {
    if (!_audioEnabled) return;

    try {
      // 현재 다른 트랙이 재생 중이면 중지
      if (_currentTrack != null && _currentTrack != allowedTrack) {
        await _musicPlayer.stop();
        _currentTrack = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('음악 중지 오류: $e');
      }
    }
  }

  // 리소스 정리
  Future<void> dispose() async {
    if (!_audioEnabled) return; // 오디오 비활성화 상태면 실행 안함
    await _musicPlayer.dispose();
    for (final player in _soundPlayers.values) {
      await player.dispose();
    }
    _soundPlayers.clear();
  }

  // 카운트다운 효과음 중지
  void stopCountdown() {
    try {
      if (_soundPlayers.containsKey(SoundType.countdown)) {
        _soundPlayers[SoundType.countdown]!.stop();
        if (kDebugMode) {
          print('카운트다운 효과음 중지됨');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('카운트다운 효과음 중지 중 오류 발생: $e');
      }
    }
  }

  // 특정 효과음 중지
  void stopSound(SoundType soundType) {
    try {
      if (_soundPlayers.containsKey(soundType)) {
        _soundPlayers[soundType]!.stop();
        if (kDebugMode) {
          print('효과음 중지됨: $soundType');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('효과음 중지 중 오류 발생: $soundType - $e');
      }
    }
  }

  // 모든 효과음 중지
  void stopAllSounds() {
    try {
      for (final player in _soundPlayers.values) {
        player.stop();
      }
      if (kDebugMode) {
        print('모든 효과음 중지됨');
      }
    } catch (e) {
      if (kDebugMode) {
        print('모든 효과음 중지 중 오류 발생: $e');
      }
    }
  }
}
