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
  final String? customText;
  final String? customTitle;

  const LongTextPracticeScreen({
    super.key,
    this.customText,
    this.customTitle,
  });

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

  // 누적 통계 (전체 세션)
  int _totalCorrectChars = 0; // 완성된 문장들의 정확한 문자 수
  int _totalTypedChars = 0; // 완성된 문장들의 총 입력 문자 수
  int _errors = 0;
  int _completedSentences = 0;

  // 현재 문장 통계
  int _currentCorrectChars = 0; // 현재 문장에서 정확한 문자 수
  int _currentTotalChars = 0; // 현재 문장에서 입력한 총 문자 수

  // 시간 관련
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  // 통계
  double _cpm = 0.0;
  double _accuracy = 100.0;

  // 최종 통계 저장 변수들 추가
  double _finalCpm = 0.0;
  double _finalAccuracy = 0.0;
  Duration _finalElapsedTime = Duration.zero;
  int _finalCompletedSentences = 0;

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
    if (widget.customText != null) {
      _setCustomText(widget.customText!);
    } else {
      _selectRandomText();
    }
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

  // 커스텀 텍스트 설정
  void _setCustomText(String text) {
    setState(() {
      _currentText = text;
      _sentences = _splitIntoSentences(_currentText);
      _currentSentenceIndex = 0;
      _currentSentence = _sentences.isNotEmpty ? _sentences[0] : '';
      _resetGame();
    });
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

      // 누적 통계 초기화
      _totalCorrectChars = 0;
      _totalTypedChars = 0;
      _errors = 0;
      _completedSentences = 0;

      // 현재 문장 통계 초기화
      _currentCorrectChars = 0;
      _currentTotalChars = 0;

      _currentSentenceIndex = 0;
      if (_sentences.isNotEmpty) {
        _currentSentence = _sentences[0];
      }
      _startTime = null;
      _endTime = null;
      _elapsedTime = Duration.zero;
      _cpm = 0.0;
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
          _calculateCPM();
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
    // 게임 완료 상태에서는 입력 무시
    if (_isCompleted) {
      _inputController.clear();
      return;
    }

    // 첫 입력 감지 시 자동으로 게임 시작
    if (!_isPlaying && !_isPaused && _inputController.text.isNotEmpty) {
      _startGame();
      return;
    }

    // 게임이 진행 중이 아니거나 일시정지 상태에서는 입력 무시
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

  // 유니코드 안전 문자 길이 계산 (이모지 포함)
  int _getActualCharLength(String text) {
    if (text.isEmpty) return 0;

    int count = 0;
    for (int i = 0; i < text.length;) {
      final codeUnit = text.codeUnitAt(i);

      // 서로게이트 페어 확인 (이모지 등)
      if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF && i + 1 < text.length) {
        final nextCodeUnit = text.codeUnitAt(i + 1);
        if (nextCodeUnit >= 0xDC00 && nextCodeUnit <= 0xDFFF) {
          // 서로게이트 페어 (2개 코드 유닛 = 1개 문자)
          i += 2;
          count += 1;
        } else {
          // 일반 문자
          i += 1;
          count += 1;
        }
      } else {
        // 일반 문자
        i += 1;
        count += 1;
      }
    }

    return count;
  }

  // 유니코드 안전 문자 비교 (이모지 포함) - 조합 중 오타 평가 제외
  Map<String, int> _compareKoreanText(String input, String target) {
    double correctChars = 0.0;
    int errors = 0;
    int evaluatedChars = 0; // 실제 평가된 문자 수

    // 실제 문자 단위로 비교 (이모지 고려)
    final inputRunes = input.runes.toList();
    final targetRunes = target.runes.toList();

    final minLength = inputRunes.length < targetRunes.length
        ? inputRunes.length
        : targetRunes.length;

    for (int i = 0; i < minLength; i++) {
      final inputChar = String.fromCharCode(inputRunes[i]);
      final targetChar = String.fromCharCode(targetRunes[i]);

      if (inputChar == targetChar) {
        // 완전히 일치하는 경우
        correctChars += 1.0;
        evaluatedChars++;
      } else if (_isKoreanChar(inputChar) && _isKoreanChar(targetChar)) {
        // 둘 다 한글인 경우 조합 상태 확인
        if (_isInComposition(inputChar, targetChar)) {
          // 조합 중인 상태 - 평가하지 않음 (오타도 정답도 아님)
          continue;
        } else {
          // 조합이 완료된 상태에서 다른 문자 - 오타로 처리
          errors++;
          evaluatedChars++;
        }
      } else {
        // 한글이 아니거나 완전히 다른 문자 (이모지 포함) - 오타로 처리
        errors++;
        evaluatedChars++;
      }
    }

    return {
      'correct': correctChars.round(),
      'errors': errors,
      'evaluated': evaluatedChars, // 실제 평가된 문자 수 추가
    };
  }

  // 한글 조합 중인 상태인지 확인
  bool _isInComposition(String input, String target) {
    if (!_isKoreanChar(input) || !_isKoreanChar(target)) return false;

    final inputCode = input.codeUnitAt(0);
    final targetCode = target.codeUnitAt(0);

    // 하나는 자모, 하나는 완성형인 경우 (조합 중)
    if ((inputCode >= 0x3131 && inputCode <= 0x318E) ||
        (targetCode >= 0x3131 && targetCode <= 0x318E)) {
      return true;
    }

    // 둘 다 완성형 한글인 경우 조합 관계 확인
    if (inputCode >= 0xAC00 &&
        inputCode <= 0xD7A3 &&
        targetCode >= 0xAC00 &&
        targetCode <= 0xD7A3) {
      final inputDecomposed = _decomposeKorean(input);
      final targetDecomposed = _decomposeKorean(target);

      // 초성이 같고 중성이 다르거나 없는 경우 (조합 중)
      if (inputDecomposed['initial'] == targetDecomposed['initial']) {
        // 중성이 다르거나 하나가 없는 경우
        if (inputDecomposed['medial'] != targetDecomposed['medial']) {
          return true;
        }
        // 중성이 같고 종성이 다르거나 하나가 없는 경우
        if (inputDecomposed['medial'] == targetDecomposed['medial'] &&
            inputDecomposed['final'] != targetDecomposed['final']) {
          return true;
        }
      }
    }

    return false;
  }

  // 한글 문자인지 확인
  bool _isKoreanChar(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);

    // 한글 완성형 (가-힣)
    if (code >= 0xAC00 && code <= 0xD7A3) return true;

    // 한글 자모 (ㄱ-ㅎ, ㅏ-ㅣ)
    if (code >= 0x3131 && code <= 0x318E) return true;

    return false;
  }

  // 한글 분해 (초성, 중성, 종성)
  Map<String, String?> _decomposeKorean(String char) {
    if (char.isEmpty || !_isKoreanChar(char)) {
      return {'initial': null, 'medial': null, 'final': null};
    }

    final code = char.codeUnitAt(0);

    // 완성형 한글이 아닌 경우
    if (code < 0xAC00 || code > 0xD7A3) {
      return {'initial': char, 'medial': null, 'final': null};
    }

    // 한글 분해 공식
    final base = code - 0xAC00;
    final initialIndex = base ~/ (21 * 28);
    final medialIndex = (base % (21 * 28)) ~/ 28;
    final finalIndex = base % 28;

    // 초성, 중성, 종성 테이블
    const initials = [
      'ㄱ',
      'ㄲ',
      'ㄴ',
      'ㄷ',
      'ㄸ',
      'ㄹ',
      'ㅁ',
      'ㅂ',
      'ㅃ',
      'ㅅ',
      'ㅆ',
      'ㅇ',
      'ㅈ',
      'ㅉ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ'
    ];
    const medials = [
      'ㅏ',
      'ㅐ',
      'ㅑ',
      'ㅒ',
      'ㅓ',
      'ㅔ',
      'ㅕ',
      'ㅖ',
      'ㅗ',
      'ㅘ',
      'ㅙ',
      'ㅚ',
      'ㅛ',
      'ㅜ',
      'ㅝ',
      'ㅞ',
      'ㅟ',
      'ㅠ',
      'ㅡ',
      'ㅢ',
      'ㅣ'
    ];
    const finals = [
      '',
      'ㄱ',
      'ㄲ',
      'ㄳ',
      'ㄴ',
      'ㄵ',
      'ㄶ',
      'ㄷ',
      'ㄹ',
      'ㄺ',
      'ㄻ',
      'ㄼ',
      'ㄽ',
      'ㄾ',
      'ㄿ',
      'ㅀ',
      'ㅁ',
      'ㅂ',
      'ㅄ',
      'ㅅ',
      'ㅆ',
      'ㅇ',
      'ㅈ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ'
    ];

    return {
      'initial': initialIndex < initials.length ? initials[initialIndex] : null,
      'medial': medialIndex < medials.length ? medials[medialIndex] : null,
      'final': finalIndex < finals.length && finals[finalIndex].isNotEmpty
          ? finals[finalIndex]
          : null,
    };
  }

  // CPM 계산 (스무딩 적용) - 조합 중 문자 제외
  void _calculateCPM() {
    if (_elapsedTime.inSeconds > 0) {
      final minutes = _elapsedTime.inSeconds / 60.0;

      // 실제 완성된 문자 수 + 현재 평가 가능한 문자 수
      final totalEvaluatedChars = _totalCorrectChars + _currentCorrectChars;

      // 기본 CPM 계산 (조합 중인 문자 제외)
      final rawCpm = totalEvaluatedChars / minutes;

      // 부드러운 스무딩 적용
      if (_cpm > 0) {
        // 변화량에 따른 적응적 스무딩
        final changeRatio = (rawCpm - _cpm).abs() / max(_cpm, 1.0);
        final smoothingFactor = changeRatio > 0.2 ? 0.8 : 0.9; // 조합 제외로 더 안정적

        _cpm = (rawCpm * (1.0 - smoothingFactor)) + (_cpm * smoothingFactor);
      } else {
        _cpm = rawCpm;
      }

      // 비현실적인 값 제한 (최대 1000 CPM)
      _cpm = min(_cpm, 1000.0);
    }
  }

  // 정확도 계산 (현재 문장 + 누적) - 조합 중 문자 평가 제외
  void _calculateAccuracy() {
    // 현재 입력 길이가 목표 문장보다 긴 경우 제한
    final maxInputLength = _currentSentence.length;
    final limitedInput = _userInput.length > maxInputLength
        ? _userInput.substring(0, maxInputLength)
        : _userInput;

    // 한글 조합을 고려한 스마트 비교 (조합 중 문자 제외)
    final result = _compareKoreanText(limitedInput, _currentSentence);
    _currentCorrectChars = result['correct'] ?? 0;
    final currentEvaluatedChars = result['evaluated'] ?? 0; // 실제 평가된 문자 수

    // 현재 문장에서 실제 평가된 문자 수 사용
    _currentTotalChars = currentEvaluatedChars;

    // 전체 정확도 계산 (완성된 문장 + 현재 평가된 문장)
    final totalChars = _totalTypedChars + _currentTotalChars;
    final totalCorrect = _totalCorrectChars + _currentCorrectChars;

    _accuracy = totalChars > 0 ? (totalCorrect / totalChars) * 100 : 100.0;

    // 정확도가 100%를 초과하지 않도록 제한
    _accuracy = min(_accuracy, 100.0);
  }

  // 문장 완성 처리
  void _completeSentence() {
    _audioService.playSound(SoundType.wordComplete);

    // 완성된 문장의 실제 문자 수를 누적에 추가 (이모지 고려)
    final actualSentenceLength = _getActualCharLength(_currentSentence);
    _totalCorrectChars += actualSentenceLength;
    _totalTypedChars += actualSentenceLength;

    // 다음 문장으로 이동 또는 게임 완료
    _moveToNextSentence();

    // 입력 필드 정리 및 포커스
    _inputController.clear();
    if (!_isCompleted) {
      _inputFocusNode.requestFocus();
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
    _calculateCPM();
  }

  // 세션 저장
  void _saveSession() {
    final statsController =
        Provider.of<StatsController>(context, listen: false);

    // 최종 통계로 저장
    final finalTotalChars = _totalTypedChars + _currentTotalChars;
    final finalCorrectChars = _totalCorrectChars + _currentCorrectChars;

    // 긴글 연습은 기본 연습 세션으로 저장
    statsController.saveBasicPracticeSession(
      chars: finalTotalChars,
      correctChars: finalCorrectChars,
      timeSpent: _elapsedTime.inMinutes,
    );
  }

  // 새 게임 시작 (최종 결과 유지)
  void _startNewGame() {
    // 새 텍스트 선택
    _selectRandomText();

    // 게임 상태만 초기화 (최종 통계는 유지)
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _isCompleted = false;
      _userInput = '';
      _currentPosition = 0;

      // 새 게임을 위한 통계 초기화
      _totalCorrectChars = 0;
      _totalTypedChars = 0;
      _errors = 0;
      _completedSentences = 0;
      _currentCorrectChars = 0;
      _currentTotalChars = 0;

      _currentSentenceIndex = 0;
      if (_sentences.isNotEmpty) {
        _currentSentence = _sentences[0];
      }
      _startTime = null;
      _endTime = null;
      _elapsedTime = Duration.zero;
      _cpm = 0.0;
      _accuracy = 100.0;
    });

    _inputController.clear();
    _timer?.cancel();
    _inputFocusNode.requestFocus();
  }

  // 다음 문장으로 이동
  void _moveToNextSentence() {
    setState(() {
      _completedSentences++;
      _currentSentenceIndex++;
      _userInput = '';
      _currentPosition = 0;
      _currentCorrectChars = 0;
      _currentTotalChars = 0;

      if (_currentSentenceIndex >= _sentences.length) {
        // 모든 문장 완료 - 최종 통계 저장
        _finalCpm = _cpm;
        _finalAccuracy = _accuracy;
        _finalElapsedTime = _elapsedTime;
        _finalCompletedSentences = _completedSentences;
      } else {
        _currentSentence = _sentences[_currentSentenceIndex];
      }
    });

    // 게임 완료 체크
    if (_currentSentenceIndex >= _sentences.length) {
      _completeGame();
    }
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
                  enabled: !_isPaused && !_isCompleted,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: _isCompleted
                        ? '게임 완료! 다시 시작하려면 "다시 시작" 버튼을 클릭하세요'
                        : _isPlaying && !_isPaused
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
              Icons.speed, _isPlaying ? _cpm.toStringAsFixed(1) : '0.0', 'CPM'),
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
                    title: widget.customTitle ?? 'LONG TEXT PRACTICE',
                    subtitle: widget.customTitle != null
                        ? '공유 텍스트로 타이핑 연습'
                        : '문단 단위의 긴 텍스트로 타이핑 실력 향상',
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
                      _isCompleted
                          ? _formatDuration(_finalElapsedTime)
                          : _isPlaying
                              ? _formatDuration(_elapsedTime)
                              : '00:00',
                      Icons.timer),
                  const SizedBox(width: 12),
                  _buildStatBox(
                      'CPM',
                      _isCompleted
                          ? _finalCpm.toStringAsFixed(1)
                          : _isPlaying
                              ? _cpm.toStringAsFixed(1)
                              : '0.0',
                      Icons.speed),
                  const SizedBox(width: 12),
                  _buildStatBox(
                      '정확도',
                      _isCompleted
                          ? '${_finalAccuracy.toStringAsFixed(1)}%'
                          : _isPlaying
                              ? '${_accuracy.toStringAsFixed(1)}%'
                              : '100%',
                      Icons.check_circle_outline),
                  const SizedBox(width: 12),
                  _buildStatBox(
                      '문장',
                      _isCompleted
                          ? '$_finalCompletedSentences/${_sentences.length}'
                          : _isPlaying
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
                            enabled: !_isPaused && !_isCompleted,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              hintText: _isCompleted
                                  ? '게임 완료! 다시 시작하려면 "다시 시작" 버튼을 클릭하세요'
                                  : _isPlaying && !_isPaused
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
                      onPressed: _startNewGame,
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

  // 텍스트 스팬 생성 (게임 완료 시 간단한 메시지만 표시)
  List<TextSpan> _buildTextSpans() {
    List<TextSpan> spans = [];

    // 게임 완료 시 간단한 완료 메시지만 표시
    if (_isCompleted) {
      spans.add(const TextSpan(
        text: '🎉 게임 완료! 🎉\n\n',
        style: TextStyle(
          color: AppColors.success,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ));

      spans.add(const TextSpan(
        text: '모든 문장을 성공적으로 완성했습니다!\n',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          height: 1.4,
        ),
      ));

      spans.add(const TextSpan(
        text: '최종 결과는 위의 통계 박스에서 확인하세요.\n\n',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          height: 1.4,
        ),
      ));

      spans.add(const TextSpan(
        text: '새로운 도전을 위해 "다시 시작" 버튼을 클릭하세요! 🚀',
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          height: 1.3,
        ),
      ));

      return spans;
    }

    // 게임 진행 중일 때는 기존 로직 사용
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
    } else if (!_isCompleted) {
      // 마지막 문장인 경우 (게임 진행 중)
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
