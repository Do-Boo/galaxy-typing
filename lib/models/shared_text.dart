// 공유 텍스트 데이터 모델
// 작성: 2025-06-10
// 사용자가 업로드하고 공유할 수 있는 텍스트 데이터 구조

class SharedText {
  final String id;
  final String title;
  final String content;
  final String category;
  final String difficulty;
  final String language;
  final String authorName;
  final DateTime createdAt;
  final int downloadCount;
  final double rating;
  final List<String> tags;
  final String description;

  SharedText({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.difficulty,
    required this.language,
    required this.authorName,
    required this.createdAt,
    this.downloadCount = 0,
    this.rating = 0.0,
    this.tags = const [],
    this.description = '',
  });

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'difficulty': difficulty,
      'language': language,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'downloadCount': downloadCount,
      'rating': rating,
      'tags': tags,
      'description': description,
    };
  }

  // JSON에서 생성
  factory SharedText.fromJson(Map<String, dynamic> json) {
    return SharedText(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? '',
      language: json['language'] ?? '',
      authorName: json['authorName'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      downloadCount: json['downloadCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'] ?? '',
    );
  }

  // 복사본 생성 (일부 필드 수정)
  SharedText copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? difficulty,
    String? language,
    String? authorName,
    DateTime? createdAt,
    int? downloadCount,
    double? rating,
    List<String>? tags,
    String? description,
  }) {
    return SharedText(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      language: language ?? this.language,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      downloadCount: downloadCount ?? this.downloadCount,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      description: description ?? this.description,
    );
  }

  // 텍스트 길이 계산
  int get textLength => content.length;

  // 예상 타이핑 시간 계산 (분) - 평균 타이핑 속도 200 CPM 기준
  int get estimatedMinutes => (textLength / 200).ceil();

  // 문장 수 계산
  int get sentenceCount {
    if (content.isEmpty) return 0;

    // 한국어와 영어 문장 끝 구두점
    final sentenceEnders = RegExp(r'[.!?。！？]');
    final matches = sentenceEnders.allMatches(content);
    return matches.isNotEmpty ? matches.length : 1;
  }
}

// 카테고리 상수
class TextCategories {
  static const String novel = '소설';
  static const String news = '뉴스';
  static const String technology = '기술';
  static const String business = '비즈니스';
  static const String poetry = '시';
  static const String lyrics = '가사';
  static const String essay = '에세이';
  static const String academic = '학술';
  static const String other = '기타';

  static const List<String> all = [
    novel,
    news,
    technology,
    business,
    poetry,
    lyrics,
    essay,
    academic,
    other,
  ];
}

// 난이도 상수
class TextDifficulties {
  static const String beginner = '초급';
  static const String intermediate = '중급';
  static const String advanced = '고급';
  static const String expert = '전문가';

  static const List<String> all = [
    beginner,
    intermediate,
    advanced,
    expert,
  ];
}

// 언어 상수
class TextLanguages {
  static const String korean = '한국어';
  static const String english = '영어';
  static const String mixed = '혼합';

  static const List<String> all = [
    korean,
    english,
    mixed,
  ];
}
