// 긴글 연습 화면
// 작성: 2024-06-16
// 문단 단위의 긴 텍스트를 타이핑하는 연습 화면

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
import '../models/game_settings.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/back_button.dart';
import '../widgets/cosmic_button.dart';
import '../widgets/page_header.dart';
import '../widgets/space_background.dart';

class LongTextPracticeScreen extends StatefulWidget {
  const LongTextPracticeScreen({super.key});

  @override
  _LongTextPracticeScreenState createState() => _LongTextPracticeScreenState();
}

class _LongTextPracticeScreenState extends State<LongTextPracticeScreen> {
  // 컨트롤러
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // 서비스
  final AudioService _audioService = AudioService();

  // 게임 상태
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isCompleted = false;

  // 타이핑 데이터
  String _currentText = '';
  List<String> _sentences = [];
  int _currentSentenceIndex = 0;
  String _currentSentence = '';
  String _userInput = '';
  int _currentPosition = 0;
  int _correctChars = 0;
  int _totalChars = 0;
  int _errors = 0;
  int _completedSentences = 0;

  // 시간 관련
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  // 통계
  double _wpm = 0.0;
  double _accuracy = 100.0;

  // 긴글 텍스트 목록 (한국어/영어)
  final List<Map<String, String>> _koreanTexts = [
    {
      'title': '우주의 신비',
      'content':
          '우주는 인류가 아직 완전히 이해하지 못한 거대한 미스터리입니다. 수십억 개의 별들이 반짝이는 밤하늘을 올려다보면, 우리는 자연스럽게 우리 자신의 존재에 대해 생각하게 됩니다. 지구라는 작은 행성에서 살아가는 우리는 과연 우주에서 유일한 생명체일까요? 과학자들은 이 질문에 답하기 위해 끊임없이 연구하고 있습니다. 망원경을 통해 먼 은하를 관찰하고, 우주선을 보내 다른 행성을 탐사하며, 외계 생명체의 신호를 찾고 있습니다.'
    },
    {
      'title': '기술의 발전',
      'content':
          '21세기는 기술 혁신의 시대입니다. 인공지능, 로봇공학, 생명공학 등 다양한 분야에서 놀라운 발전이 이루어지고 있습니다. 스마트폰 하나로 전 세계 사람들과 소통하고, 인터넷을 통해 무한한 정보에 접근할 수 있게 되었습니다. 자율주행 자동차가 도로를 달리고, 드론이 하늘을 날아다니며, 가상현실이 새로운 경험을 제공합니다. 이러한 기술들은 우리의 삶을 더욱 편리하고 풍요롭게 만들어주지만, 동시에 새로운 도전과 과제도 제시하고 있습니다.'
    },
    {
      'title': '환경 보호',
      'content':
          '지구 환경 보호는 현재 인류가 직면한 가장 중요한 과제 중 하나입니다. 기후 변화로 인해 극지방의 빙하가 녹고 있고, 해수면이 상승하고 있습니다. 대기 오염과 수질 오염은 생태계를 파괴하고 있으며, 많은 동식물들이 멸종 위기에 처해 있습니다. 우리는 재생 가능한 에너지를 사용하고, 플라스틱 사용을 줄이며, 친환경적인 생활 방식을 채택해야 합니다. 작은 실천이 모여 큰 변화를 만들 수 있습니다. 미래 세대를 위해 지금 행동해야 할 때입니다.'
    },
  ];

  final List<Map<String, String>> _englishTexts = [
    {
      'title': 'The Digital Revolution',
      'content':
          'The digital revolution has fundamentally transformed how we live, work, and communicate. From the invention of the personal computer to the rise of smartphones and social media, technology has reshaped every aspect of human society. We can now access vast amounts of information instantly, connect with people across the globe, and automate complex tasks. However, this digital transformation also brings challenges such as privacy concerns, digital divide, and the need for continuous learning to keep up with rapid technological changes.'
    },
    {
      'title': 'Climate Change',
      'content':
          'Climate change represents one of the most pressing challenges of our time. Rising global temperatures, melting ice caps, and extreme weather events are clear indicators that our planet is undergoing significant environmental changes. The primary cause is human activities, particularly the burning of fossil fuels and deforestation. To address this crisis, we need immediate action including transitioning to renewable energy sources, implementing sustainable practices, and fostering international cooperation to reduce greenhouse gas emissions.'
    },
    {
      'title': 'The Future of Education',
      'content':
          'Education is evolving rapidly in the 21st century. Traditional classroom-based learning is being supplemented and sometimes replaced by online platforms, virtual reality experiences, and personalized learning algorithms. Students can now access courses from top universities worldwide, learn at their own pace, and develop skills that are directly relevant to the modern job market. This transformation requires educators to adapt their teaching methods and students to become more self-directed learners.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectRandomText();
    _inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 랜덤 텍스트 선택
  void _selectRandomText() {
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);
    final isKorean = settingsController.language == LanguageOption.korean;

    final texts = isKorean ? _koreanTexts : _englishTexts;
    final randomIndex = Random().nextInt(texts.length);

    setState(() {
      _currentText = texts[randomIndex]['content']!;
      _sentences = _splitIntoSentences(_currentText);
      _currentSentenceIndex = 0;
      _currentSentence = _sentences.isNotEmpty ? _sentences[0] : '';
      _resetGame();
    });
  }

  // 텍스트를 문장으로 분리
  List<String> _splitIntoSentences(String text) {
    // 한국어와 영어 문장 구분자
    final sentenceEnders = RegExp(r'[.!?。！？]');

    List<String> sentences = [];
    List<String> parts = text.split(sentenceEnders);

    for (int i = 0; i < parts.length - 1; i++) {
      String sentence = parts[i].trim();
      if (sentence.isNotEmpty) {
        // 문장 끝 구두점 찾기
        int enderIndex = text.indexOf(
            sentenceEnders, text.indexOf(sentence) + sentence.length);
        if (enderIndex != -1) {
          sentence += text[enderIndex];
        }
        sentences.add(sentence);
      }
    }

    // 마지막 부분 처리 (구두점이 없는 경우)
    String lastPart = parts.last.trim();
    if (lastPart.isNotEmpty) {
      sentences.add(lastPart);
    }

    return sentences;
  }

  // 게임 초기화
  void _resetGame() {
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _isCompleted = false;
      _userInput = '';
      _currentPosition = 0;
      _correctChars = 0;
      _totalChars = 0;
      _errors = 0;
      _completedSentences = 0;
      _currentSentenceIndex = 0;
      if (_sentences.isNotEmpty) {
        _currentSentence = _sentences[0];
      }
      _startTime = null;
      _endTime = null;
      _elapsedTime = Duration.zero;
      _wpm = 0.0;
      _accuracy = 100.0;
    });

    _inputController.clear();
    _timer?.cancel();
  }

  // 게임 시작 (카운트다운 없이 바로 시작)
  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isPaused = false;
      _startTime = DateTime.now();
    });

    // 카운트다운 소리 제거 - 조용히 시작
    _inputFocusNode.requestFocus();

    // 타이머 시작
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isPaused && _isPlaying) {
        setState(() {
          _elapsedTime = DateTime.now().difference(_startTime!);
          _calculateWPM();
        });
      }
    });
  }

  // 게임 일시정지/재개
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _audioService.playSound(SoundType.pause);
    } else {
      _inputFocusNode.requestFocus();
    }
  }

  // 입력 변경 처리 (자동 시작 기능 포함)
  void _onInputChanged() {
    // 첫 입력 감지 시 자동으로 게임 시작
    if (!_isPlaying && !_isPaused && _inputController.text.isNotEmpty) {
      _startGame();
      return;
    }

    if (!_isPlaying || _isPaused) return;

    final input = _inputController.text;
    setState(() {
      _userInput = input;
      _currentPosition = input.length;
      _calculateAccuracy();
    });

    // 현재 문장 완성 확인
    if (input.trim() == _currentSentence.trim()) {
      _completeSentence();
    }

    // 키 입력 소리
    _audioService.playSound(SoundType.keyPress);
  }

  // 정확도 계산
  void _calculateAccuracy() {
    _totalChars = _userInput.length;
    _correctChars = 0;
    _errors = 0;

    for (int i = 0; i < _userInput.length && i < _currentSentence.length; i++) {
      if (_userInput[i] == _currentSentence[i]) {
        _correctChars++;
      } else {
        _errors++;
      }
    }

    _accuracy = _totalChars > 0 ? (_correctChars / _totalChars) * 100 : 100.0;
  }

  // WPM 계산
  void _calculateWPM() {
    if (_elapsedTime.inSeconds > 0) {
      final minutes = _elapsedTime.inSeconds / 60.0;
      final words = _correctChars / 5.0; // 5글자 = 1단어
      _wpm = words / minutes;
    }
  }

  // 문장 완성 처리
  void _completeSentence() {
    _audioService.playSound(SoundType.wordComplete);

    setState(() {
      _completedSentences++;
      _currentSentenceIndex++;
    });

    // 다음 문장이 있는지 확인
    if (_currentSentenceIndex < _sentences.length) {
      // 다음 문장으로 이동
      setState(() {
        _currentSentence = _sentences[_currentSentenceIndex];
        _userInput = '';
        _currentPosition = 0;
      });
      _inputController.clear();
      _inputFocusNode.requestFocus();
    } else {
      // 모든 문장 완료
      _completeGame();
    }
  }

  // 게임 완료
  void _completeGame() {
    setState(() {
      _isPlaying = false;
      _isCompleted = true;
      _endTime = DateTime.now();
    });

    _timer?.cancel();
    _calculateFinalStats();
    _audioService.playSound(SoundType.wordComplete);
    _saveSession();
  }

  // 최종 통계 계산
  void _calculateFinalStats() {
    _calculateAccuracy();
    _calculateWPM();
  }

  // 세션 저장
  void _saveSession() {
    final statsController =
        Provider.of<StatsController>(context, listen: false);

    // 긴글 연습은 기본 연습 세션으로 저장
    statsController.saveBasicPracticeSession(
      chars: _totalChars,
      correctChars: _correctChars,
      timeSpent: _elapsedTime.inMinutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = !isDesktop && !isTablet;
    final screenPadding = ResponsiveHelper.screenPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      // 키보드가 표시될 때 화면이 리사이징되도록 설정
      // 모바일 웹에서는 리사이징을 비활성화하여 키보드 공백 문제 해결
      resizeToAvoidBottomInset: !kIsWeb,
      body: Stack(
        children: [
          // 배경
          const SpaceBackground(
            particleDensity: 50,
            animateStars: true,
          ),

          // 메인 콘텐츠
          SafeArea(
            child: ResponsiveHelper.centeredContent(
              context: context,
              child: isMobile
                  ? _buildMobileLayout(context)
                  : _buildDesktopLayout(context),
            ),
          ),
        ],
      ),
    );
  }

  // 모바일용 레이아웃
  Widget _buildMobileLayout(BuildContext context) {
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
                          title: 'LONG TEXT PRACTICE',
                          subtitle: '문단 단위의 긴 텍스트로 타이핑 실력 향상',
                          centerAlign: true,
                          titleFontSize: isTablet ? 28 : 24,
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 모바일용 컴팩트 미니 대시보드
                  _buildMobileMiniDashboard(context),

                  const SizedBox(height: 12),

                  // 타이핑 영역
                  _buildMobileTypingArea(context),
                ],
              ),
            ),
          ),
        ),

        // 모바일에서 키보드 위에 고정되는 입력 필드
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
                  enabled: !_isPaused,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: _isPlaying && !_isPaused
                        ? '위의 현재 문장을 정확히 입력하세요...'
                        : _isPaused
                            ? '일시 정지됨'
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
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh,
                              color: AppColors.textSecondary),
                          onPressed: _selectRandomText,
                          tooltip: '새 텍스트',
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textSecondary),
                          onPressed: () => _inputController.clear(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 하단 입력 필드 옆에 일시정지/재개 버튼 추가
              if (_isPaused)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon:
                        const Icon(Icons.play_arrow, color: AppColors.primary),
                    onPressed: _resumeGame,
                    tooltip: '계속하기',
                  ),
                )
              else if (_isPlaying && !_isPaused)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: const Icon(Icons.pause, color: AppColors.warning),
                    onPressed: _togglePause,
                    tooltip: '일시정지',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // 모바일용 미니 대시보드
  Widget _buildMobileMiniDashboard(BuildContext context) {
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
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(_elapsedTime),
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 20,
                    color: AppColors.primary,
                    shadows: [
                      Shadow(
                        color: AppColors.primary,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 간단한 통계들
          _buildMiniStatItem(
              Icons.speed, _isPlaying ? _wpm.toStringAsFixed(1) : '0.0', 'WPM'),
          _buildMiniStatItem(Icons.check_circle_outline,
              _isPlaying ? '${_accuracy.toStringAsFixed(1)}%' : '100%', '정확도'),
          _buildMiniStatItem(
              Icons.text_fields,
              _isPlaying
                  ? '${_completedSentences + 1}/${_sentences.length}'
                  : '1/${_sentences.length}',
              '문장'),
        ],
      ),
    );
  }

  // 미니 통계 아이템
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

  // 모바일용 타이핑 영역
  Widget _buildMobileTypingArea(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 텍스트 표시 카드
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width < 600 ? 200 : 220,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundDarker,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontFamily: 'Rajdhani',
                  ),
                  children: _buildTextSpans(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 데스크톱용 레이아웃
  Widget _buildDesktopLayout(BuildContext context) {
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
                    title: 'LONG TEXT PRACTICE',
                    subtitle: '문단 단위의 긴 텍스트로 타이핑 실력 향상',
                    centerAlign: true,
                    titleFontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),

            const SizedBox(height: 20),

            // 통계 영역 - 웹 스타일의 통계 바 적용
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 720),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBox(
                      '시간',
                      _isPlaying ? _formatDuration(_elapsedTime) : '00:00',
                      Icons.timer),
                  const SizedBox(width: 12),
                  _buildStatBox(
                      'WPM',
                      _isPlaying ? _wpm.toStringAsFixed(1) : '0.0',
                      Icons.speed),
                  const SizedBox(width: 12),
                  _buildStatBox(
                      '정확도',
                      _isPlaying ? '${_accuracy.toStringAsFixed(1)}%' : '100%',
                      Icons.check_circle_outline),
                  const SizedBox(width: 12),
                  _buildStatBox(
                      '문장',
                      _isPlaying
                          ? '${_completedSentences + 1}/${_sentences.length}'
                          : '1/${_sentences.length}',
                      Icons.text_fields),
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
                  // 텍스트 표시 카드
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
                        // 텍스트 표시 영역
                        Container(
                          width: double.infinity,
                          height: isDesktop ? 250 : 220,
                          padding: EdgeInsets.all(isDesktop ? 20 : 16),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  fontFamily: 'Rajdhani',
                                ),
                                children: _buildTextSpans(),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 지시사항 텍스트
                        if (isDesktop || isTablet)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text(
                              '위의 현재 문장을 정확히 입력하세요. 문장을 완성하면 자동으로 다음 문장으로 이동합니다.',
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
                            enabled: !_isPaused,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              hintText: _isPlaying && !_isPaused
                                  ? '위의 현재 문장을 정확히 입력하세요...'
                                  : _isPaused
                                      ? '일시 정지됨'
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
                            ),
                          ),
                        ),
                      ],
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
                      onPressed: _resumeGame,
                    )
                  else if (_isPlaying && !_isPaused)
                    CosmicButton(
                      label: '일시정지',
                      icon: Icons.pause,
                      type: CosmicButtonType.outline,
                      size: isDesktop
                          ? CosmicButtonSize.large
                          : CosmicButtonSize.medium,
                      onPressed: _togglePause,
                    ),
                  CosmicButton(
                    label: '새 텍스트',
                    icon: Icons.refresh,
                    type: CosmicButtonType.secondary,
                    size: isDesktop
                        ? CosmicButtonSize.large
                        : CosmicButtonSize.medium,
                    onPressed: _selectRandomText,
                  ),
                  if (_isCompleted)
                    CosmicButton(
                      label: '다시 시작',
                      icon: Icons.replay,
                      type: CosmicButtonType.primary,
                      size: isDesktop
                          ? CosmicButtonSize.large
                          : CosmicButtonSize.medium,
                      onPressed: () {
                        _resetGame();
                        _inputFocusNode.requestFocus();
                      },
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

  // 텍스트 스팬 생성 (현재 문장과 다음 문장만 표시)
  List<TextSpan> _buildTextSpans() {
    List<TextSpan> spans = [];

    // 현재 문장 (강조 표시)
    if (_currentSentenceIndex < _sentences.length) {
      // 현재 문장 라벨
      spans.add(TextSpan(
        text: '현재 문장 (${_currentSentenceIndex + 1}/${_sentences.length}):\n',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ));

      // 현재 문장 내용 (타이핑 진행 상황 표시)
      for (int i = 0; i < _currentSentence.length; i++) {
        Color textColor;
        Color? backgroundColor;

        if (i < _userInput.length) {
          // 이미 입력된 부분
          if (i < _userInput.length && _userInput[i] == _currentSentence[i]) {
            textColor = AppColors.success; // 정확한 입력
          } else {
            textColor = AppColors.error; // 잘못된 입력
            backgroundColor = AppColors.error.withOpacity(0.2);
          }
        } else if (i == _userInput.length) {
          textColor = AppColors.primary; // 현재 입력 위치
          backgroundColor = AppColors.primary.withOpacity(0.3);
        } else {
          textColor = AppColors.textPrimary; // 아직 입력하지 않은 부분
        }

        spans.add(TextSpan(
          text: _currentSentence[i],
          style: TextStyle(
            color: textColor,
            backgroundColor: backgroundColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ));
      }

      spans.add(const TextSpan(text: '\n\n'));
    }

    // 다음 문장 (있는 경우, 연한 회색)
    if (_currentSentenceIndex + 1 < _sentences.length) {
      spans.add(TextSpan(
        text: '다음 문장:\n${_sentences[_currentSentenceIndex + 1]}',
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
          fontStyle: FontStyle.italic,
          height: 1.3,
        ),
      ));
    } else {
      // 마지막 문장인 경우
      spans.add(const TextSpan(
        text: '마지막 문장입니다! 🎉',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ));
    }

    return spans;
  }

  // 시간 포맷팅
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 게임 재개
  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
    _inputFocusNode.requestFocus();
  }

  // 나가기 확인 다이얼로그
  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLighter,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        title: const Text(
          '게임 종료',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '현재 게임을 종료하시겠습니까? 진행 상황이 저장되지 않습니다.',
          style: TextStyle(color: AppColors.textSecondary),
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
