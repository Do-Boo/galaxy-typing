// 단어 데이터 모델
// 작성: 2023-05-10
// 업데이트: 2024-06-02 (다국어 지원 추가)
// 타자 연습에 사용되는 단어 데이터 관리

import 'dart:math';
import '../models/game_settings.dart';

/// 타자 연습에 사용되는 단어 데이터 관리 클래스
class WordData {
  // 쉬운 난이도 단어 목록 (한국어)
  static final List<String> _easyWordsKorean = [
    '나무',
    '바다',
    '하늘',
    '사과',
    '자동차',
    '연필',
    '학교',
    '책상',
    '의자',
    '가방',
    '시계',
    '바람',
    '햇빛',
    '물고기',
    '거북이',
    '토끼',
    '개구리',
    '고양이',
    '강아지',
    '나비',
    '별자리',
    '꽃잎',
    '과일',
    '야채',
    '소리',
    '색깔',
    '모양',
    '달력',
    '시간',
    '날씨',
    '창문',
    '문화',
    '역사',
    '우주',
    '지구',
    '달',
    '해',
    '산',
    '무지개',
    '눈사람',
    '아침',
    '저녁',
    '점심',
    '밤',
    '낮',
    '사랑',
    '행복',
    '슬픔',
    '기쁨',
    '건강',
  ];

  // 보통 난이도 단어 목록 (한국어)
  static final List<String> _mediumWordsKorean = [
    '프로그램',
    '컴퓨터',
    '스마트폰',
    '인터넷',
    '네트워크',
    '우주선',
    '인공지능',
    '빅데이터',
    '클라우드',
    '가상현실',
    '증강현실',
    '블록체인',
    '암호화폐',
    '자율주행',
    '드론',
    '로봇공학',
    '생명과학',
    '유전공학',
    '재생에너지',
    '친환경',
    '지속가능',
    '생태계',
    '경제성장',
    '정치철학',
    '문화예술',
    '심리학적',
    '철학적인',
    '우주만물',
    '천체물리',
    '진화과정',
    '국제관계',
    '외교정책',
    '사회구조',
    '교육제도',
    '의료체계',
    '금융시장',
    '투자전략',
    '경영방침',
    '마케팅',
    '브랜드',
    '환경보호',
    '자원순환',
    '기후변화',
    '생물다양성',
    '에너지',
    '통신기술',
    '미디어',
    '방송국',
    '신문사',
    '출판업계',
  ];

  // 어려운 난이도 단어 목록 (한국어)
  static final List<String> _hardWordsKorean = [
    '양자역학',
    '상대성이론',
    '열역학법칙',
    '광자충돌',
    '블랙홀',
    '초신성폭발',
    '중성미자',
    '쿼크글루온',
    '초끈이론',
    '다중우주',
    '의식의흐름기법',
    '실존주의철학',
    '형이상학적사유',
    '인식론적한계',
    '초월적경험',
    '자기계발과성장',
    '창의적사고방식',
    '비판적분석능력',
    '체계적문제해결',
    '혁신적발상',
    '환경오염방지정책',
    '지속가능한개발',
    '생태계보존활동',
    '기후변화대응',
    '탄소중립',
    '국제통상협정',
    '다자간외교관계',
    '경제블록형성',
    '지정학적갈등',
    '안보리협의',
    '인공지능윤리',
    '데이터주권문제',
    '개인정보보호',
    '사이버보안',
    '디지털트랜스포메이션',
    '양자컴퓨팅',
    '기계학습알고리즘',
    '신경망네트워크',
    '딥러닝모델',
    '자연어처리',
    '유전자가위기술',
    '줄기세포연구',
    '바이오인포매틱스',
    '합성생물학',
    '유전체편집',
    '면역치료법',
    '정밀의학',
    '재생의학',
    '줄기세포치료',
    '유전자치료',
  ];

  // 쉬운 난이도 단어 목록 (영어)
  static final List<String> _easyWordsEnglish = [
    'tree',
    'sea',
    'sky',
    'apple',
    'car',
    'pencil',
    'school',
    'desk',
    'chair',
    'bag',
    'clock',
    'wind',
    'sun',
    'fish',
    'turtle',
    'rabbit',
    'frog',
    'cat',
    'dog',
    'butterfly',
    'star',
    'petal',
    'fruit',
    'vegetable',
    'sound',
    'color',
    'shape',
    'calendar',
    'time',
    'weather',
    'window',
    'culture',
    'history',
    'space',
    'earth',
    'moon',
    'sun',
    'mountain',
    'rainbow',
    'snowman',
    'morning',
    'evening',
    'lunch',
    'night',
    'day',
    'love',
    'happy',
    'sad',
    'joy',
    'health',
  ];

  // 보통 난이도 단어 목록 (영어)
  static final List<String> _mediumWordsEnglish = [
    'program',
    'computer',
    'smartphone',
    'internet',
    'network',
    'spaceship',
    'artificial',
    'bigdata',
    'cloud',
    'virtual',
    'augmented',
    'blockchain',
    'crypto',
    'autonomous',
    'drone',
    'robotics',
    'biology',
    'genetic',
    'renewable',
    'eco',
    'sustainable',
    'ecosystem',
    'economic',
    'philosophy',
    'culture',
    'psychological',
    'philosophical',
    'universe',
    'astrophysics',
    'evolution',
    'international',
    'diplomacy',
    'society',
    'education',
    'healthcare',
    'financial',
    'investment',
    'management',
    'marketing',
    'brand',
    'environmental',
    'recycling',
    'climate',
    'biodiversity',
    'energy',
    'communication',
    'media',
    'broadcast',
    'newspaper',
    'publishing',
  ];

  // 어려운 난이도 단어 목록 (영어)
  static final List<String> _hardWordsEnglish = [
    'quantum mechanics',
    'relativity theory',
    'thermodynamics',
    'photon collision',
    'black hole',
    'supernova explosion',
    'neutrino',
    'quark gluon',
    'string theory',
    'multiverse',
    'stream of consciousness',
    'existentialism',
    'metaphysical thought',
    'epistemological',
    'transcendental',
    'self development',
    'creative thinking',
    'critical analysis',
    'problem solving',
    'innovation',
    'pollution prevention',
    'sustainable development',
    'ecosystem conservation',
    'climate adaptation',
    'carbon neutral',
    'trade agreement',
    'multilateral diplomacy',
    'economic block',
    'geopolitical conflict',
    'security council',
    'AI ethics',
    'data sovereignty',
    'privacy protection',
    'cybersecurity',
    'digital transformation',
    'quantum computing',
    'machine learning',
    'neural network',
    'deep learning',
    'natural language',
    'gene editing',
    'stem cell research',
    'bioinformatics',
    'synthetic biology',
    'genome editing',
    'immunotherapy',
    'precision medicine',
    'regenerative medicine',
    'stem cell therapy',
    'gene therapy',
  ];

  /// 난이도에 따른 단어 목록 가져오기 (한국어 기본값)
  static List<String> getWordsByDifficulty(
    DifficultyLevel difficulty, {
    LanguageOption language = LanguageOption.korean,
  }) {
    switch (language) {
      case LanguageOption.korean:
        switch (difficulty) {
          case DifficultyLevel.easy:
            return _easyWordsKorean;
          case DifficultyLevel.medium:
            return _mediumWordsKorean;
          case DifficultyLevel.hard:
            return _hardWordsKorean;
        }
      case LanguageOption.english:
        switch (difficulty) {
          case DifficultyLevel.easy:
            return _easyWordsEnglish;
          case DifficultyLevel.medium:
            return _mediumWordsEnglish;
          case DifficultyLevel.hard:
            return _hardWordsEnglish;
        }
    }
  }

  /// 선택한 언어로 모든 난이도의 단어 가져오기
  static List<String> getAllWordsByLanguage(LanguageOption language) {
    switch (language) {
      case LanguageOption.korean:
        return [
          ..._easyWordsKorean,
          ..._mediumWordsKorean,
          ..._hardWordsKorean
        ];
      case LanguageOption.english:
        return [
          ..._easyWordsEnglish,
          ..._mediumWordsEnglish,
          ..._hardWordsEnglish
        ];
    }
  }

  // 우주 디펜스 게임용 단어 목록
  static final List<String> _spaceDefenseEasyWords = [
    '지구',
    '달',
    '별',
    '화성',
    '목성',
    '태양',
    '혜성',
    '운석',
    'earth',
    'moon',
    'star',
    'mars',
    'venus',
    'sun',
    'comet',
    'meteor',
    'ship',
    'space',
    'alien',
    'planet',
    'orbit',
    'light',
    'solar',
    'beam',
  ];

  static final List<String> _spaceDefenseMediumWords = [
    '우주선',
    '행성',
    '은하계',
    '블랙홀',
    '인공위성',
    '소행성',
    '중력',
    'spaceship',
    'galaxy',
    'blackhole',
    'asteroid',
    'satellite',
    'gravity',
    'nebula',
    'universe',
    'telescope',
    'mission',
    'cosmic',
    'station',
    'launcher',
    'explorer',
    'discovery',
    'shuttle',
    'voyage',
    'rocket',
  ];

  static final List<String> _spaceDefenseHardWords = [
    '인공위성',
    '우주정거장',
    '외계생명체',
    '중력가속도',
    '행성간여행',
    'interstellar',
    'gravitational',
    'extraterrestrial',
    'constellation',
    'astrophysics',
    'colonization',
    'terraforming',
    'wormhole',
    'spacecraft',
    'astronomical',
    'Andromeda-1',
    'Mars@2030',
    'Space-X',
    'Alpha-Centauri',
  ];

  /// 우주 디펜스 게임용 단어 목록 가져오기
  static List<String> getSpaceDefenseWords(
    DifficultyLevel difficulty, {
    LanguageOption language = LanguageOption.korean,
  }) {
    // 우주 디펜스 게임은 양쪽 언어의 단어를 모두 사용하지만,
    // 언어 선택에 따라 자국어 단어의 비중을 높입니다.
    final List<String> result = [];

    switch (difficulty) {
      case DifficultyLevel.easy:
        result.addAll(_spaceDefenseEasyWords);
        break;
      case DifficultyLevel.medium:
        result.addAll(_spaceDefenseMediumWords);
        break;
      case DifficultyLevel.hard:
        result.addAll(_spaceDefenseHardWords);
        break;
    }

    // 선택한 언어의 일반 단어도 일부 추가
    if (language == LanguageOption.korean) {
      result.addAll(_easyWordsKorean.take(10));
    } else {
      result.addAll(_easyWordsEnglish.take(10));
    }

    return result;
  }

  /// 모든 난이도의 단어를 섞어서 가져오기
  static List<String> getAllWords() {
    final allWords = [
      ..._easyWordsKorean,
      ..._mediumWordsKorean,
      ..._hardWordsKorean,
    ];

    // 리스트 섞기
    final random = Random();
    allWords.shuffle(random);

    return allWords;
  }

  /// 난이도별 랜덤 단어 가져오기
  static String getRandomWord(
    DifficultyLevel difficulty, {
    LanguageOption language = LanguageOption.korean,
  }) {
    final words = getWordsByDifficulty(difficulty, language: language);
    final random = Random();
    return words[random.nextInt(words.length)];
  }

  /// 문장 생성 (여러 단어를 결합)
  static String generateSentence(
    DifficultyLevel difficulty,
    int wordCount, {
    LanguageOption language = LanguageOption.korean,
  }) {
    final words = getWordsByDifficulty(difficulty, language: language);
    final random = Random();
    final sentence = <String>[];

    for (int i = 0; i < wordCount; i++) {
      sentence.add(words[random.nextInt(words.length)]);
    }

    return sentence.join(' ');
  }
}

// 참고: DifficultyLevel은 game_settings.dart에서 가져옵니다.
