// 오디오 서비스
// 작성: 2024-05-15
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
}

/// 앱의 음향 효과를 관리하는 서비스
class AudioService {
  // 싱글톤 인스턴스
  static AudioService? _instance;

  // 오디오 플레이어
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Map<SoundType, AudioPlayer> _soundPlayers = {};

  // 현재 재생 중인 음악 트랙
  MusicTrack? _currentTrack;

  // 오디오 사용 가능 여부
  bool _audioEnabled = true;

  // 웹 환경 여부
  final bool _isWeb = kIsWeb;

  // 생성자
  AudioService._create() {
    // 웹 환경이면 오디오 버그가 있을 수 있으므로 비활성화
    if (_isWeb) {
      _audioEnabled = false;
      if (kDebugMode) {
        print('Web 환경에서 오디오 서비스를 비활성화합니다. 사운드가 지원되지 않습니다.');
      }
    }
  }

  // 팩토리 생성자
  factory AudioService() {
    _instance ??= AudioService._create();
    return _instance!;
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

  // 초기화
  Future<void> initialize() async {
    if (!_audioEnabled) return; // 오디오 비활성화 상태면 초기화 건너뜀

    try {
      // 효과음 플레이어 초기화
      for (final soundType in SoundType.values) {
        _soundPlayers[soundType] = AudioPlayer();
      }
    } catch (e) {
      if (kDebugMode) {
        print('오디오 서비스 초기화 오류: $e');
        // 웹 환경에서는 오류가 발생할 수 있으므로, 오류가 발생하면 오디오를 비활성화합니다.
        if (_isWeb) {
          _audioEnabled = false;
          print('웹 환경에서 오디오 초기화 오류로 오디오를 비활성화합니다.');
        }
      }
    }
  }

  // 배경 음악 재생
  Future<void> playMusic(MusicTrack track) async {
    if (!_audioEnabled) return; // 오디오 비활성화 상태면 실행 안함

    try {
      // 이미 같은 트랙이 재생 중이면 무시
      if (_currentTrack == track && _musicPlayer.playing) {
        return;
      }

      // 설정에서 음량 가져오기
      final volume = SettingsController().musicVolume;

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
        // 에셋 로드 실패 시 더 이상 오류 전파하지 않음
        if (kDebugMode) {
          print('음악 에셋 로드 실패: $assetPath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('음악 재생 오류: $e');
      }
    }
  }

  // 효과음 재생
  Future<void> playSound(SoundType soundType) async {
    if (!_audioEnabled) return; // 오디오 비활성화 상태면 실행 안함

    try {
      // 설정에서 효과음 활성화 여부 및 음량 확인
      final settings = SettingsController();
      final volume = settings.soundEffectsVolume;

      // 타이핑 소리가 비활성화되어 있으면 키 입력 소리 무시
      if (soundType == SoundType.keyPress && !settings.typingSoundEnabled) {
        return;
      }

      // 효과음 플레이어 가져오기
      final player = _soundPlayers[soundType];
      if (player == null) return;

      // 이미 로드되지 않은 효과음인 경우 로드
      try {
        // AudioPlayer에는 ready 속성이 없으므로 플레이어 상태로 확인
        final duration = await player.duration;
        final needsLoad = duration == null;

        if (needsLoad) {
          String assetPath;
          switch (soundType) {
            case SoundType.keyPress:
              assetPath = 'assets/sounds/key_press.mp3';
              break;
            case SoundType.wordComplete:
              assetPath = 'assets/sounds/word_complete.mp3';
              break;
            case SoundType.error:
              assetPath = 'assets/sounds/error.mp3';
              break;
            case SoundType.countdown:
              assetPath = 'assets/sounds/countdown.mp3';
              break;
            case SoundType.gameStart:
              assetPath = 'assets/sounds/game_start.mp3';
              break;
            case SoundType.gameOver:
              assetPath = 'assets/sounds/game_over.mp3';
              break;
            case SoundType.pause:
              assetPath = 'assets/sounds/pause.mp3';
              break;
            case SoundType.tick:
              assetPath = 'assets/sounds/tick.mp3';
              break;
            case SoundType.enemyDestroyed:
              assetPath = 'assets/sounds/enemy_destroyed.mp3';
              break;
            case SoundType.playerHit:
              assetPath = 'assets/sounds/player_hit.mp3';
              break;
            case SoundType.waveUp:
              assetPath = 'assets/sounds/wave_up.mp3';
              break;
            case SoundType.buttonClick:
              assetPath = 'assets/sounds/button_click.mp3';
              break;
          }

          try {
            await player.setAsset(assetPath);
          } catch (assetError) {
            if (kDebugMode) {
              print('음향 에셋 로드 실패: $assetPath');
            }
            return; // 에셋 로드 실패 시 재생 시도하지 않음
          }
        }

        // 재생
        await player.setVolume(volume);
        await player.seek(Duration.zero);
        await player.play();
      } catch (e) {
        if (kDebugMode) {
          print('효과음 재생 오류: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('효과음 재생 오류: $e');
      }
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

  // 음악 음량 설정
  Future<void> setMusicVolume(double volume) async {
    if (!_audioEnabled) return; // 오디오 비활성화 상태면 실행 안함
    await _musicPlayer.setVolume(volume);
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
}
