// 시간 도전 화면
// 작성: 2024-05-15
// 업데이트: 2024-06-07 (웹버전 스타일 기반 반응형 개선)
// 제한 시간 내에 최대한 많은 단어를 타이핑하는 도전 모드 화면

import 'dart:async';

import 'package:flutter/foundation.dart';
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
import '../widgets/page_header.dart';
import '../widgets/space_background.dart';
import '../widgets/typing_text_display.dart';

class TimeChallengeScreen extends StatefulWidget {
  const TimeChallengeScreen({super.key});

  @override
  _TimeChallengeScreenState createState() => _TimeChallengeScreenState();
}

class _TimeChallengeScreenState extends State<TimeChallengeScreen> {
  final _audioService = AudioService();

  // 게임 상태
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isFinished = false;
  int _currentWordIndex = 0;
  List<String> _wordList = [];

  // 타이머 및 시간 관련
  late int _totalSeconds;
  int _remainingSeconds = 0;
  Timer? _gameTimer;

  // 타자 통계
  int _totalChars = 0;
  int _correctChars = 0;
  int _totalWords = 0;
  int _currentCpm = 0;
  int _maxCpm = 0;

  // 타자 입력 컨트롤러
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  String _currentTypedText = '';
  String _currentWord = '';

  // 준비 카운트다운
  bool _isCountingDown = false;
  int _countdownValue = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    // 시간 도전 화면에서는 음악을 재생하지 않음 (space_defense_screen 전용)
    _audioService.stop(); // 모든 음악 중지

    // 단어 목록 생성
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWords();

      // 설정에서 총 시간 가져오기
      final settingsController = Provider.of<SettingsController>(
        context,
        listen: false,
      );
      _totalSeconds = settingsController.timeChallengeDuration;
      _remainingSeconds = _totalSeconds;

      // 자동으로 입력 필드에 포커스 설정 (키보드 표시)
      _inputFocusNode.requestFocus();
    });

    // 입력 텍스트 변경 리스너 추가
    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // 2024-07-16: 화면 전환 시 카운트다운 소리 중지
    _audioService.stopCountdown();

    // 타이머 취소
    _gameTimer?.cancel();
    _countdownTimer?.cancel();

    // 컨트롤러 정리
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    _inputFocusNode.dispose();

    super.dispose();
  }

  // 단어 목록을 로드하는 메서드
  void _loadWords() {
    final settingsController = Provider.of<SettingsController>(
      context,
      listen: false,
    );

    // 선택된 난이도와 언어에 따른 단어 목록 가져오기
    _wordList = WordData.getWordsByDifficulty(
      settingsController.difficulty,
      language: settingsController.typingLanguage,
    );

    // 단어 목록을 무작위로 섞기
    _wordList.shuffle();

    if (_wordList.isNotEmpty) {
      setState(() {
        _currentWord = _wordList[0];
      });
    }
  }

  // 카운트다운 시작
  void _startCountdown() {
    // 2024-07-13: 카운트다운 소리 재생 로직 간소화
    // 2024-07-16: 타이밍 문제 해결을 위해 상태 업데이트 전에 소리 재생
    // 2024-07-16: 카운트다운 소리가 1초 지연되는 문제 수정
    // 2024-07-17: 웹과 모바일 모두 동일한 방식으로 처리하도록 수정
    // 2024-07-17: 카운트다운 소리와 숫자 변경 타이밍 동기화

    // 타이머 취소 먼저 수행
    _countdownTimer?.cancel();

    // 상태 초기화
    setState(() {
      _isCountingDown = true;
      _countdownValue = 3;
    });

    // 소리 먼저 재생 (소리가 화면에 숫자 표시되는 것보다 먼저 들림)
    _audioService.playSound(SoundType.countdown);

    // 카운트다운 타이머 시작 (소리 재생 직후 시작)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdownValue--;
      });

      if (_countdownValue <= 0) {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
        });
        _startGame();
      }
    });
  }

  // 게임 시작
  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isPaused = false;
      _isFinished = false;
      _totalChars = 0;
      _correctChars = 0;
      _totalWords = 0;
      _currentCpm = 0;
      _maxCpm = 0;
      _currentWordIndex = 0;
      _remainingSeconds = _totalSeconds;

      if (_wordList.isNotEmpty) {
        _currentWord = _wordList[0];
      }

      _inputController.clear();
      _currentTypedText = '';
    });

    // 타이머 시작
    _startTimer();

    // 입력 필드에 포커스
    _inputFocusNode.requestFocus();
  }

  // 타이머 시작
  void _startTimer() {
    // 이미 실행 중인 타이머가 있다면 취소
    _gameTimer?.cancel();

    // 1초마다 실행되는 타이머 설정
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          // 남은 시간 감소
          _remainingSeconds--;

          // CPM 계산 (분당 문자 입력 수)
          final elapsedSeconds = _totalSeconds - _remainingSeconds;
          if (elapsedSeconds > 0) {
            _currentCpm = (_totalChars * 60 / elapsedSeconds).round();
            if (_currentCpm > _maxCpm) {
              _maxCpm = _currentCpm;
            }
          }

          // 시간이 다 되면 게임 종료
          if (_remainingSeconds <= 0) {
            _endGame();
          }
        });

        // 마지막 10초 카운트다운 효과음
        if (_remainingSeconds <= 10 && _remainingSeconds > 0) {
          _audioService.playSound(SoundType.tick);
        }
      }
    });
  }

  // 게임 일시 정지
  void _pauseGame() {
    if (!_isPlaying || _isPaused) return;

    setState(() {
      _isPaused = true;
    });

    // 타이머 중지
    _gameTimer?.cancel();

    // 일시 정지 효과음
    _audioService.playSound(SoundType.pause);
  }

  // 게임 종료
  void _endGame() async {
    // 이미 종료되었으면 무시
    if (_isFinished) return;

    // 타이머 중지
    _gameTimer?.cancel();

    // 종료 효과음
    _audioService.playSound(SoundType.gameOver);

    // 통계 저장
    final statsController = Provider.of<StatsController>(
      context,
      listen: false,
    );
    await statsController.saveTimeChallengeSession(
      chars: _totalChars,
      correctChars: _correctChars,
      words: _totalWords,
      cpm: _maxCpm,
      timeSpent: _totalSeconds,
    );

    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _isFinished = true;
    });

    // 결과 다이얼로그 표시
    _showResultDialog();
  }

  // 입력 텍스트 변경 핸들러
  void _onTextChanged() {
    // 첫 입력 감지 시 자동으로 게임 시작 (카운트다운 시작)
    if (!_isPlaying &&
        !_isPaused &&
        !_isFinished &&
        !_isCountingDown &&
        _inputController.text.isNotEmpty) {
      _startCountdown();
      return;
    }

    if (!_isPlaying || _isPaused) return;

    setState(() {
      _currentTypedText = _inputController.text;
    });

    // 단어 완료 확인 - 스페이스바 입력, 정확히 일치할 때, 또는 길이 초과 시
    if (_currentTypedText.endsWith(' ')) {
      final typedWord = _currentTypedText.trim();
      _checkWordCompletion(typedWord);
    } else if (_currentTypedText == _currentWord) {
      // 입력한 텍스트가 현재 단어와 정확히 일치하면 자동으로 다음 단어로 진행
      _checkWordCompletion(_currentTypedText);
    } else if (_currentTypedText.length > _currentWord.length) {
      // 입력한 텍스트 길이가 현재 단어보다 길면 오타로 처리하고 다음 단어로 진행
      _audioService.playSound(SoundType.error);
      _checkWordCompletion(_currentTypedText);
    }
  }

  // 단어 완료 확인
  void _checkWordCompletion(String typedWord) {
    // 총 문자 수 업데이트
    _totalChars += typedWord.length + 1; // +1은 스페이스바

    // 정확한 문자 수 업데이트
    if (typedWord == _currentWord) {
      _correctChars += typedWord.length + 1;
      _audioService.playSound(SoundType.wordComplete);
    } else {
      // 일치하는 문자 수 계산
      int matchingChars = 0;
      for (int i = 0; i < typedWord.length && i < _currentWord.length; i++) {
        if (typedWord[i] == _currentWord[i]) {
          matchingChars++;
        }
      }
      _correctChars += matchingChars + 1;
      _audioService.playSound(SoundType.error);
    }

    // 단어 수 업데이트
    _totalWords++;

    // 다음 단어로 이동
    _currentWordIndex = (_currentWordIndex + 1) % _wordList.length;
    _currentWord = _wordList[_currentWordIndex];

    // 입력 필드 초기화
    _inputController.clear();
    _currentTypedText = '';
  }

  // 결과 다이얼로그 표시
  void _showResultDialog() {
    // 정확도 계산
    final accuracy =
        _totalChars > 0 ? (_correctChars / _totalChars * 100).round() : 0;

    // 등급 결정
    String rank;
    if (_currentCpm >= 300) {
      rank = 'S+';
    } else if (_currentCpm >= 250) {
      rank = 'S';
    } else if (_currentCpm >= 200) {
      rank = 'A+';
    } else if (_currentCpm >= 150) {
      rank = 'A';
    } else if (_currentCpm >= 100) {
      rank = 'B';
    } else if (_currentCpm >= 70) {
      rank = 'C';
    } else {
      rank = 'D';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLighter,
        title: Text(
          '시간 도전 결과',
          style: AppTextStyles.titleMedium(context),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 등급 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: Text(
                rank,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 32,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 결과 통계
            _buildResultStat('총 단어 수', '$_totalWords 단어'),
            _buildResultStat('총 입력 문자 수', '$_totalChars 자'),
            _buildResultStat('정확하게 입력한 문자 수', '$_correctChars 자'),
            _buildResultStat('정확도', '$accuracy%'),
            _buildResultStat('평균 CPM', '$_currentCpm'),
            _buildResultStat('최고 CPM', '$_maxCpm'),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startCountdown();
                },
                child: const Text(
                  '다시 도전',
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

  // 결과 통계 항목 위젯
  Widget _buildResultStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 포맷된 시간 문자열 생성
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final formattedTime = '$minutes:${seconds.toString().padLeft(2, '0')}';

    // 정확도 계산
    final accuracy =
        _totalChars > 0 ? (_correctChars / _totalChars * 100).round() : 0;

    // 반응형 여부 확인
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = !isDesktop && !isTablet;

    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        // 키보드가 표시될 때 화면이 리사이징되도록 설정
        // 모바일 웹에서는 리사이징을 비활성화하여 키보드 공백 문제 해결
        resizeToAvoidBottomInset: !kIsWeb,
        body: Stack(
          children: [
            // 배경
            const SpaceBackground(),

            // 메인 콘텐츠
            SafeArea(
              child: ResponsiveHelper.centeredContent(
                context: context,
                child: isMobile
                    ? _buildMobileLayout(context, formattedTime, accuracy)
                    : _buildDesktopLayout(context, formattedTime, accuracy),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 모바일용 레이아웃
  Widget _buildMobileLayout(
      BuildContext context, String formattedTime, int accuracy) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Column(
      children: [
        // 상단 콘텐츠 (스크롤 가능)
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 헤더 및 뒤로가기 버튼
                  Row(
                    children: [
                      CosmicBackButton(
                        onPressed: () {
                          if (_isPlaying) {
                            _showExitConfirmDialog();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      Expanded(
                        child: PageHeader(
                          title: 'TIME CHALLENGE',
                          subtitle: '제한 시간 내 최대한 많은 단어 입력',
                          centerAlign: true,
                          titleFontSize: isTablet ? 28 : 24,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 모바일용 컴팩트 미니 대시보드 (타이머 + 통계를 통합)
                  _buildMobileMiniDashboard(context, formattedTime, accuracy),

                  const SizedBox(height: 12),

                  // 타이핑 영역 (카운트다운 시에는 카운트다운 표시)
                  _isCountingDown
                      ? _buildCountdownOverlay(context)
                      : _buildMobileTypingArea(context),

                  // 버튼 영역 - 모바일에 맞는 버튼 세트 사용
                  if (!_isCountingDown)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: _buildMobileControlButtons(context),
                    ),
                ],
              ),
            ),
          ),
        ),

        // 모바일에서 키보드 위에 고정되는 입력 필드
        if (!_isCountingDown)
          Container(
            width: double.infinity,
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
                    enabled: !_isPaused && !_isFinished && !_isCountingDown,
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: _isPlaying && !_isPaused && !_isFinished
                          ? '여기에 입력하세요...'
                          : _isFinished
                              ? '게임 종료'
                              : _isPaused
                                  ? '일시 정지됨'
                                  : _isCountingDown
                                      ? '카운트다운 중...'
                                      : '입력을 시작하면 자동으로 게임이 시작됩니다',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.keyboard,
                          color: AppColors.textSecondary),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.textSecondary),
                        onPressed: () => _inputController.clear(),
                      ),
                    ),
                    onSubmitted: (_) => _inputController.text += ' ',
                  ),
                ),
                if (_isPaused)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: const Icon(Icons.play_arrow,
                          color: AppColors.primary),
                      onPressed: _startTimer,
                      tooltip: '계속하기',
                    ),
                  )
                else if (_isPlaying && !_isPaused)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: const Icon(Icons.pause, color: AppColors.warning),
                      onPressed: _pauseGame,
                      tooltip: '일시정지',
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  // 모바일용 미니 대시보드 (타이머 + 통계가 통합된 컴팩트한 형태)
  Widget _buildMobileMiniDashboard(
      BuildContext context, String formattedTime, int accuracy) {
    // 남은 시간에 따라 색상 변경
    final timerColor = _remainingSeconds <= 10
        ? AppColors.error
        : _remainingSeconds <= 30
            ? AppColors.warning
            : AppColors.primary;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 타이머 영역
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: timerColor,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: timerColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 20,
                    color: timerColor,
                    shadows: [
                      Shadow(
                        color: timerColor.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 간단한 통계들 (작은 아이콘과 수치만 표시)
          _buildMiniStatItem(Icons.text_fields, '$_totalWords', '단어'),
          _buildMiniStatItem(Icons.speed, '$_currentCpm', 'CPM'),
          _buildMiniStatItem(Icons.check_circle_outline, '$accuracy%', '정확도'),
        ],
      ),
    );
  }

  // 미니 통계 아이템 (아이콘 + 수치)
  Widget _buildMiniStatItem(IconData icon, String value, String label) {
    return Tooltip(
      message: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 14),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 데스크톱용 레이아웃 (기존 레이아웃)
  Widget _buildDesktopLayout(
      BuildContext context, String formattedTime, int accuracy) {
    return SingleChildScrollView(
      child: Padding(
        padding: ResponsiveHelper.screenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 헤더 및 뒤로가기 버튼
            Row(
              children: [
                CosmicBackButton(
                  onPressed: () {
                    if (_isPlaying) {
                      _showExitConfirmDialog();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                Expanded(
                  child: PageHeader(
                    title: 'TIME CHALLENGE',
                    subtitle: '제한 시간 내 최대한 많은 단어 입력하기',
                    centerAlign: true,
                    titleFontSize: ResponsiveHelper.isDesktop(context)
                        ? 32
                        : (ResponsiveHelper.isTablet(context) ? 28 : 24),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),

            const SizedBox(height: 20),

            // 타이머 표시 - 웹 스타일 적용
            _buildTimerDisplay(context, formattedTime),

            const SizedBox(height: 16),

            // 상태 정보 표시 - 웹 스타일 적용
            _buildStatsDisplay(context, accuracy),

            const SizedBox(height: 16),

            // 타이핑 영역 - 웹 스타일 적용
            _isCountingDown
                ? _buildCountdownOverlay(context)
                : _buildTypingArea(context),

            const SizedBox(height: 16),

            // 하단 버튼 영역
            _buildControlButtons(context),
          ],
        ),
      ),
    );
  }

  // 모바일용 타이핑 영역 위젯
  Widget _buildMobileTypingArea(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 현재 타이핑 중인 텍스트 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLighter.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderColor,
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // 현재 목표 단어
                Text(
                  _isPlaying ? _currentWord : '시작 버튼을 눌러 도전을 시작하세요',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // 타이핑 피드백 영역
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 1,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minHeight: 60,
                  ),
                  child: _isPlaying
                      ? TypingTextDisplay(
                          targetText: _currentWord,
                          typedText: _currentTypedText,
                          fontSize: isTablet ? 24 : 20,
                        )
                      : Center(
                          child: Text(
                            '아래에 타이핑을 시작하면 카운트다운 후 게임이 시작됩니다',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              color: AppColors.textSecondary.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
              ],
            ),
          ),

          // 다음 단어 미리보기
          if (_isPlaying && !_isPaused && !_isFinished)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(8),
              constraints: BoxConstraints(
                maxWidth: isTablet ? 350 : 300,
              ),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '다음 단어',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _wordList[(_currentWordIndex + 1) % _wordList.length],
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 타이머 표시 위젯
  Widget _buildTimerDisplay(BuildContext context, String formattedTime) {
    // 남은 시간에 따라 색상 변경
    final color = _remainingSeconds <= 10
        ? AppColors.error
        : _remainingSeconds <= 30
            ? AppColors.warning
            : AppColors.primary;

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 16 : 12, horizontal: isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter.withOpacity(0.7),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: color, size: isDesktop ? 32 : 24),
          const SizedBox(width: 12),
          Text(
            formattedTime,
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: isDesktop ? 32 : 24,
              color: color,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 통계 표시 위젯
  Widget _buildStatsDisplay(BuildContext context, int accuracy) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatBox('단어', '$_totalWords', Icons.text_fields),
          _buildStatBox('CPM', '$_currentCpm', Icons.speed),
          _buildStatBox('정확도', '$accuracy%', Icons.check_circle_outline),
        ],
      ),
    );
  }

  // 통계 박스 위젯
  Widget _buildStatBox(String label, String value, IconData icon) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      width: isDesktop ? 150 : 110,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: isDesktop ? 24 : 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // 카운트다운 오버레이
  Widget _buildCountdownOverlay(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '게임 시작',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: isDesktop ? 140 : 120,
            height: isDesktop ? 140 : 120,
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_countdownValue',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: isDesktop ? 48 : 36,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            '키보드 준비',
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // 타이핑 영역 위젯
  Widget _buildTypingArea(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 현재 타이핑 중인 텍스트 카드
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 800 : 600,
          ),
          padding: EdgeInsets.all(isDesktop ? 16 : 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundLighter.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // 현재 목표 단어
              Text(
                _isPlaying ? _currentWord : '시작 버튼을 눌러 도전을 시작하세요',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 타이핑 피드백 영역
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isDesktop ? 16 : 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 1,
                  ),
                ),
                constraints: BoxConstraints(
                  minHeight: isDesktop ? 80 : 60,
                ),
                child: _isPlaying
                    ? TypingTextDisplay(
                        targetText: _currentWord,
                        typedText: _currentTypedText,
                        fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                      )
                    : Center(
                        child: Text(
                          '아래에 타이핑을 시작하면 카운트다운 후 게임이 시작됩니다',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            color: AppColors.textSecondary.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 지시사항 텍스트
        if (isDesktop || isTablet)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '위의 단어를 입력하세요. 시간이 다 되면 자동으로 게임이 종료됩니다.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // 입력 필드 - 웹 스타일 적용
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : 500,
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: _inputController,
            focusNode: _inputFocusNode,
            enabled: !_isPaused && !_isFinished && !_isCountingDown,
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: _isPlaying && !_isPaused && !_isFinished
                  ? '여기에 입력하세요...'
                  : _isFinished
                      ? '게임 종료'
                      : _isPaused
                          ? '일시 정지됨'
                          : _isCountingDown
                              ? '카운트다운 중...'
                              : '입력을 시작하면 자동으로 게임이 시작됩니다',
              // prefixIcon: Icon(Icons.keyboard),
              filled: true,
              fillColor: Colors.white.withOpacity(0.07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            onSubmitted: (_) => _inputController.text += ' ',
          ),
        ),
      ],
    );
  }

  // 하단 제어 버튼 영역
  Widget _buildControlButtons(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final buttonSize =
        isDesktop ? CosmicButtonSize.large : CosmicButtonSize.medium;

    if (_isFinished) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CosmicButton(
            label: '다시 도전',
            icon: Icons.replay,
            type: CosmicButtonType.primary,
            size: buttonSize,
            onPressed: _startCountdown,
          ),
          const SizedBox(width: 16),
          CosmicButton(
            label: '나가기',
            icon: Icons.exit_to_app,
            type: CosmicButtonType.outline,
            size: buttonSize,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    } else if (_isPlaying) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isPaused)
            CosmicButton(
              label: '계속하기',
              icon: Icons.play_arrow,
              type: CosmicButtonType.primary,
              size: buttonSize,
              onPressed: _startTimer,
            )
          else
            CosmicButton(
              label: '일시정지',
              icon: Icons.pause,
              type: CosmicButtonType.outline,
              size: buttonSize,
              onPressed: _pauseGame,
            ),
          const SizedBox(width: 16),
          CosmicButton(
            label: '종료',
            icon: Icons.stop,
            type: CosmicButtonType.secondary,
            size: buttonSize,
            onPressed: _endGame,
          ),
        ],
      );
    } else if (_isCountingDown) {
      // 카운트다운 중에는 버튼 표시 안함
      return const SizedBox.shrink();
    } else {
      // 시작 전 - 단순 안내 메시지만 표시
      return Center(
        child: Text(
          '타이핑을 시작하면 게임이 자동으로 시작됩니다',
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
  }

  // 모바일용 컨트롤 버튼 - 최소한의 버튼만 표시
  Widget _buildMobileControlButtons(BuildContext context) {
    const buttonSize = CosmicButtonSize.medium;

    // 게임이 끝났을 때
    if (_isFinished) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CosmicButton(
            label: '다시 도전',
            icon: Icons.replay,
            type: CosmicButtonType.primary,
            size: buttonSize,
            onPressed: _startCountdown,
          ),
        ],
      );
    }
    // 카운트다운 중이나 일반 플레이 중에는 버튼 숨김 (이미 하단에 컨트롤 버튼 있음)
    else {
      return const SizedBox.shrink();
    }
  }

  // 나가기 확인 다이얼로그
  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLighter,
        title: Text(
          '도전 종료',
          style: AppTextStyles.titleMedium(context),
        ),
        content: Text(
          '현재 진행 중인 도전을 종료하시겠습니까? 현재까지의 기록은 저장되지 않습니다.',
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
              Navigator.of(context).pop();
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

  // 뒤로가기 처리
  Future<bool> _onWillPop() async {
    // 2024-07-16: 화면 전환 시 카운트다운 소리 중지
    _audioService.stopCountdown();

    // 게임 중인 경우 확인 다이얼로그 표시
    if (_isPlaying && !_isFinished) {
      _gameTimer?.cancel(); // 타이머 일시 중지

      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('게임 종료'),
          content: const Text('정말 게임을 종료하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('종료'),
            ),
          ],
        ),
      );

      if (result != true) {
        // 취소한 경우 타이머 재시작
        _startTimer();
        return false;
      }
    }

    return true;
  }
}
