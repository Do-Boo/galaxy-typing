// 우주 디펜스 게임 화면
// 작성: 2024-05-15
// 업데이트: 2024-06-03 (웹/데스크톱에서 모바일 스타일 유지)
// 업데이트: 2024-06-05 (파워업 아이템 시스템 추가)
// 업데이트: 2024-06-10 (보스 시스템 추가)
// 우주 침략자를 막기 위해 단어를 입력하는 게임 모드 화면

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
import '../models/boss_enemy.dart';
import '../models/power_up_item.dart';
import '../models/word_data.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/back_button.dart';
import '../widgets/cosmic_button.dart';
import '../widgets/space_background.dart';

class SpaceDefenseScreen extends StatefulWidget {
  const SpaceDefenseScreen({super.key});

  @override
  _SpaceDefenseScreenState createState() => _SpaceDefenseScreenState();
}

class _SpaceDefenseScreenState extends State<SpaceDefenseScreen>
    with TickerProviderStateMixin {
  final _audioService = AudioService();
  final _random = Random();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  // 게임 상태
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _isCountingDown = false; // 카운트다운 상태 추가
  int _countdownValue = 3; // 카운트다운 값
  int _score = 0;
  int _wave = 1;
  int _lives = 3;
  List<String> _wordPool = [];
  final List<_EnemyWord> _activeEnemies = [];
  final List<_Bullet> _activeBullets = []; // 총알 목록
  final List<_Explosion> _activeExplosions = []; // 폭발 효과 목록
  int _enemySpawnCounter = 0;

  // 보스 관련 상태
  BossEnemy? _activeBoss; // 현재 활성화된 보스
  bool _isBossActive = false; // 보스 활성화 여부
  Timer? _bossSpecialAbilityTimer; // 보스 특수 능력 타이머

  // 파워업 아이템 관련 상태
  final List<PowerUpItem> _activePowerUps = []; // 화면에 표시되는 아이템들
  final Map<PowerUpType, DateTime> _activePowerUpEffects =
      {}; // 현재 활성화된 효과와 종료 시간
  double _timeSlowFactor = 1.0; // 시간 감속 효과 (1.0 = 정상 속도)
  bool _hasShield = false; // 보호막 활성화 여부
  Timer? _multiShotTimer; // 다중 공격 타이머
  Timer? _itemSpawnTimer; // 아이템 생성 타이머
  Timer? _effectCheckTimer; // 효과 지속 시간 체크 타이머

  // 애니메이션 컨트롤러
  late AnimationController _gameLoopController;

  // 타이머
  Timer? _spawnTimer;
  Timer? _difficultyTimer;
  Timer? _countdownTimer; // 카운트다운 타이머

  // 게임 설정
  int _spawnInterval = 2000; // 초기 적 생성 간격 (밀리초)
  double _enemySpeed = 8.0; // 초기 적 이동 속도 (픽셀/초) - 속도 대폭 감소

  @override
  void initState() {
    super.initState();

    // 배경 음악 재생
    _audioService.stopMusicExcept(MusicTrack.spaceDefense); // 다른 모든 음악 중지
    _audioService.playMusic(MusicTrack.spaceDefense);

    // 게임 루프 애니메이션 컨트롤러 설정
    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // 단어 풀 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWordPool();

      // 효과 체크 타이머 시작
      _startEffectCheckTimer();
    });

    // 텍스트 입력 리스너
    _inputController.addListener(_checkInput);
  }

  @override
  void dispose() {
    // 타이머 및 애니메이션 정리
    _gameLoopController.dispose();
    _spawnTimer?.cancel();
    _difficultyTimer?.cancel();
    _countdownTimer?.cancel();
    _itemSpawnTimer?.cancel();
    _multiShotTimer?.cancel();
    _effectCheckTimer?.cancel();
    _bossSpecialAbilityTimer?.cancel();

    // 배경 음악 중지
    _audioService.stop();

    // 컨트롤러 정리
    _inputController.removeListener(_checkInput);
    _inputController.dispose();
    _inputFocusNode.dispose();

    super.dispose();
  }

  // 단어 풀 로드
  void _loadWordPool() {
    final settingsController = Provider.of<SettingsController>(
      context,
      listen: false,
    );

    // 난이도와 언어에 따라 단어 가져오기
    _wordPool = WordData.getSpaceDefenseWords(
      settingsController.difficulty,
      language: settingsController.language,
    );

    if (_wordPool.isEmpty) {
      // 기본 단어 사용 (프로덕션에서는 사용하지 않음)
      _wordPool = [
        'earth',
        'rocket',
        'space',
        'moon',
        'star',
        'planet',
        'galaxy',
      ];
    }
  }

  // 게임 시작
  void _startGame() {
    // 상태 초기화
    setState(() {
      _isPlaying = true;
      _isPaused = false;
      _isGameOver = false;
      _isCountingDown = true; // 카운트다운 시작
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
      _enemySpeed = 8.0; // 초기 속도 값 대폭 감소

      _multiShotTimer?.cancel();
    });

    // 입력 필드 초기화 및 포커스
    _inputController.clear();
    _inputFocusNode.requestFocus();

    // 카운트다운 타이머 시작
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownValue--;
      });

      // 효과음 재생
      _audioService.playSound(SoundType.countdown);

      if (_countdownValue <= 0) {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
        });

        // 게임 시작 효과음
        _audioService.playSound(SoundType.gameStart);

        // 적 생성 타이머 시작
        _startSpawnTimer();

        // 난이도 증가 타이머 시작
        _startDifficultyTimer();

        // 아이템 생성 타이머 시작 - 별도 함수 호출로 변경
        _startItemSpawnTimer();
      }
    });
  }

  // 적 생성 타이머 시작
  void _startSpawnTimer() {
    _spawnTimer?.cancel();

    // 웨이브에 따라 스폰 간격 추가 조정 (웨이브가 높을수록 적 생성 간격이 더 불규칙적으로)
    final baseInterval = _spawnInterval;
    final randomVariation = _wave > 3 ? 0.3 : 0.2; // 웨이브 3 이상부터 변동폭 증가

    _spawnTimer = Timer.periodic(Duration(milliseconds: baseInterval), (_) {
      if (!_isPaused && _isPlaying) {
        // 다음 스폰까지 약간의 랜덤 지연 추가 (게임이 예측 불가능하게)
        final nextSpawnDelay = (baseInterval *
                (1.0 -
                    randomVariation +
                    _random.nextDouble() * randomVariation * 2))
            .toInt();
        _spawnTimer?.cancel();

        // 적 생성
        _spawnEnemy();

        // 다음 스폰 타이머 설정
        _spawnTimer = Timer(Duration(milliseconds: nextSpawnDelay), () {
          _startSpawnTimer();
        });
      }
    });
  }

  // 아이템 생성 타이머 시작
  void _startItemSpawnTimer() {
    _itemSpawnTimer?.cancel();

    // 첫 아이템은 게임 시작 후 10초 뒤에 등장
    const initialDelay = 10000;

    if (kDebugMode) {
      print('아이템 생성 타이머 시작: $initialDelay ms 후 첫 아이템 생성 예정');
    }

    _itemSpawnTimer = Timer(const Duration(milliseconds: initialDelay), () {
      if (!_isPaused && _isPlaying) {
        // 파워업 아이템 생성
        _spawnPowerUpItem();

        // 다음 아이템 생성 간격 조정 (웨이브가 높을수록 더 자주 등장)
        final nextInterval = max(8000, 15000 - (_wave * 500)); // 간격 줄임
        const randomVariation = 3000; // 변동폭 줄임
        final nextSpawnDelay = nextInterval + _random.nextInt(randomVariation);

        if (kDebugMode) {
          print('다음 아이템 생성 예정: $nextSpawnDelay ms 후');
        }

        // 다음 아이템 생성 타이머 설정
        _itemSpawnTimer = Timer(Duration(milliseconds: nextSpawnDelay), () {
          // 재귀 호출이 아닌 별도 함수 호출로 변경
          if (_isPlaying && !_isPaused) {
            _startItemSpawnTimer();
          }
        });
      }
    });
  }

  // 파워업 아이템 생성
  void _spawnPowerUpItem() {
    if (_wordPool.isEmpty) return;

    // 아이템 유형 선택 (랜덤)
    const powerUpTypes = PowerUpType.values;
    final selectedType = powerUpTypes[_random.nextInt(powerUpTypes.length)];

    // 희귀도에 따른 아이템 등장 확률 조정
    double spawnChance;
    int duration;

    switch (selectedType) {
      case PowerUpType.slowTime:
        spawnChance = 0.3; // 확률 높임 (70% → 30%)
        duration = 15;
        break;
      case PowerUpType.multiShot:
        spawnChance = 0.5;
        duration = 10;
        break;
      case PowerUpType.shield:
        spawnChance = 0.6;
        duration = 20;
        break;
      case PowerUpType.extraLife:
        spawnChance = 0.7;
        duration = 0;
        break;
      case PowerUpType.explosion:
        spawnChance = 0.65;
        duration = 0;
        break;
    }

    // 확률 체크 (Random.nextDouble은 0.0 이상 1.0 미만의 값 반환)
    // 반환된 값이 spawnChance보다 작을 때 아이템 생성 (즉, 낮은 spawnChance 값이 높은 확률)
    if (_random.nextDouble() > spawnChance) {
      if (kDebugMode) {
        print('아이템 생성 실패: ${selectedType.name}, 확률: $spawnChance');
      }
      return;
    }

    if (kDebugMode) {
      print('아이템 생성 성공: ${selectedType.name}, 지속시간: $duration초');
    }

    // 단어 풀에서 아이템용 단어 선택 (짧은 단어 선호)
    List<String> shortWords =
        _wordPool.where((word) => word.length <= 5).toList();
    final wordPool = shortWords.isEmpty ? _wordPool : shortWords;
    final word = wordPool[_random.nextInt(wordPool.length)];

    // 랜덤 X 좌표 (화면 가로 영역 내)
    final xPos = _random.nextDouble() * 0.8 + 0.1; // 화면 너비의 10% ~ 90% 사이

    // 아이템 생성
    setState(() {
      _activePowerUps.add(
        PowerUpItem(
          type: selectedType,
          xPosition: xPos,
          yPosition: 0.0, // 화면 최상단
          speed: _enemySpeed * 0.5, // 적보다 느리게 이동
          rotation: _random.nextDouble() * 0.2 - 0.1, // 약간의 기울기
          spawnTime: DateTime.now(),
          duration: duration,
          word: word,
        ),
      );
    });
  }

  // 파워업 효과 비활성화
  void _deactivatePowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.slowTime:
        _timeSlowFactor = 1.0; // 속도 원상복구
        break;
      case PowerUpType.multiShot:
        _multiShotTimer?.cancel();
        break;
      case PowerUpType.shield:
        _hasShield = false;
        break;
      case PowerUpType.extraLife:
      case PowerUpType.explosion:
        // 즉시 효과는 비활성화 로직 필요 없음
        break;
    }

    // 효과 종료 소리
    _audioService.playSound(SoundType.itemExpire);
  }

  // 파워업 아이템 획득
  void _acquirePowerUp(int index) {
    if (index < 0 || index >= _activePowerUps.length) return;

    final powerUp = _activePowerUps[index];

    // 아이템 효과 적용
    switch (powerUp.type) {
      case PowerUpType.slowTime:
        _activatePowerUp(powerUp.type, powerUp.duration);
        _timeSlowFactor = 0.5; // 적 속도 50% 감소
        break;

      case PowerUpType.multiShot:
        _activatePowerUp(powerUp.type, powerUp.duration);
        _startMultiShotEffect(powerUp.duration);
        break;

      case PowerUpType.shield:
        _activatePowerUp(powerUp.type, powerUp.duration);
        _hasShield = true;
        _audioService.playSound(SoundType.shieldActive);
        break;

      case PowerUpType.extraLife:
        // 생명력 즉시 회복 (최대 3까지)
        setState(() {
          _lives = min(3, _lives + 1);
        });
        _audioService.playSound(SoundType.itemUse);
        break;

      case PowerUpType.explosion:
        // 화면의 모든 적 파괴
        _triggerExplosionEffect();
        _audioService.playSound(SoundType.itemUse);
        break;
    }

    // 아이템 제거
    setState(() {
      _activePowerUps.removeAt(index);
    });

    // 아이템 획득 효과음
    _audioService.playSound(SoundType.itemPickup);
  }

  // 파워업 효과 활성화
  void _activatePowerUp(PowerUpType type, int durationSeconds) {
    final endTime = DateTime.now().add(Duration(seconds: durationSeconds));
    setState(() {
      _activePowerUpEffects[type] = endTime;
    });
  }

  // 다중 공격 효과 시작
  void _startMultiShotEffect(int durationSeconds) {
    _multiShotTimer?.cancel();
    _multiShotTimer = Timer.periodic(const Duration(milliseconds: 1500), (
      timer,
    ) {
      if (!_isPlaying || _isPaused) return;

      // 적이 있는 경우 무작위로 하나 공격
      if (_activeEnemies.isNotEmpty) {
        final targetIndex = _random.nextInt(_activeEnemies.length);
        final enemy = _activeEnemies[targetIndex];

        // 총알 발사
        _fireBullet(enemy.xPosition, enemy.yPosition);

        // 적 파괴
        _destroyEnemy(targetIndex);
      }
    });

    // 지정된 시간 후 효과 종료
    Future.delayed(Duration(seconds: durationSeconds), () {
      _multiShotTimer?.cancel();
    });
  }

  // 폭발 효과 트리거 (모든 적 파괴)
  void _triggerExplosionEffect() {
    if (_activeEnemies.isEmpty) return;

    // 화면 중앙에 큰 폭발 효과 추가
    setState(() {
      _activeExplosions.add(
        _Explosion(
          xPosition: 0.5, // 화면 중앙 X
          yPosition: 0.5, // 화면 중앙 Y
          size: 100.0, // 매우 큰 폭발
          startTime: DateTime.now(),
        ),
      );
    });

    // 모든 적에 대한 점수 계산 및 파괴
    int totalScore = 0;

    // 리스트를 복사하여 반복 중 수정 문제 방지
    final enemiesToDestroy = List<_EnemyWord>.from(_activeEnemies);

    for (final enemy in enemiesToDestroy) {
      totalScore += enemy.word.length * 10;

      // 각 적 위치에 작은 폭발 효과 추가
      _activeExplosions.add(
        _Explosion(
          xPosition: enemy.xPosition,
          yPosition: enemy.yPosition,
          size: 20.0 + enemy.word.length * 2.0,
          startTime: DateTime.now().add(const Duration(milliseconds: 100)),
        ),
      );
    }

    // 점수 추가 및 적 제거
    setState(() {
      _score += totalScore;
      _activeEnemies.clear();
    });
  }

  // 난이도 증가 타이머 시작
  void _startDifficultyTimer() {
    _difficultyTimer?.cancel();
    _difficultyTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      // 45초에서 60초로 증가
      if (!_isPaused && _isPlaying) {
        _increaseWave();
      }
    });
  }

  // 웨이브 증가 (난이도 상승)
  void _increaseWave() {
    setState(() {
      _wave++;
      _spawnInterval = max(
        1800,
        _spawnInterval - 150,
      ); // 생성 간격 감소 폭 감소 (최소 1.8초)
      _enemySpeed = min(30.0, _enemySpeed + 2.0); // 속도 증가 폭 감소 (최대 30 픽셀/초)
    });

    // 2의 배수 웨이브마다 보스 출현
    if (_wave % 2 == 0) {
      _spawnBoss();
    }

    // 웨이브 변경에 따른 타이머 재설정
    _startSpawnTimer();
  }

  // 보스 생성
  void _spawnBoss() {
    if (_wordPool.isEmpty || _isBossActive) return;

    // 이미 보스가 있는 경우 기존 보스 제거
    if (_activeBoss != null) {
      setState(() {
        _activeBoss = null;
        _isBossActive = false;
      });
      _bossSpecialAbilityTimer?.cancel();
    }

    // 보스 유형 결정 (웨이브에 따라 다른 유형)
    BossType bossType;
    switch (_wave % 6) {
      case 2:
        bossType = BossType.destroyer; // 파괴자 보스
        break;
      case 4:
        bossType = BossType.splitter; // 분열자 보스
        break;
      case 0:
        bossType = BossType.summoner; // 소환자 보스
        break;
      default:
        bossType = BossType.destroyer; // 기본값
    }

    // 보스에 할당할 단어 생성 (긴 단어 위주)
    final List<String> bossWords = [];
    final longWords = _wordPool.where((word) => word.length >= 5).toList();
    final availableWords = longWords.isEmpty ? _wordPool : longWords;

    // 웨이브에 따라 단어 수 증가 (최소 2개, 웨이브가 높을수록 더 많은 단어)
    final wordCount = 2 + (_wave ~/ 4);

    for (int i = 0; i < wordCount; i++) {
      if (availableWords.isNotEmpty) {
        final wordIndex = _random.nextInt(availableWords.length);
        bossWords.add(availableWords[wordIndex]);
      }
    }

    if (bossWords.isEmpty) return; // 단어가 없으면 보스 생성 안함

    // 보스 체력 계산 (웨이브와 보스 타입에 따라 다름)
    int health = 5; // 기본값 설정
    switch (bossType) {
      case BossType.destroyer:
        health = 5 + (_wave ~/ 2); // 파괴자는 높은 체력
        break;
      case BossType.splitter:
        health = 3 + (_wave ~/ 4); // 분열자는 중간 체력
        break;
      case BossType.summoner:
        health = 3 + (_wave ~/ 6); // 소환자는 낮은 체력
        break;
    }

    // 랜덤 X 좌표
    final xPos = _random.nextDouble() * 0.6 + 0.2; // 화면 너비의 20% ~ 80% 사이

    // 보스 생성 - Y 위치는 상단에 고정
    setState(() {
      _activeBoss = BossEnemy(
        type: bossType,
        xPosition: xPos,
        yPosition: 0.1, // 화면 상단에 고정 (10% 지점)
        speed: 0, // 움직이지 않음
        rotation: _random.nextDouble() * 0.1 - 0.05, // 약간의 기울기
        spawnTime: DateTime.now(),
        words: bossWords,
        health: health,
        scale: 1.5, // 일반 적보다 1.5배 큰 크기
        specialAbilityInterval: 8000, // 8초마다 특수 능력 사용
      );
      _isBossActive = true;
    });

    // 보스 등장 효과음
    _audioService.playSound(SoundType.waveUp); // 보스 등장용으로 waveUp 사용

    // 보스 특수 능력 타이머 시작
    _startBossSpecialAbilityTimer();

    if (kDebugMode) {
      print('보스 출현: ${bossType.name}, 체력: $health, 단어 수: ${bossWords.length}');
    }
  }

  // 보스 특수 능력 타이머 시작
  void _startBossSpecialAbilityTimer() {
    _bossSpecialAbilityTimer?.cancel();
    if (_activeBoss == null) return;

    _bossSpecialAbilityTimer = Timer.periodic(
      Duration(milliseconds: _activeBoss!.specialAbilityInterval),
      (_) {
        if (!_isPlaying || _isPaused || _activeBoss == null) return;

        // 보스 특수 능력 발동
        _useBossSpecialAbility();
      },
    );
  }

  // 보스 특수 능력 사용
  void _useBossSpecialAbility() {
    if (_activeBoss == null) return;

    setState(() {
      _activeBoss!.isSpecialAbilityActive = true;
      _activeBoss!.updateSpecialAbilityTime();
    });

    switch (_activeBoss!.type) {
      case BossType.destroyer:
        // 파괴자 - 강력한 공격 (플레이어 방향으로 투사체)
        // 화면 가로 중앙, 하단을 향해 대형 투사체 발사
        _fireBossBullet(0.5, 0.85);
        _audioService.playSound(SoundType.enemyDestroyed); // 강한 공격 효과음
        break;

      case BossType.splitter:
        // 분열자 - 여러 방향으로 공격
        // 여러 개의 투사체를 산탄식으로 발사
        for (int i = 0; i < 3; i++) {
          final targetX = 0.3 + (i * 0.2); // 왼쪽, 중앙, 오른쪽으로 발사
          _fireBossBullet(targetX, 0.8);
        }
        _audioService.playSound(SoundType.itemUse); // 다중 발사 효과음
        break;

      case BossType.summoner:
        // 소환자 - 적 여러 개 소환
        // 화면에 작은 적 3개 추가
        for (int i = 0; i < 3; i++) {
          _spawnEnemy();
        }
        _audioService.playSound(SoundType.itemUse); // 소환 효과음
        break;
    }

    // 특수 능력 활성화 상태 해제 (시각적 효과용)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_activeBoss != null) {
        setState(() {
          _activeBoss!.isSpecialAbilityActive = false;
        });
      }
    });
  }

  // 보스 총알 발사
  void _fireBossBullet(double targetX, double targetY) {
    setState(() {
      _activeBullets.add(
        _Bullet(
          startX: _activeBoss!.xPosition,
          startY: _activeBoss!.yPosition + 0.1, // 보스 아래쪽에서 시작
          targetX: targetX,
          targetY: targetY,
          speed: 0.015, // 일반 총알보다 약간 느림
          startTime: DateTime.now(),
          isEnemyBullet: true, // 적의 총알
          size: 15.0, // 일반 총알보다 큼
        ),
      );
    });
  }

  // 적 (단어) 생성
  void _spawnEnemy() {
    if (_wordPool.isEmpty) return;

    // 랜덤 단어 선택
    final wordIndex = _random.nextInt(_wordPool.length);
    final word = _wordPool[wordIndex];

    // 랜덤 X 좌표 (화면 가로 영역 내)
    final xPos = _random.nextDouble() * 0.8 + 0.1; // 화면 너비의 10% ~ 90% 사이

    // 단어 길이에 따른 속도 조정 - 짧은 단어는 빠르게, 긴 단어는 느리게
    double speedMultiplier = 1.0;
    if (word.length <= 3) {
      speedMultiplier = 1.05; // 짧은 단어는 약간 빠르게 (110%→105%)
    } else if (word.length >= 7) {
      speedMultiplier = 0.7; // 긴 단어는 더 느리게 (80%→70%)
    } else if (word.length >= 5) {
      speedMultiplier = 0.85; // 중간 길이 단어도 약간 느리게
    }

    setState(() {
      _activeEnemies.add(
        _EnemyWord(
          word: word,
          xPosition: xPos,
          yPosition: 0.0, // 화면 최상단
          speed: _enemySpeed *
              (0.65 + _random.nextDouble() * 0.3) *
              speedMultiplier, // 속도에 변화 추가 (65%~95% 범위)
          rotation: _random.nextDouble() * 0.1 - 0.05, // 약간의 기울기
        ),
      );
    });

    _enemySpawnCounter++;
  }

  // 파워업 효과 체크 타이머 시작
  void _startEffectCheckTimer() {
    _effectCheckTimer?.cancel();
    _effectCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!_isPlaying || _isPaused) return;

      final now = DateTime.now();
      bool needsUpdate = false;

      // 활성화된 효과들 확인하고 만료된 효과 제거
      _activePowerUpEffects.removeWhere((type, endTime) {
        final isExpired = now.isAfter(endTime);
        if (isExpired) {
          needsUpdate = true;
          _deactivatePowerUp(type);
        }
        return isExpired;
      });

      if (needsUpdate) {
        setState(() {});
      }
    });
  }

  // 입력 확인
  void _checkInput() {
    // 게임이 시작되지 않은 상태에서 첫 입력이 있을 경우 게임 시작
    if (!_isPlaying &&
        !_isGameOver &&
        !_isCountingDown &&
        _inputController.text.isNotEmpty) {
      _startGame();
      return;
    }

    if (!_isPlaying || _isPaused) return;

    final inputText = _inputController.text.trim().toLowerCase();
    if (inputText.isEmpty) return;

    // 보스 단어와 일치하는지 확인
    if (_activeBoss != null &&
        _activeBoss!.currentWord.toLowerCase() == inputText) {
      _hitBoss();
      _inputController.clear();
      return;
    }

    // 입력 단어와 일치하는 적 찾기
    final enemyIndex = _activeEnemies.indexWhere(
      (enemy) => enemy.word.toLowerCase() == inputText,
    );

    if (enemyIndex != -1) {
      // 적 파괴 및 점수 획득
      _destroyEnemy(enemyIndex);
      _inputController.clear();
      return;
    }

    // 입력 단어와 일치하는 아이템 찾기
    final itemIndex = _activePowerUps.indexWhere(
      (item) => item.word.toLowerCase() == inputText,
    );

    if (itemIndex != -1) {
      // 아이템 획득
      _acquirePowerUp(itemIndex);
      _inputController.clear();
    }
  }

  // 보스 타격
  void _hitBoss() {
    if (_activeBoss == null) return;

    // 현재 단어 완료 처리
    _activeBoss!.currentWordIndex++;

    // 인덱스가 배열 범위를 벗어나지 않도록 보호
    if (_activeBoss!.currentWordIndex >= _activeBoss!.words.length) {
      _destroyBoss();
      return;
    }

    // 총알 발사 - 우주선에서 보스 위치로
    _fireBullet(_activeBoss!.xPosition, _activeBoss!.yPosition);

    // 보스 체력 감소
    setState(() {
      _activeBoss!.health--;

      // 폭발 효과 추가
      _activeExplosions.add(
        _Explosion(
          xPosition: _activeBoss!.xPosition,
          yPosition: _activeBoss!.yPosition,
          size: 30.0, // 큰 폭발
          startTime: DateTime.now(),
        ),
      );

      // 점수 획득
      _score += _activeBoss!.currentWord.length * 20; // 일반 적보다 2배 점수
    });

    // 효과음 재생
    _audioService.playSound(SoundType.wordComplete); // 단어 완료 효과음 사용

    // 모든 단어 완료 또는 체력이 0이 되었는지 확인
    if (_activeBoss!.health <= 0) {
      _destroyBoss();
    }
  }

  // 적 파괴
  void _destroyEnemy(int index) {
    if (index < 0 || index >= _activeEnemies.length) return;

    final enemy = _activeEnemies[index];
    final wordLength = enemy.word.length;

    // 총알 발사 - 우주선에서 적 위치로
    _fireBullet(enemy.xPosition, enemy.yPosition);

    setState(() {
      // 점수 획득 (단어 길이에 따라 점수 차등 지급)
      _score += wordLength * 10;

      // 폭발 효과 추가
      _activeExplosions.add(
        _Explosion(
          xPosition: enemy.xPosition,
          yPosition: enemy.yPosition,
          size: min(20.0 + wordLength * 3.0, 40.0), // 단어 길이에 비례한 폭발 크기
          startTime: DateTime.now(),
        ),
      );

      // 적 제거
      _activeEnemies.removeAt(index);
    });

    // 효과음 재생
    _audioService.playSound(SoundType.enemyDestroyed);
  }

  // 총알 발사
  void _fireBullet(double targetX, double targetY) {
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      _activeBullets.add(
        _Bullet(
          startX: screenSize.width / 2 / screenSize.width, // 우주선 위치 (화면 중앙)
          startY: 0.9, // 우주선 위치 (화면 하단 근처)
          targetX: targetX,
          targetY: targetY,
          speed: 0.02, // 총알 속도
          startTime: DateTime.now(),
        ),
      );
    });
  }

  // 게임 오버 처리
  void _gameOver() {
    // 게임 종료 상태로 변경
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });

    // 타이머 정리
    _spawnTimer?.cancel();
    _difficultyTimer?.cancel();

    // 음악 중지
    _audioService.pauseMusic();

    // 효과음 재생
    _audioService.playSound(SoundType.gameOver);

    // 통계 저장
    final statsController = Provider.of<StatsController>(
      context,
      listen: false,
    );
    statsController.saveDefenseModeSession(
      score: _score,
      wave: _wave,
      defeated: _enemySpawnCounter - _activeEnemies.length,
    );

    // 결과 다이얼로그 표시
    _showGameOverDialog();
  }

  // 게임 일시정지
  void _pauseGame() {
    if (!_isPlaying || _isPaused) return;

    setState(() {
      _isPaused = true;
    });

    // 음악 일시정지
    _audioService.pauseMusic();

    // 일시정지 효과음
    _audioService.playSound(SoundType.pause);
  }

  // 게임 재개
  void _resumeGame() {
    if (!_isPaused) return;

    setState(() {
      _isPaused = false;
    });

    // 음악 재개
    _audioService.resumeMusic();

    // 입력 필드에 포커스
    _inputFocusNode.requestFocus();
  }

  // 게임 오버 다이얼로그
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLighter,
        title: Text(
          '게임 오버',
          style: AppTextStyles.titleMedium(context),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 점수 표시
            Text(
              '$_score',
              style: const TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text('점수', style: AppTextStyles.bodyMedium(context)),

            const SizedBox(height: 20),

            // 결과 통계
            _buildResultRow('최대 웨이브', '$_wave'),
            _buildResultRow(
              '처치한 적',
              '${_enemySpawnCounter - _activeEnemies.length}',
            ),
            _buildResultRow('총 생성된 적', '$_enemySpawnCounter'),

            const SizedBox(height: 12),

            // 팁: 파워업 아이템 사용
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '팁: 다양한 파워업 아이템을 활용하면 더 높은 점수를 달성할 수 있습니다!',
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startGame();
                },
                child: const Text(
                  '다시 시작',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // 메인 화면으로 돌아가기
                },
                child: const Text(
                  '나가기',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 결과 행 위젯
  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 게임 루프에서 총알과 폭발 효과 업데이트
  void _updateEffects() {
    final now = DateTime.now();
    bool needsUpdate = false;

    // 오래된 폭발 효과 제거 (1초 지속)
    _activeExplosions.removeWhere((explosion) {
      return now.difference(explosion.startTime).inMilliseconds > 1000;
    });

    // 총알 위치 업데이트 및 도착한 총알 제거
    for (int i = _activeBullets.length - 1; i >= 0; i--) {
      final bullet = _activeBullets[i];
      final timeElapsed =
          now.difference(bullet.startTime).inMilliseconds / 1000.0;

      if (timeElapsed >= 1.0) {
        // 총알이 목표에 도달
        _activeBullets.removeAt(i);
        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      setState(() {});
    }
  }

  // 아이템 위치 업데이트
  void _updatePowerUps(double screenHeight) {
    final toRemove = <int>[];
    bool needsUpdate = false;

    for (int i = 0; i < _activePowerUps.length; i++) {
      final item = _activePowerUps[i];

      // 시간 감속 효과 적용
      item.yPosition += item.speed * _timeSlowFactor / 12000;

      // 화면 하단을 벗어난 아이템 제거
      if (item.yPosition > 1.0) {
        toRemove.add(i);
        needsUpdate = true;
      }
    }

    // 제거할 아이템이 있는 경우
    if (toRemove.isNotEmpty) {
      // 역순으로 제거 (인덱스 변화 방지)
      for (int i = toRemove.length - 1; i >= 0; i--) {
        if (toRemove[i] < _activePowerUps.length) {
          _activePowerUps.removeAt(toRemove[i]);
        }
      }
    }

    // UI 갱신이 필요한 경우에만 setState 호출
    if (needsUpdate) {
      setState(() {});
    }
  }

  // 적 위치 업데이트
  void _updateEnemies(double screenHeight) {
    final toRemove = <int>[];
    bool needsUpdate = false;

    for (int i = 0; i < _activeEnemies.length; i++) {
      final enemy = _activeEnemies[i];
      // 시간 감속 효과 적용
      enemy.yPosition += enemy.speed * _timeSlowFactor / 12000;

      // 화면 하단에 도달한 적 (95% 지점으로 조정 - 우주선과 충돌)
      if (enemy.yPosition > 0.95) {
        toRemove.add(i);

        // 보호막이 있으면 생명력 감소 없이 보호막만 소멸
        if (_hasShield) {
          _hasShield = false;
          _activePowerUpEffects.remove(PowerUpType.shield);
          _audioService.playSound(SoundType.shieldActive);
          needsUpdate = true;
        } else {
          _lives--; // 생명력 감소
          needsUpdate = true;
          // 효과음 재생
          _audioService.playSound(SoundType.playerHit);
        }
      }
    }

    // 제거할 적이 있는 경우
    if (toRemove.isNotEmpty) {
      // 역순으로 제거 (인덱스 변화 방지)
      for (int i = toRemove.length - 1; i >= 0; i--) {
        if (toRemove[i] < _activeEnemies.length) {
          _activeEnemies.removeAt(toRemove[i]);
        }
      }

      // 생명력이 0이 되면 게임 오버
      if (_lives <= 0) {
        _gameOver();
        return; // 게임 오버 후 더 이상 처리하지 않음
      }
    }

    // UI 갱신이 필요한 경우에만 setState 호출
    if (needsUpdate) {
      setState(() {});
    }
  }

  // 게임 상태 업데이트 (setState 호출 방지를 위해 별도 메소드로 분리)
  void _updateGameState(double screenHeight) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateEnemies(screenHeight);
      _updatePowerUps(screenHeight);
      _updateBullets(screenHeight);
      _updateEffects();
    });
  }

  // 총알 업데이트 및 충돌 감지
  void _updateBullets(double screenHeight) {
    final now = DateTime.now();
    const playerPosition = Offset(0.5, 0.9); // 플레이어 위치 (화면 중앙 하단)
    const playerRadius = 0.03; // 플레이어 반경 (화면 비율)

    bool needsUpdate = false;
    List<int> bulletsToRemove = [];

    // 총알 이동 및 수명 확인
    for (int i = 0; i < _activeBullets.length; i++) {
      final bullet = _activeBullets[i];

      // 총알이 목표에 도달했거나 5초가 지나면 제거
      final timeElapsed = now.difference(bullet.startTime).inMilliseconds;
      final progress = min(1.0, timeElapsed / 1000.0 * bullet.speed * 50);

      if (progress >= 1.0 || timeElapsed > 5000) {
        bulletsToRemove.add(i);
        needsUpdate = true;
        continue;
      }

      // 적 총알이 플레이어와 충돌했는지 확인
      if (bullet.isEnemyBullet) {
        final bulletX =
            bullet.startX + (bullet.targetX - bullet.startX) * progress;
        final bulletY =
            bullet.startY + (bullet.targetY - bullet.startY) * progress;

        // 거리 계산 (피타고라스 정리)
        final distance = sqrt(
          pow(bulletX - playerPosition.dx, 2) +
              pow(bulletY - playerPosition.dy, 2),
        );

        // 충돌 감지
        if (distance < playerRadius) {
          // 보호막이 있으면 막만 제거
          if (_hasShield) {
            _hasShield = false;
            _activePowerUpEffects.remove(PowerUpType.shield);
            _audioService.playSound(SoundType.shieldActive);
          } else {
            // 생명력 감소
            _lives--;
            _audioService.playSound(SoundType.playerHit);

            // 생명력이 0이 되면 게임 오버
            if (_lives <= 0) {
              _gameOver();
              return;
            }
          }

          // 충돌한 총알 제거
          bulletsToRemove.add(i);
          needsUpdate = true;

          // 폭발 효과 추가
          _activeExplosions.add(
            _Explosion(
              xPosition: bulletX,
              yPosition: bulletY,
              size: 20.0,
              startTime: now,
            ),
          );
        }
      }
    }

    // 제거할 총알이 있으면 역순으로 제거
    if (bulletsToRemove.isNotEmpty) {
      bulletsToRemove.sort((a, b) => b.compareTo(a)); // 역순 정렬
      for (final index in bulletsToRemove) {
        if (index < _activeBullets.length) {
          _activeBullets.removeAt(index);
        }
      }
    }

    if (needsUpdate) {
      setState(() {});
    }
  }

  // 보스 파괴
  void _destroyBoss() {
    if (_activeBoss == null) return;

    final bossType = _activeBoss!.type;
    final bossPosition = Offset(_activeBoss!.xPosition, _activeBoss!.yPosition);

    // 보스 파괴에 따른 추가 점수
    setState(() {
      _score += 500 + (_wave * 50); // 기본 500점 + 웨이브당 50점 추가
    });

    // 큰 폭발 효과
    setState(() {
      _activeExplosions.add(
        _Explosion(
          xPosition: bossPosition.dx,
          yPosition: bossPosition.dy,
          size: 60.0, // 매우 큰 폭발
          startTime: DateTime.now(),
        ),
      );
    });

    // 보스 타입별 특수 효과
    switch (bossType) {
      case BossType.destroyer:
        // 파괴자는 파워업 아이템 드롭
        const powerUpTypes = PowerUpType.values;
        final selectedType = powerUpTypes[_random.nextInt(powerUpTypes.length)];
        final itemWord = _wordPool[_random.nextInt(_wordPool.length)];

        setState(() {
          _activePowerUps.add(
            PowerUpItem(
              type: selectedType,
              xPosition: bossPosition.dx,
              yPosition: bossPosition.dy,
              speed: _enemySpeed * 0.3,
              rotation: _random.nextDouble() * 0.2 - 0.1,
              spawnTime: DateTime.now(),
              duration: 15, // 기본 15초 지속
              word: itemWord,
            ),
          );
        });
        break;

      case BossType.splitter:
        // 분열자는 여러 개의 작은 적으로 분열
        for (int i = 0; i < 5; i++) {
          final xOffset = (i - 2) * 0.05;
          final newXPos = bossPosition.dx + xOffset;

          if (newXPos > 0 && newXPos < 1.0) {
            setState(() {
              _activeEnemies.add(
                _EnemyWord(
                  word: _wordPool[_random.nextInt(_wordPool.length)],
                  xPosition: newXPos,
                  yPosition: bossPosition.dy,
                  speed: _enemySpeed * 0.9,
                  rotation: _random.nextDouble() * 0.2 - 0.1,
                ),
              );
            });
          }
        }
        break;

      case BossType.summoner:
        // 소환자는 아이템 드롭
        const powerUpTypes = PowerUpType.values;
        final selectedType = powerUpTypes[_random.nextInt(powerUpTypes.length)];

        // 단어 선택 로직 안전하게 수정
        String itemWord;
        final shortWords = _wordPool.where((word) => word.length <= 5).toList();
        if (shortWords.isNotEmpty) {
          // 짧은 단어가 있으면 랜덤으로 선택
          itemWord = shortWords[_random.nextInt(shortWords.length)];
        } else {
          // 짧은 단어가 없으면 일반 단어풀에서 선택
          itemWord = _wordPool[_random.nextInt(_wordPool.length)];
        }

        setState(() {
          _activePowerUps.add(
            PowerUpItem(
              type: selectedType,
              xPosition: bossPosition.dx,
              yPosition: bossPosition.dy,
              speed: _enemySpeed * 0.3,
              rotation: _random.nextDouble() * 0.2 - 0.1,
              spawnTime: DateTime.now(),
              duration: 15, // 기본 15초 지속
              word: itemWord,
            ),
          );
        });
        break;
    }

    // 보스 제거
    setState(() {
      _activeBoss = null;
      _isBossActive = false;
    });

    // 보스 특수 능력 타이머 취소
    _bossSpecialAbilityTimer?.cancel();

    // 보스 파괴 효과음
    _audioService.playSound(SoundType.enemyDestroyed); // 적 파괴 효과음 강화
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 배경
          const SpaceBackground(),

          // 메인 콘텐츠
          SafeArea(
            child: ResponsiveHelper.centeredContent(
              context: context,
              child: Column(
                children: [
                  // 상단 바
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildTopBar(context),
                  ),

                  // 게임 영역
                  Expanded(child: _buildGameArea(context)),

                  // 하단 입력 영역
                  _buildInputArea(context),
                ],
              ),
            ),
          ),

          // 카운트다운 오버레이
          if (_isCountingDown)
            Container(
              color: AppColors.background.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('준비하세요!', style: AppTextStyles.titleLarge(context)),
                    const SizedBox(height: 24),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '$_countdownValue',
                          style: const TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 36,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '단어를 입력하여 우주선을 방어하세요',
                      style: AppTextStyles.bodyLarge(context),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 300,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLighter.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '파워업 아이템',
                            style: AppTextStyles.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '다양한 색상의 아이템을 타이핑하여 특수 능력을 획득하세요!',
                            style: AppTextStyles.bodySmall(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildPowerUpHint(
                                context,
                                Icons.hourglass_bottom,
                                Colors.lightBlue,
                                '시간 감속',
                              ),
                              _buildPowerUpHint(
                                context,
                                Icons.shield,
                                Colors.blue,
                                '보호막',
                              ),
                              _buildPowerUpHint(
                                context,
                                Icons.favorite,
                                Colors.red,
                                '생명 회복',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 일시정지 오버레이
          if (_isPaused) _buildPauseOverlay(context),

          // 게임 오버 오버레이
          if (_isGameOver && !_isPlaying)
            Container(
              color: AppColors.background.withOpacity(0.7),
              child: Center(
                child: CosmicButton(
                  label: '다시 시작',
                  icon: Icons.replay,
                  type: CosmicButtonType.primary,
                  size: CosmicButtonSize.large,
                  onPressed: _startGame,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 상단 바 구성
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        // 뒤로가기 버튼
        CosmicBackButton(
          onPressed: () {
            if (_isPlaying) {
              _showExitConfirmDialog();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),

        // 생명력 표시
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 생명력 아이콘
              ...List.generate(3, (index) {
                final isActive = index < _lives;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.favorite,
                        color:
                            isActive ? AppColors.error : AppColors.borderColor,
                        size: 24,
                      ),
                      if (index == 0 && _hasShield)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                        ),
                    ],
                  ),
                );
              }),

              // 활성화된 파워업 효과 표시
              ..._buildActivePowerUpIcons(),
            ],
          ),
        ),

        // 점수 및 웨이브 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundLighter.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_score',
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              Text('웨이브 $_wave', style: AppTextStyles.bodySmall(context)),
            ],
          ),
        ),
      ],
    );
  }

  // 활성화된 파워업 효과 아이콘 빌드
  List<Widget> _buildActivePowerUpIcons() {
    final icons = <Widget>[];

    _activePowerUpEffects.forEach((type, endTime) {
      // 보호막은 생명력 아이콘에 통합해서 표시하므로 건너뜀
      if (type == PowerUpType.shield) return;

      // 남은 시간 계산
      final now = DateTime.now();
      final remainingSeconds = endTime.difference(now).inSeconds;

      if (remainingSeconds <= 0) return;

      // 파워업 아이콘 생성
      final powerUp = PowerUpItem(
        type: type,
        xPosition: 0,
        yPosition: 0,
        speed: 0,
        rotation: 0,
        spawnTime: DateTime.now(),
        duration: 0,
        word: '',
      );

      icons.add(
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Tooltip(
            message: '${powerUp.displayName}: $remainingSeconds초',
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: powerUp.color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: powerUp.color, width: 1),
              ),
              child: Icon(powerUp.icon, color: powerUp.color, size: 14),
            ),
          ),
        ),
      );
    });

    return icons;
  }

  // 게임 영역 구성
  Widget _buildGameArea(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AnimatedBuilder(
        animation: _gameLoopController,
        builder: (context, child) {
          // 게임이 실행 중이고 일시정지 상태가 아닌 경우에만 업데이트
          if (_isPlaying && !_isPaused) {
            // 적 및 아이템 위치 업데이트 (빌드 중에 setState 호출 방지)
            _updateGameState(screenSize.height);
          }

          return Stack(
            children: [
              // 적 (단어) 렌더링
              ..._activeEnemies.map((enemy) {
                return _buildEnemy(
                  context,
                  enemy,
                  screenSize.width,
                  screenSize.height,
                );
              }),

              // 파워업 아이템 렌더링
              ..._activePowerUps.map((powerUp) {
                return _buildPowerUpItem(
                  context,
                  powerUp,
                  screenSize.width,
                  screenSize.height,
                );
              }),

              // 총알 렌더링
              ..._activeBullets.map((bullet) {
                return _buildBullet(
                  bullet,
                  screenSize.width,
                  screenSize.height,
                );
              }),

              // 폭발 효과 렌더링
              ..._activeExplosions.map((explosion) {
                return _buildExplosion(
                  explosion,
                  screenSize.width,
                  screenSize.height,
                );
              }),

              // 우주선 (하단 중앙)
              Positioned(
                bottom: 20,
                left: screenSize.width / 2 - 25,
                child: Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.rocket,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),

                    // 보호막 효과 표시
                    if (_hasShield)
                      Positioned(
                        left: -5,
                        top: -5,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.8),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 보스 렌더링
              if (_activeBoss != null)
                _buildBoss(
                  context,
                  _activeBoss!,
                  screenSize.width,
                  screenSize.height,
                ),
            ],
          );
        },
      ),
    );
  }

  // 적 (단어) 렌더링
  Widget _buildEnemy(
    BuildContext context,
    _EnemyWord enemy,
    double width,
    double height,
  ) {
    return Positioned(
      left: enemy.xPosition * width - 50, // 화면 너비에 비례한 위치
      top: enemy.yPosition * height, // 화면 높이에 비례한 위치
      child: Transform.rotate(
        angle: enemy.rotation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundLighter.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            enemy.word,
            style: AppTextStyles.bodyLarge(
              context,
            ).copyWith(color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  // 총알 렌더링
  Widget _buildBullet(_Bullet bullet, double width, double height) {
    // 시간에 따른 총알 위치 계산 (선형 보간)
    final now = DateTime.now();
    final timeElapsed =
        now.difference(bullet.startTime).inMilliseconds / 1000.0;
    final progress = min(1.0, timeElapsed * bullet.speed * 50);

    final currentX =
        bullet.startX + (bullet.targetX - bullet.startX) * progress;
    final currentY =
        bullet.startY + (bullet.targetY - bullet.startY) * progress;

    // 적 총알은 다른 색상 사용
    final bulletColor = bullet.isEnemyBullet ? Colors.red : AppColors.primary;
    final bulletSize = bullet.size;

    return Positioned(
      left: currentX * width - bulletSize / 2,
      top: currentY * height - bulletSize / 2,
      child: Container(
        width: bulletSize,
        height: bulletSize,
        decoration: BoxDecoration(
          color: bulletColor,
          borderRadius: BorderRadius.circular(bulletSize / 2),
          boxShadow: [
            BoxShadow(
              color: bulletColor.withOpacity(0.8),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  // 폭발 효과 렌더링
  Widget _buildExplosion(_Explosion explosion, double width, double height) {
    // 시간에 따른 폭발 효과 애니메이션
    final now = DateTime.now();
    final timeElapsed =
        now.difference(explosion.startTime).inMilliseconds / 1000.0; // 1초 지속

    // 시간에 따라 크기와 투명도 조정
    final size = explosion.size * (1.0 + timeElapsed); // 크기 증가
    final opacity = 1.0 - timeElapsed; // 점점 사라짐

    if (opacity <= 0) return Container(); // 완전히 투명하면 렌더링 안함

    return Positioned(
      left: explosion.xPosition * width - size / 2,
      top: explosion.yPosition * height - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.yellow.withOpacity(opacity * 0.8),
              Colors.orange.withOpacity(opacity * 0.6),
              Colors.red.withOpacity(opacity * 0.3),
              Colors.transparent,
            ],
            stops: const [0.2, 0.5, 0.7, 1.0],
          ),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // 파워업 아이템 렌더링
  Widget _buildPowerUpItem(
    BuildContext context,
    PowerUpItem powerUp,
    double width,
    double height,
  ) {
    return Positioned(
      left: powerUp.xPosition * width - 30, // 화면 너비에 비례한 위치
      top: powerUp.yPosition * height, // 화면 높이에 비례한 위치
      child: Transform.rotate(
        angle: powerUp.rotation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: powerUp.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: powerUp.color, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: powerUp.color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(powerUp.icon, color: powerUp.color, size: 18),
              const SizedBox(width: 6),
              Text(
                powerUp.word,
                style: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(color: powerUp.color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 파워업 힌트 위젯
  Widget _buildPowerUpHint(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall(context).copyWith(fontSize: 10),
        ),
      ],
    );
  }

  // 입력 영역 구성
  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter.withOpacity(0.7),
        border: const Border(
          top: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocusNode,
              enabled: _isPlaying && !_isPaused && !_isGameOver ||
                  !_isPlaying && !_isGameOver,
              onSubmitted: (_) => _inputController.clear(),
              decoration: InputDecoration(
                hintText: _isPlaying && !_isPaused
                    ? '단어를 입력하세요...'
                    : _isGameOver
                        ? '게임 오버'
                        : _isCountingDown
                            ? '카운트다운 중...'
                            : '입력을 시작하면 자동으로 게임이 시작됩니다',
                prefixIcon: const Icon(Icons.keyboard),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _inputController.clear(),
                ),
              ),
              textInputAction: TextInputAction.send,
            ),
          ),

          const SizedBox(width: 8),

          // 게임 제어 버튼 (일시정지 중 또는 게임 진행 중일 때만 표시)
          if (_isPaused || (_isPlaying && !_isGameOver && !_isCountingDown))
            IconButton(
              icon: _isPaused
                  ? const Icon(Icons.play_arrow, color: AppColors.primary)
                  : const Icon(Icons.pause, color: AppColors.warning),
              onPressed: _isPaused ? _resumeGame : _pauseGame,
              tooltip: _isPaused ? '계속하기' : '일시정지',
            ),
        ],
      ),
    );
  }

  // 일시정지 오버레이
  Widget _buildPauseOverlay(BuildContext context) {
    return Container(
      color: AppColors.background.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('일시정지', style: AppTextStyles.titleLarge(context)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CosmicButton(
                  label: '계속하기',
                  icon: Icons.play_arrow,
                  type: CosmicButtonType.primary,
                  onPressed: _resumeGame,
                ),
                const SizedBox(width: 16),
                CosmicButton(
                  label: '나가기',
                  icon: Icons.exit_to_app,
                  type: CosmicButtonType.outline,
                  onPressed: () => _showExitConfirmDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 나가기 확인 다이얼로그
  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLighter,
        title: Text('게임 종료', style: AppTextStyles.titleMedium(context)),
        content: Text(
          '게임을 종료하시겠습니까? 현재 진행 상황은 저장되지 않습니다.',
          style: AppTextStyles.bodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '계속하기',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 메인 화면으로 돌아가기
            },
            child: const Text(
              '나가기',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // 보스 렌더링
  Widget _buildBoss(
    BuildContext context,
    BossEnemy boss,
    double width,
    double height,
  ) {
    // 보스 색상 결정 (활성화 중일 때 더 밝게)
    final baseColor = boss.color;
    final bossColor = boss.isSpecialAbilityActive
        ? baseColor.withOpacity(0.9)
        : baseColor.withOpacity(0.7);

    // 보스 크기 (일반 적보다 큼)
    final size = boss.scale * 90.0;

    return Positioned(
      left: boss.xPosition * width - size / 2,
      top: boss.yPosition * height - 10.0, // 상단 고정
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 보스 체력바
          Container(
            width: size,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[600]!, width: 1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: boss.healthPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: boss.healthPercentage > 0.5
                      ? Colors.green
                      : boss.healthPercentage > 0.2
                          ? Colors.orange
                          : Colors.red,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // 보스 본체
          Stack(
            alignment: Alignment.center,
            children: [
              // 보스 몸체
              Transform.rotate(
                angle: boss.rotation,
                child: Container(
                  width: size,
                  height: size * 0.8,
                  decoration: BoxDecoration(
                    color: bossColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(size / 4),
                    border: Border.all(color: bossColor, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: bossColor.withOpacity(0.7),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(boss.icon, color: bossColor, size: size / 2),
                  ),
                ),
              ),

              // 보스 주변 빛나는 효과 (특수 능력 사용 중)
              if (boss.isSpecialAbilityActive)
                Container(
                  width: size * 1.1,
                  height: size * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: bossColor.withOpacity(0.8),
                        blurRadius: 30,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // 현재 입력해야 할 단어
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bossColor, width: 1.5),
            ),
            child: Text(
              boss.currentWord,
              style: AppTextStyles.titleSmall(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 4),

          // 보스 이름 표시
          Text(
            boss.title,
            style: AppTextStyles.bodySmall(
              context,
            ).copyWith(color: bossColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// 적 (단어) 클래스
class _EnemyWord {
  final String word;
  double xPosition; // 화면의 비율적 위치 (0.0 ~ 1.0)
  double yPosition; // 화면의 비율적 위치 (0.0 ~ 1.0)
  final double speed; // 이동 속도 (픽셀/초)
  final double rotation; // 회전 각도

  _EnemyWord({
    required this.word,
    required this.xPosition,
    required this.yPosition,
    required this.speed,
    required this.rotation,
  });
}

// 총알 클래스
class _Bullet {
  final double startX;
  final double startY;
  final double targetX;
  final double targetY;
  final double speed;
  final DateTime startTime;
  final bool isEnemyBullet; // 적의 총알인지 여부
  final double size; // 총알 크기

  _Bullet({
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
    required this.speed,
    required this.startTime,
    this.isEnemyBullet = false, // 기본값은 플레이어 총알
    this.size = 10.0, // 기본 사이즈
  });
}

// 폭발 효과 클래스
class _Explosion {
  final double xPosition; // X 위치
  final double yPosition; // Y 위치
  final double size; // 폭발 크기
  final DateTime startTime; // 폭발 시작 시간

  _Explosion({
    required this.xPosition,
    required this.yPosition,
    required this.size,
    required this.startTime,
  });
}
