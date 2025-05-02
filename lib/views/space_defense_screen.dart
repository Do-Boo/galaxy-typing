// 우주 디펜스 게임 화면
// 작성: 2024-05-15
// 업데이트: 2024-06-03 (웹/데스크톱에서 모바일 스타일 유지)
// 우주 침략자를 막기 위해 단어를 입력하는 게임 모드 화면

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
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

  // 애니메이션 컨트롤러
  late AnimationController _gameLoopController;

  // 타이머
  Timer? _spawnTimer;
  Timer? _difficultyTimer;
  Timer? _countdownTimer; // 카운트다운 타이머

  // 게임 설정
  int _spawnInterval = 3000; // 초기 적 생성 간격 (밀리초)
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
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);

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
        'galaxy'
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
      _spawnInterval = 3000;
      _enemySpeed = 8.0; // 초기 속도 값 대폭 감소
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
      _spawnInterval =
          max(1800, _spawnInterval - 150); // 생성 간격 감소 폭 감소 (최소 1.8초)
      _enemySpeed = min(30.0, _enemySpeed + 2.0); // 속도 증가 폭 감소 (최대 30 픽셀/초)
    });

    // 웨이브 변경에 따른 타이머 재설정
    _startSpawnTimer();
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
      _activeEnemies.add(_EnemyWord(
        word: word,
        xPosition: xPos,
        yPosition: 0.0, // 화면 최상단
        speed: _enemySpeed *
            (0.65 + _random.nextDouble() * 0.3) *
            speedMultiplier, // 속도에 변화 추가 (65%~95% 범위)
        rotation: _random.nextDouble() * 0.1 - 0.05, // 약간의 기울기
      ));
    });

    _enemySpawnCounter++;
  }

  // 입력 확인
  void _checkInput() {
    if (!_isPlaying || _isPaused) return;

    final inputText = _inputController.text.trim().toLowerCase();
    if (inputText.isEmpty) return;

    // 입력 단어와 일치하는 적 찾기
    final enemyIndex = _activeEnemies
        .indexWhere((enemy) => enemy.word.toLowerCase() == inputText);

    if (enemyIndex != -1) {
      // 적 파괴 및 점수 획득
      _destroyEnemy(enemyIndex);
      _inputController.clear();
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
      _activeExplosions.add(_Explosion(
        xPosition: enemy.xPosition,
        yPosition: enemy.yPosition,
        size: min(20.0 + wordLength * 3.0, 40.0), // 단어 길이에 비례한 폭발 크기
        startTime: DateTime.now(),
      ));

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
      _activeBullets.add(_Bullet(
        startX: screenSize.width / 2 / screenSize.width, // 우주선 위치 (화면 중앙)
        startY: 0.9, // 우주선 위치 (화면 하단 근처)
        targetX: targetX,
        targetY: targetY,
        speed: 0.02, // 총알 속도
        startTime: DateTime.now(),
      ));
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
    final statsController =
        Provider.of<StatsController>(context, listen: false);
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
            Text(
              '점수',
              style: AppTextStyles.bodyMedium(context),
            ),

            const SizedBox(height: 20),

            // 결과 통계
            _buildResultRow('최대 웨이브', '$_wave'),
            _buildResultRow(
                '처치한 적', '${_enemySpawnCounter - _activeEnemies.length}'),
            _buildResultRow('총 생성된 적', '$_enemySpawnCounter'),
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
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
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
          now.difference(bullet.startTime).inMilliseconds / 500.0; // 0.5초에 도달

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
                  Expanded(
                    child: _buildGameArea(context),
                  ),

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
                    Text(
                      '준비하세요!',
                      style: AppTextStyles.titleLarge(context),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 3,
                        ),
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
                    const SizedBox(height: 24),
                    Text(
                      '단어를 입력하여 우주선을 방어하세요',
                      style: AppTextStyles.bodyLarge(context),
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
            children: List.generate(3, (index) {
              final isActive = index < _lives;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.favorite,
                  color: isActive ? AppColors.error : AppColors.borderColor,
                  size: 24,
                ),
              );
            }),
          ),
        ),

        // 점수 및 웨이브 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundLighter.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1,
            ),
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
              Text(
                '웨이브 $_wave',
                style: AppTextStyles.bodySmall(context),
              ),
            ],
          ),
        ),
      ],
    );
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
          // 게임이 실행 중이고 일시정지 상태가 아닌 경우 적 위치 업데이트
          // 빌드 중에 setState를 호출하는 문제 해결을 위해 빌드 후에 실행되도록 수정
          if (_isPlaying && !_isPaused) {
            // 빌드 후에 실행되도록 스케줄링
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateEnemies(screenSize.height);
              _updateEffects();
            });
          }

          return Stack(
            children: [
              // 적 (단어) 렌더링
              ..._activeEnemies.map((enemy) {
                return _buildEnemy(
                    context, enemy, screenSize.width, screenSize.height);
              }),

              // 총알 렌더링
              ..._activeBullets.map((bullet) {
                return _buildBullet(
                    bullet, screenSize.width, screenSize.height);
              }),

              // 폭발 효과 렌더링
              ..._activeExplosions.map((explosion) {
                return _buildExplosion(
                    explosion, screenSize.width, screenSize.height);
              }),

              // 우주선 (하단 중앙)
              Positioned(
                bottom: 20,
                left: screenSize.width / 2 - 25,
                child: Container(
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
              ),
            ],
          );
        },
      ),
    );
  }

  // 적 위치 업데이트
  void _updateEnemies(double screenHeight) {
    final toRemove = <int>[];
    bool needsUpdate = false;

    for (int i = 0; i < _activeEnemies.length; i++) {
      final enemy = _activeEnemies[i];
      // 프레임당 이동 거리 계산 방식 수정 (60→120으로 나누어 속도 감소)
      enemy.yPosition += enemy.speed / 12000;

      // 화면 하단에 도달한 적 (95% 지점으로 조정 - 우주선과 충돌)
      if (enemy.yPosition > 0.95) {
        toRemove.add(i);
        _lives--; // 생명력 감소
        needsUpdate = true;

        // 효과음 재생
        _audioService.playSound(SoundType.playerHit);
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

  // 적 (단어) 렌더링
  Widget _buildEnemy(
      BuildContext context, _EnemyWord enemy, double width, double height) {
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
            border: Border.all(
              color: AppColors.borderColor,
              width: 1,
            ),
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
            style: AppTextStyles.bodyLarge(context).copyWith(
              color: AppColors.textPrimary,
            ),
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
        now.difference(bullet.startTime).inMilliseconds / 500.0; // 0.5초에 도달
    final progress = min(1.0, timeElapsed);

    final currentX =
        bullet.startX + (bullet.targetX - bullet.startX) * progress;
    final currentY =
        bullet.startY + (bullet.targetY - bullet.startY) * progress;

    return Positioned(
      left: currentX * width - 5,
      top: currentY * height - 5,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.8),
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

  // 입력 영역 구성
  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter.withOpacity(0.7),
        border: const Border(
          top: BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocusNode,
              enabled: _isPlaying && !_isPaused && !_isGameOver,
              onSubmitted: (_) => _inputController.clear(),
              decoration: InputDecoration(
                hintText: _isPlaying && !_isPaused
                    ? '단어를 입력하세요...'
                    : _isGameOver
                        ? '게임 오버'
                        : '시작 버튼을 눌러 게임을 시작하세요',
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

          // 게임 제어 버튼
          if (!_isPlaying && !_isGameOver)
            IconButton(
              icon: const Icon(Icons.play_arrow, color: AppColors.primary),
              onPressed: _startGame,
              tooltip: '게임 시작',
            )
          else if (_isPaused)
            IconButton(
              icon: const Icon(Icons.play_arrow, color: AppColors.primary),
              onPressed: _resumeGame,
              tooltip: '계속하기',
            )
          else if (_isPlaying && !_isGameOver)
            IconButton(
              icon: const Icon(Icons.pause, color: AppColors.warning),
              onPressed: _pauseGame,
              tooltip: '일시정지',
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
            Text(
              '일시정지',
              style: AppTextStyles.titleLarge(context),
            ),
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
        title: Text(
          '게임 종료',
          style: AppTextStyles.titleMedium(context),
        ),
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
  final double startX; // 시작 X 위치
  final double startY; // 시작 Y 위치
  final double targetX; // 목표 X 위치
  final double targetY; // 목표 Y 위치
  final double speed; // 이동 속도
  final DateTime startTime; // 발사 시간

  _Bullet({
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
    required this.speed,
    required this.startTime,
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
