// 기본 타자 연습 화면
// 작성: 2023-05-10
// 업데이트: 2024-05-15 (PressStart2P 폰트 일관성 개선)
// 업데이트: 2024-06-07 (웹버전 스타일 기반 반응형 개선)
// 기본적인 타자 연습을 위한 화면

import 'dart:async';

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

class BasicPracticeScreen extends StatefulWidget {
  const BasicPracticeScreen({super.key});

  @override
  _BasicPracticeScreenState createState() => _BasicPracticeScreenState();
}

class _BasicPracticeScreenState extends State<BasicPracticeScreen> {
  final _audioService = AudioService();

  // 게임 상태
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentWordIndex = 0;
  List<String> _wordList = [];

  // 통계 추적
  int _totalChars = 0;
  int _correctChars = 0;
  int _totalWords = 0;
  DateTime _startTime = DateTime.now();
  DateTime _lastActiveTime = DateTime.now();
  int _elapsedSeconds = 0;
  Timer? _gameTimer;

  // 타자 입력 컨트롤러
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  String _currentTypedText = '';
  String _currentWord = '';

  // CPM 계산 변수
  int _currentCpm = 0;
  int _maxCpm = 0;

  @override
  void initState() {
    super.initState();

    // 기본 연습 화면에서는 음악을 재생하지 않음 (space_defense_screen 전용)
    _audioService.stop(); // 모든 음악 중지

    // 단어 목록 생성 - 설정 컨트롤러에서 난이도에 따라 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWords();
    });

    // 입력 텍스트 변경 리스너 추가
    _inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // 타이머 취소
    _gameTimer?.cancel();

    // 컨트롤러 정리
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    _inputFocusNode.dispose();

    super.dispose();
  }

  // 난이도에 따른 단어 목록 로드
  void _loadWords() {
    final settingsController = Provider.of<SettingsController>(
      context,
      listen: false,
    );

    // 선택된 난이도와 언어에 따른 단어 목록 가져오기
    _wordList = WordData.getWordsByDifficulty(
      settingsController.difficulty,
      language: settingsController.language,
    );

    // 단어 목록을 무작위로 섞기
    _wordList.shuffle();

    if (_wordList.isNotEmpty) {
      setState(() {
        _currentWord = _wordList[0];
      });
    }
  }

  // 타이머 관리
  void _startTimer() {
    // 이미 실행 중인 타이머가 있다면 취소
    _gameTimer?.cancel();

    // 시작 시간 기록
    _startTime = DateTime.now();
    _lastActiveTime = _startTime;

    // 1초마다 실행되는 타이머 설정
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        final now = DateTime.now();

        setState(() {
          // 경과 시간 업데이트
          _elapsedSeconds = now.difference(_startTime).inSeconds;

          // CPM 계산 (분당 문자 입력 수)
          if (_elapsedSeconds > 0) {
            _currentCpm = (_totalChars * 60 / _elapsedSeconds).round();
            if (_currentCpm > _maxCpm) {
              _maxCpm = _currentCpm;
            }
          }
        });

        // 휴면 감지 (3분 이상 입력이 없으면 일시 정지)
        if (now.difference(_lastActiveTime).inMinutes >= 3) {
          _pauseGame();
        }
      }
    });
  }

  // 게임 시작
  void _startGame() {
    // 이미 게임이 진행 중이면 무시
    if (_isPlaying && !_isPaused) return;

    setState(() {
      _isPlaying = true;
      _isPaused = false;

      // 게임이 처음 시작되는 경우 (일시 정지 후 재개가 아닌 경우)
      if (_elapsedSeconds == 0) {
        _totalChars = 0;
        _correctChars = 0;
        _totalWords = 0;
        _currentCpm = 0;
        _maxCpm = 0;
        _currentWordIndex = 0;

        if (_wordList.isNotEmpty) {
          _currentWord = _wordList[0];
        }
      }
    });

    // 타이머 시작
    _startTimer();

    // 입력 필드에 포커스
    _inputFocusNode.requestFocus();
  }

  // 게임 일시 정지
  void _pauseGame() {
    if (!_isPlaying || _isPaused) return;

    setState(() {
      _isPaused = true;
    });

    // 타이머 중지
    _gameTimer?.cancel();
  }

  // 게임 종료
  void _endGame() async {
    // 게임이 진행 중이지 않으면 무시
    if (!_isPlaying) return;

    // 타이머 중지
    _gameTimer?.cancel();

    // 통계 저장
    final statsController = Provider.of<StatsController>(
      context,
      listen: false,
    );
    await statsController.saveBasicPracticeSession(
      chars: _totalChars,
      correctChars: _correctChars,
      timeSpent: _elapsedSeconds,
    );

    setState(() {
      _isPlaying = false;
      _isPaused = false;
    });

    // 결과 다이얼로그 표시
    _showResultDialog();
  }

  // 결과 다이얼로그 표시
  void _showResultDialog() {
    // 정확도 계산
    final accuracy =
        _totalChars > 0 ? (_correctChars / _totalChars * 100).round() : 0;

    // 성과 메시지 결정
    String performanceMessage;
    if (_maxCpm >= 300) {
      performanceMessage = '당신은 우주 타자의 마스터입니다!';
    } else if (_maxCpm >= 200) {
      performanceMessage = '우주 함선 조종사급 타자 실력!';
    } else if (_maxCpm >= 100) {
      performanceMessage = '우주 여행자로서 훌륭한 실력!';
    } else {
      performanceMessage = '좋은 시작입니다. 계속 연습하세요!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLighter,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        title: Text(
          '연습 결과',
          style: AppTextStyles.titleMedium(context),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              performanceMessage,
              style: AppTextStyles.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 결과 통계
            _buildResultStat('입력한 문자 수', '$_totalChars'),
            _buildResultStat('정확하게 입력한 문자 수', '$_correctChars'),
            _buildResultStat('입력한 단어 수', '$_totalWords'),
            _buildResultStat('정확도', '$accuracy%'),
            _buildResultStat('최고 CPM', '$_maxCpm'),
            _buildResultStat(
              '소요 시간',
              '${_elapsedSeconds ~/ 60}분 ${_elapsedSeconds % 60}초',
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
                  setState(() {
                    _inputController.clear();
                    _currentTypedText = '';
                    _loadWords(); // 새 단어 목록 로드
                  });
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

  // 입력 텍스트 변경 핸들러
  void _onTextChanged() {
    // 첫 입력 감지 시 자동으로 게임 시작
    if (!_isPlaying && !_isPaused && _inputController.text.isNotEmpty) {
      _startGame();
      return;
    }

    if (!_isPlaying || _isPaused) return;

    setState(() {
      _currentTypedText = _inputController.text;
      _lastActiveTime = DateTime.now(); // 활동 시간 갱신
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

  @override
  Widget build(BuildContext context) {
    // 통계 표시용 문자열
    final formattedTime =
        '${_elapsedSeconds ~/ 60}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}';
    final accuracy =
        _totalChars > 0 ? (_correctChars / _totalChars * 100).round() : 0;

    // 반응형 여부 확인
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = !isDesktop && !isTablet;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      // 키보드가 표시될 때 화면이 리사이징되도록 설정
      resizeToAvoidBottomInset: true, // 모든 디바이스에서 리사이징 활성화
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
                  // 헤더 영역
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
                          title: 'BASIC TYPING',
                          subtitle: '자신의 페이스로 타이핑을 연습하세요',
                          centerAlign: true,
                          titleFontSize: isTablet ? 28 : 24,
                        ),
                      ),
                      const SizedBox(width: 40), // 뒤로가기 버튼과 대칭을 위한 공간
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 통계 영역 - 웹 스타일의 통계 바 적용
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatBox('시간', formattedTime, Icons.timer),
                        _buildStatBox(
                            'CPM', _currentCpm.toString(), Icons.speed),
                        _buildStatBox(
                            '정확도', '$accuracy%', Icons.check_circle_outline),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 타이핑 영역
                  Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 단어 표시 카드
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
                                _isPlaying
                                    ? _currentWord
                                    : '시작 버튼을 눌러 연습을 시작하세요',
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
                                          '아래에 타이핑을 시작하면 자동으로 게임이 시작됩니다',
                                          style: TextStyle(
                                            fontSize: isTablet ? 18 : 16,
                                            color: AppColors.textSecondary
                                                .withOpacity(0.5),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 버튼 영역
                  Container(
                    constraints: const BoxConstraints(maxWidth: 600),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_isPlaying && _isPaused)
                          CosmicButton(
                            label: '계속',
                            icon: Icons.play_arrow,
                            type: CosmicButtonType.primary,
                            size: CosmicButtonSize.medium,
                            onPressed: _startGame,
                          )
                        else if (_isPlaying && !_isPaused)
                          CosmicButton(
                            label: '일시정지',
                            icon: Icons.pause,
                            type: CosmicButtonType.outline,
                            size: CosmicButtonSize.medium,
                            onPressed: _pauseGame,
                          ),
                        if (_isPlaying)
                          CosmicButton(
                            label: '종료',
                            icon: Icons.stop,
                            type: CosmicButtonType.secondary,
                            size: CosmicButtonSize.medium,
                            onPressed: _endGame,
                          )
                        else
                          CosmicButton(
                            label: '단어 새로고침',
                            icon: Icons.refresh,
                            type: CosmicButtonType.outline,
                            size: CosmicButtonSize.medium,
                            onPressed: _loadWords,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 하단 입력 필드 영역 (키보드 위에 고정)
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
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: _isPlaying && !_isPaused
                        ? '여기에 입력하세요...'
                        : _isPaused
                            ? '일시 정지됨'
                            : '입력을 시작하면 자동으로 게임이 시작됩니다',
                    enabled: !_isPaused,
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
                    icon:
                        const Icon(Icons.play_arrow, color: AppColors.primary),
                    onPressed: _startGame,
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

  // 데스크톱용 레이아웃 (기존 레이아웃)
  Widget _buildDesktopLayout(
      BuildContext context, String formattedTime, int accuracy) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 헤더 영역
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
                    title: 'BASIC TYPING',
                    subtitle: '자신의 페이스로 타이핑을 연습하세요',
                    centerAlign: true,
                    titleFontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                  ),
                ),
                const SizedBox(width: 40), // 뒤로가기 버튼과 대칭을 위한 공간
              ],
            ),

            const SizedBox(height: 20),

            // 통계 영역 - 웹 스타일의 통계 바 적용
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBox('시간', formattedTime, Icons.timer),
                  _buildStatBox('CPM', _currentCpm.toString(), Icons.speed),
                  _buildStatBox(
                      '정확도', '$accuracy%', Icons.check_circle_outline),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 타이핑 영역 - 웹 스타일의 타이핑 디스플레이 적용
            Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : 600,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 단어 표시 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
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
                          _isPlaying ? _currentWord : '시작 버튼을 눌러 연습을 시작하세요',
                          style: TextStyle(
                            fontSize: isDesktop ? 28 : (isTablet ? 24 : 20),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

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
                          constraints: const BoxConstraints(
                            minHeight: 80,
                          ),
                          child: _isPlaying
                              ? TypingTextDisplay(
                                  targetText: _currentWord,
                                  typedText: _currentTypedText,
                                  fontSize:
                                      isDesktop ? 28 : (isTablet ? 24 : 20),
                                )
                              : Center(
                                  child: Text(
                                    '아래에 타이핑을 시작하면 자동으로 게임이 시작됩니다',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 18 : 16,
                                      color: AppColors.textSecondary
                                          .withOpacity(0.5),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 지시사항 텍스트
                  if (isDesktop || isTablet)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        '위의 단어를 입력하세요. 정확하게 입력하면 다음 단어로 자동 이동합니다.',
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
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: TextField(
                      controller: _inputController,
                      focusNode: _inputFocusNode,
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 18,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: _isPlaying && !_isPaused
                            ? '여기에 입력하세요...'
                            : _isPaused
                                ? '일시 정지됨'
                                : '입력을 시작하면 자동으로 게임이 시작됩니다',
                        enabled: !_isPaused,
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
              ),
            ),

            const SizedBox(height: 20),

            // 버튼 영역
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_isPlaying && _isPaused)
                    CosmicButton(
                      label: '계속',
                      icon: Icons.play_arrow,
                      type: CosmicButtonType.primary,
                      size: isDesktop
                          ? CosmicButtonSize.large
                          : CosmicButtonSize.medium,
                      onPressed: _startGame,
                    )
                  else if (_isPlaying && !_isPaused)
                    CosmicButton(
                      label: '일시정지',
                      icon: Icons.pause,
                      type: CosmicButtonType.outline,
                      size: isDesktop
                          ? CosmicButtonSize.large
                          : CosmicButtonSize.medium,
                      onPressed: _pauseGame,
                    ),
                  if (_isPlaying)
                    CosmicButton(
                      label: '종료',
                      icon: Icons.stop,
                      type: CosmicButtonType.secondary,
                      size: isDesktop
                          ? CosmicButtonSize.large
                          : CosmicButtonSize.medium,
                      onPressed: _endGame,
                    )
                  else
                    CosmicButton(
                      label: '단어 새로고침',
                      icon: Icons.refresh,
                      type: CosmicButtonType.outline,
                      size: isDesktop
                          ? CosmicButtonSize.large
                          : CosmicButtonSize.medium,
                      onPressed: _loadWords,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 웹 스타일의 통계 박스 위젯
  Widget _buildStatBox(String label, String value, IconData icon) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      width: isDesktop ? 150 : 110,
      decoration: BoxDecoration(
        color: Colors.black26,
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
          const SizedBox(height: 4),
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

  // 나가기 확인 다이얼로그
  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLighter,
        title: Text(
          '연습 종료',
          style: AppTextStyles.titleMedium(context),
        ),
        content: Text(
          '현재 연습을 종료하시겠습니까? 현재까지의 기록은 저장되지 않습니다.',
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
}
