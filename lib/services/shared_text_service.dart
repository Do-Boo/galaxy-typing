// 공유 텍스트 서비스
// 작성: 2025-06-10
// 공유 텍스트의 저장, 로드, 관리를 담당하는 서비스

import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/shared_text.dart';

class SharedTextService {
  static const String _sharedTextsKey = 'shared_texts';
  static const String _myTextsKey = 'my_texts';

  // 싱글톤 패턴
  static final SharedTextService _instance = SharedTextService._internal();
  factory SharedTextService() => _instance;
  SharedTextService._internal();

  // 모든 공유 텍스트 가져오기
  Future<List<SharedText>> getAllSharedTexts() async {
    final prefs = await SharedPreferences.getInstance();
    final textsJson = prefs.getString(_sharedTextsKey);

    if (textsJson == null) {
      // 초기 샘플 데이터 생성
      final sampleTexts = _createSampleTexts();
      await _saveSharedTexts(sampleTexts);
      return sampleTexts;
    }

    final List<dynamic> textsList = json.decode(textsJson);
    return textsList.map((json) => SharedText.fromJson(json)).toList();
  }

  // 내가 업로드한 텍스트 가져오기
  Future<List<SharedText>> getMyTexts() async {
    final prefs = await SharedPreferences.getInstance();
    final textsJson = prefs.getString(_myTextsKey);

    if (textsJson == null) return [];

    final List<dynamic> textsList = json.decode(textsJson);
    return textsList.map((json) => SharedText.fromJson(json)).toList();
  }

  // 새 텍스트 업로드
  Future<bool> uploadText(SharedText text) async {
    try {
      // 고유 ID 생성
      final textWithId = text.copyWith(
        id: _generateId(),
        createdAt: DateTime.now(),
      );

      // 공유 텍스트 목록에 추가
      final allTexts = await getAllSharedTexts();
      allTexts.insert(0, textWithId); // 최신 순으로 정렬
      await _saveSharedTexts(allTexts);

      // 내 텍스트 목록에도 추가
      final myTexts = await getMyTexts();
      myTexts.insert(0, textWithId);
      await _saveMyTexts(myTexts);

      return true;
    } catch (e) {
      return false;
    }
  }

  // 텍스트 다운로드 (다운로드 수 증가)
  Future<SharedText?> downloadText(String textId) async {
    try {
      final allTexts = await getAllSharedTexts();
      final textIndex = allTexts.indexWhere((text) => text.id == textId);

      if (textIndex == -1) return null;

      // 다운로드 수 증가
      final updatedText = allTexts[textIndex].copyWith(
        downloadCount: allTexts[textIndex].downloadCount + 1,
      );

      allTexts[textIndex] = updatedText;
      await _saveSharedTexts(allTexts);

      return updatedText;
    } catch (e) {
      return null;
    }
  }

  // 텍스트 검색
  Future<List<SharedText>> searchTexts({
    String? query,
    String? category,
    String? difficulty,
    String? language,
  }) async {
    final allTexts = await getAllSharedTexts();

    return allTexts.where((text) {
      // 검색어 필터
      if (query != null && query.isNotEmpty) {
        final searchQuery = query.toLowerCase();
        if (!text.title.toLowerCase().contains(searchQuery) &&
            !text.content.toLowerCase().contains(searchQuery) &&
            !text.tags.any((tag) => tag.toLowerCase().contains(searchQuery))) {
          return false;
        }
      }

      // 카테고리 필터
      if (category != null &&
          category.isNotEmpty &&
          text.category != category) {
        return false;
      }

      // 난이도 필터
      if (difficulty != null &&
          difficulty.isNotEmpty &&
          text.difficulty != difficulty) {
        return false;
      }

      // 언어 필터
      if (language != null &&
          language.isNotEmpty &&
          text.language != language) {
        return false;
      }

      return true;
    }).toList();
  }

  // 인기 텍스트 가져오기 (다운로드 수 기준)
  Future<List<SharedText>> getPopularTexts({int limit = 10}) async {
    final allTexts = await getAllSharedTexts();
    allTexts.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    return allTexts.take(limit).toList();
  }

  // 최신 텍스트 가져오기
  Future<List<SharedText>> getRecentTexts({int limit = 10}) async {
    final allTexts = await getAllSharedTexts();
    allTexts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allTexts.take(limit).toList();
  }

  // 카테고리별 텍스트 가져오기
  Future<List<SharedText>> getTextsByCategory(String category) async {
    final allTexts = await getAllSharedTexts();
    return allTexts.where((text) => text.category == category).toList();
  }

  // 내부 메서드들
  Future<void> _saveSharedTexts(List<SharedText> texts) async {
    final prefs = await SharedPreferences.getInstance();
    final textsJson = json.encode(texts.map((text) => text.toJson()).toList());
    await prefs.setString(_sharedTextsKey, textsJson);
  }

  Future<void> _saveMyTexts(List<SharedText> texts) async {
    final prefs = await SharedPreferences.getInstance();
    final textsJson = json.encode(texts.map((text) => text.toJson()).toList());
    await prefs.setString(_myTextsKey, textsJson);
  }

  String _generateId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(9999);
    return '${timestamp}_$randomNum';
  }

  // 샘플 데이터 생성
  List<SharedText> _createSampleTexts() {
    return [
      SharedText(
        id: _generateId(),
        title: '봄날의 추억',
        content: '''벚꽃이 흩날리는 봄날, 나는 오래된 친구와 함께 공원을 걸었다. 
따뜻한 햇살이 우리의 어깨를 감싸며, 지난 시절의 추억들이 하나둘씩 떠올랐다. 
그때는 몰랐지만, 그 순간이 얼마나 소중한 시간이었는지 이제야 깨닫는다. 
시간은 빠르게 흘러가지만, 진정한 우정은 영원히 남는다는 것을 배웠다.''',
        category: TextCategories.essay,
        difficulty: TextDifficulties.intermediate,
        language: TextLanguages.korean,
        authorName: '익명의 작가',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        downloadCount: 42,
        rating: 4.5,
        tags: ['봄', '우정', '추억', '감성'],
        description: '봄날의 아름다운 추억을 담은 짧은 에세이입니다.',
      ),
      SharedText(
        id: _generateId(),
        title: 'The Future of Technology',
        content: '''Technology continues to evolve at an unprecedented pace. 
Artificial intelligence, machine learning, and quantum computing are reshaping our world. 
These innovations promise to solve complex problems and create new opportunities. 
However, we must also consider the ethical implications and ensure that technology serves humanity's best interests.''',
        category: TextCategories.technology,
        difficulty: TextDifficulties.advanced,
        language: TextLanguages.english,
        authorName: 'Tech Writer',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        downloadCount: 28,
        rating: 4.2,
        tags: ['AI', 'technology', 'future', 'innovation'],
        description:
            'An article about the future of technology and its impact on society.',
      ),
      SharedText(
        id: _generateId(),
        title: '커피 한 잔의 여유',
        content: '''바쁜 일상 속에서 잠시 멈춰 서서 커피 한 잔을 마시는 시간. 
향긋한 커피 향이 코끝을 스치며 마음이 차분해진다. 
창밖으로 보이는 풍경을 바라보며 오늘 하루를 돌아본다. 
작은 여유가 주는 행복이 이렇게 클 줄 몰랐다.''',
        category: TextCategories.essay,
        difficulty: TextDifficulties.beginner,
        language: TextLanguages.korean,
        authorName: '카페 애호가',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        downloadCount: 15,
        rating: 4.0,
        tags: ['커피', '여유', '일상', '힐링'],
        description: '일상의 소소한 행복을 담은 글입니다.',
      ),
    ];
  }
}
