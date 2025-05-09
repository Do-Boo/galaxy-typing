// 우주 디펜스 게임 컨트롤러
// 작성: 2024-06-15
// 우주 디펜스 게임의 로직을 관리하는 컨트롤러 클래스

import 'dart:async';
import 'dart:math';

import '../models/boss_enemy.dart';
import '../models/enemy_word_model.dart';
import '../models/game_bullet_model.dart';
import '../models/game_explosion_model.dart';
import '../models/power_up_item.dart';
import '../services/audio_service.dart';

/// 우주 디펜스 게임의 로직을 관리하는 컨트롤러 클래스
class SpaceDefenseGameController {
  // 게임 상태
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _isCountingDown = false;
  int _countdownValue = 3;

  // 게임 설정
  int _spawnInterval = 2000; // 초기 적 생성 간격 (밀리초)
  double _enemySpeed = 8.0; // 초기 적 이동 속도 (픽셀/초)

  // 게임 점수와 레벨
  int _score = 0;
  int _wave = 1;
  int _lives = 3;

  // 게임 객체
  final List<EnemyWordModel> _activeEnemies = [];
  final List<GameBulletModel> _activeBullets = [];
  final List<GameExplosionModel> _activeExplosions = [];
  int _enemySpawnCounter = 0;

  // 파워업 관련 상태
  final List<PowerUpItem> _activePowerUps = [];
  final Map<PowerUpType, DateTime> _activePowerUpEffects = {};
  bool _hasShield = false;
  double _timeSlowFactor = 1.0;

  // 보스 관련 상태
  BossEnemy? _activeBoss;
  bool _isBossActive = false;
  Timer? _bossSpecialAbilityTimer;

  // 총알 관련 상태
  bool _hasMultiShot = false; // 다중 발사 활성화 여부
  Timer? _multiShotTimer; // 다중 발사 효과 타이머

  // 타이머들
  Timer? _enemySpawnTimer;
  Timer? _effectCheckTimer;
  Timer? _itemSpawnTimer;
  Timer? _countdownTimer;

  // 서비스
  final AudioService _audioService = AudioService();

  // Random 인스턴스
  final Random _random = Random();

  // 게터
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get isGameOver => _isGameOver;
  bool get isCountingDown => _isCountingDown;
  int get countdownValue => _countdownValue;
  int get score => _score;
  int get wave => _wave;
  int get lives => _lives;
  List<EnemyWordModel> get activeEnemies => _activeEnemies;
  List<GameBulletModel> get activeBullets => _activeBullets;
  List<GameExplosionModel> get activeExplosions => _activeExplosions;
  List<PowerUpItem> get activePowerUps => _activePowerUps;
  Map<PowerUpType, DateTime> get activePowerUpEffects => _activePowerUpEffects;
  bool get hasShield => _hasShield;
  double get timeSlowFactor => _timeSlowFactor;
  BossEnemy? get activeBoss => _activeBoss;
  bool get isBossActive => _isBossActive;
  bool get hasMultiShot => _hasMultiShot;

  /// 게임 컨트롤러 생성자
  SpaceDefenseGameController();

  /// 게임 초기화
  void initGame() {
    _isPlaying = false;
    _isPaused = false;
    _isGameOver = false;
    _isCountingDown = false;
    _countdownValue = 3;
    _score = 0;
    _wave = 1;
    _lives = 3;
    _activeEnemies.clear();
    _activeBullets.clear();
    _activeExplosions.clear();
    _activePowerUps.clear();
    _activePowerUpEffects.clear();
    _hasShield = false;
    _timeSlowFactor = 1.0;
    _hasMultiShot = false;
    _activeBoss = null;
    _isBossActive = false;

    _enemySpawnTimer?.cancel();
    _effectCheckTimer?.cancel();
    _itemSpawnTimer?.cancel();
    _countdownTimer?.cancel();
    _multiShotTimer?.cancel();
    _bossSpecialAbilityTimer?.cancel();
  }

  /// 게임 시작
  void startGame() {
    // 2024-07-15: 카운트다운 타이밍 문제 해결
    // 상태 초기화 후 소리 재생

    // 상태 초기화
    _isPlaying = true;
    _isPaused = false;
    _isGameOver = false;
    _isCountingDown = true;
    _countdownValue = 3;
    _score = 0;
    _wave = 1;
    _lives = 3;
    _activeEnemies.clear();
    _activePowerUps.clear();
    _activePowerUpEffects.clear();
    _timeSlowFactor = 1.0;
    _hasShield = false;
    _spawnInterval = 3000;
    _enemySpeed = 8.0;

    _multiShotTimer?.cancel();

    // 2024-07-15: 상태 업데이트 후 소리 재생
    // 지연없이 즉시 소리 재생
    _audioService.playSound(SoundType.countdown);

    // 카운트다운 타이머 시작
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownValue--;

      // 2024-07-08: 각 초마다 카운트다운 소리를 재생하지 않음
      // 이미 countdown.mp3가 전체 카운트다운 효과음을 포함함

      if (_countdownValue <= 0) {
        timer.cancel();
        _isCountingDown = false;

        // 2024-07-08: 추가 게임 시작 효과음 재생 제거
        // countdown.mp3가 이미 전체 카운트다운 효과음을 포함함

        // 적 생성 타이머 시작
        _startEnemySpawnTimer();

        // 아이템 생성 타이머 시작
        _startItemSpawnTimer();
      }
    });
  }

  /// 적 생성 타이머 시작
  void _startEnemySpawnTimer() {
    _enemySpawnTimer?.cancel();
    _enemySpawnTimer =
        Timer.periodic(Duration(milliseconds: _spawnInterval), (_) {
      if (!_isPaused && !_isGameOver) {
        _spawnEnemy();
      }
    });
  }

  /// 아이템 생성 타이머 시작
  void _startItemSpawnTimer() {
    _itemSpawnTimer?.cancel();
    _itemSpawnTimer = Timer.periodic(
      const Duration(seconds: 10), // 10초마다 파워업 생성 시도
      (_) {
        if (!_isPaused && !_isGameOver) {
          // 20% 확률로 파워업 아이템 생성
          if (_random.nextDouble() < 0.2) {
            _spawnPowerUp();
          }
        }
      },
    );
  }

  /// 적 생성
  void _spawnEnemy() {
    // 일정 횟수마다 새로운 웨이브 시작
    _enemySpawnCounter++;
    if (_enemySpawnCounter >= 10) {
      // 10회마다 새 웨이브
      _enemySpawnCounter = 0;
      _increaseWave();
    }

    // TODO: 단어 풀에서 랜덤 단어 선택 로직 구현
    const word = "임시단어";

    // 화면 상단에 랜덤 위치 생성
    final xPos = 0.1 + (_random.nextDouble() * 0.8); // 화면 가장자리 피함

    // 적 생성
    _activeEnemies.add(
      EnemyWordModel(
        word: word,
        xPosition: xPos,
        yPosition: 0.1, // 상단에서 시작
        speed: _enemySpeed * _timeSlowFactor, // 시간 지연 효과 적용
        rotation: _random.nextDouble() * pi / 4, // 약간의 랜덤 회전
      ),
    );
  }

  /// 파워업 아이템 생성
  void _spawnPowerUp() {
    // 랜덤 파워업 타입 선택
    const powerUpTypes = PowerUpType.values;
    final randomType = powerUpTypes[_random.nextInt(powerUpTypes.length)];

    // 화면 상단에 랜덤 위치 생성
    final xPos = 0.1 + (_random.nextDouble() * 0.8); // 화면 가장자리 피함

    // 파워업 아이템 생성
    _activePowerUps.add(
      PowerUpItem(
        type: randomType,
        xPosition: xPos,
        yPosition: 0.1, // 상단에서 시작
        speed: 6.0 * _timeSlowFactor, // 적보다 조금 느림
        rotation: _random.nextDouble() * pi / 4, // 약간의 랜덤 회전
        spawnTime: DateTime.now(),
        duration: 10, // 기본 지속시간 10초
        word: "파워업", // 임시 단어
      ),
    );
  }

  /// 웨이브 증가
  void _increaseWave() {
    _wave++;

    // 효과음 재생
    _audioService.playSound(SoundType.waveUp);

    // 난이도 증가 - 생성 간격 감소, 속도 증가
    _spawnInterval = max(800, _spawnInterval - 200); // 최소 0.8초까지 감소
    _enemySpeed = min(15.0, _enemySpeed + 0.5); // 최대 15.0까지 증가

    // 타이머 재설정
    _startEnemySpawnTimer();

    // 매 2 웨이브마다 보스 생성
    if (_wave % 2 == 0 && !_isBossActive) {
      _spawnBoss();
    }
  }

  /// 보스 생성
  void _spawnBoss() {
    // TODO: 보스 생성 로직 구현
  }
}
