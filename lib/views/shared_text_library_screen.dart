// 공유 텍스트 라이브러리 화면
// 작성: 2024-05-15
// 업데이트: 2025-06-18 (간소화된 레이아웃으로 재구성)
// 다른 사용자들이 공유한 텍스트를 탐색하고 다운로드할 수 있는 간단한 화면

import 'package:flutter/material.dart';

import '../models/shared_text.dart';
import '../services/audio_service.dart';
import '../services/shared_text_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/back_button.dart';
import '../widgets/cosmic_button.dart';
import '../widgets/cosmic_card.dart';
import '../widgets/cosmic_input_field.dart';
import '../widgets/page_header.dart';
import '../widgets/space_background.dart';

class SharedTextLibraryScreen extends StatefulWidget {
  const SharedTextLibraryScreen({super.key});

  @override
  _SharedTextLibraryScreenState createState() =>
      _SharedTextLibraryScreenState();
}

class _SharedTextLibraryScreenState extends State<SharedTextLibraryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _audioService = AudioService();
  final _sharedTextService = SharedTextService();

  // 상태 변수들
  List<SharedText> _allTexts = [];
  List<SharedText> _filteredTexts = [];
  bool _isLoading = true;
  String _selectedCategory = '전체';
  String _selectedDifficulty = '전체';
  final _searchController = TextEditingController();

  // 필터 옵션
  final List<String> _categories = ['전체', '일반', '소설', '시', '뉴스', '기술', '기타'];
  final List<String> _difficulties = ['전체', '초급', '중급', '고급'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 음악 중지
    _audioService.stop();

    // 데이터 로드
    _loadTexts();

    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTexts() async {
    print('텍스트 로딩 시작');
    setState(() => _isLoading = true);

    try {
      final texts = await _sharedTextService.getAllSharedTexts();
      print('로드된 텍스트 수: ${texts.length}');
      setState(() {
        _allTexts = texts;
        _filteredTexts = texts;
        _isLoading = false;
      });
      print('텍스트 로딩 완료');
    } catch (e) {
      print('텍스트 로딩 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterTexts() {
    setState(() {
      _filteredTexts = _allTexts.where((text) {
        // 검색어 필터
        final searchQuery = _searchController.text.toLowerCase();
        if (searchQuery.isNotEmpty) {
          if (!text.title.toLowerCase().contains(searchQuery) &&
              !text.content.toLowerCase().contains(searchQuery)) {
            return false;
          }
        }

        // 카테고리 필터
        if (_selectedCategory != '전체' && text.category != _selectedCategory) {
          return false;
        }

        // 난이도 필터
        if (_selectedDifficulty != '전체' &&
            text.difficulty != _selectedDifficulty) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final screenPadding = ResponsiveHelper.screenPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ResponsiveHelper.centeredContent(
                context: context,
                child: Scrollbar(
                  thumbVisibility: false,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: screenPadding,
                      child: Column(
                        children: [
                          SizedBox(height: isDesktop ? 20 : 10),

                          // 헤더
                          Row(
                            children: [
                              CosmicBackButton(
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const Expanded(
                                child: PageHeader(
                                  title: 'TEXT LIBRARY',
                                  subtitle: '공유 텍스트 라이브러리',
                                  centerAlign: true,
                                ),
                              ),
                              CosmicButton(
                                label: isDesktop ? '새 텍스트 업로드' : '',
                                icon: Icons.add,
                                type: CosmicButtonType.primary,
                                size: isDesktop
                                    ? CosmicButtonSize.medium
                                    : CosmicButtonSize.small,
                                onPressed: () async {
                                  print('새 텍스트 업로드 버튼 클릭됨');
                                  try {
                                    final result = await Navigator.of(context)
                                        .pushNamed('/text-upload');
                                    print('업로드 화면에서 돌아옴: $result');
                                    if (result == true) {
                                      _loadTexts();
                                    }
                                  } catch (e) {
                                    print('업로드 화면 이동 오류: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('업로드 화면으로 이동 중 오류: $e'),
                                        backgroundColor: AppColors.error,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 검색 및 필터
                          _buildSearchAndFilter(context),

                          const SizedBox(height: 16),

                          // 텍스트 목록
                          if (_isLoading)
                            _buildLoadingWidget()
                          else if (_filteredTexts.isEmpty)
                            _buildEmptyWidget()
                          else
                            _buildTextList(context),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 검색 및 필터
  Widget _buildSearchAndFilter(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return CosmicCard(
      title: '검색 및 필터',
      titleIcon: Icons.search,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 검색 필드
            CosmicInputField(
              controller: _searchController,
              label: '검색',
              hintText: '제목이나 내용으로 검색하세요',
              prefixIcon: Icons.search,
              onChanged: (_) => _filterTexts(),
            ),

            const SizedBox(height: 16),

            // 필터
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildDropdown(
                      '카테고리',
                      _selectedCategory,
                      _categories,
                      (value) {
                        setState(() => _selectedCategory = value!);
                        _filterTexts();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      '난이도',
                      _selectedDifficulty,
                      _difficulties,
                      (value) {
                        setState(() => _selectedDifficulty = value!);
                        _filterTexts();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: CosmicButton(
                      label: '초기화',
                      icon: Icons.refresh,
                      type: CosmicButtonType.outline,
                      size: CosmicButtonSize.medium,
                      onPressed: _resetFilters,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildDropdown(
                    '카테고리',
                    _selectedCategory,
                    _categories,
                    (value) {
                      setState(() => _selectedCategory = value!);
                      _filterTexts();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    '난이도',
                    _selectedDifficulty,
                    _difficulties,
                    (value) {
                      setState(() => _selectedDifficulty = value!);
                      _filterTexts();
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CosmicButton(
                      label: '초기화',
                      icon: Icons.refresh,
                      type: CosmicButtonType.outline,
                      size: CosmicButtonSize.medium,
                      onPressed: _resetFilters,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // 텍스트 목록
  Widget _buildTextList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 목록 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.list, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '텍스트 목록 (${_filteredTexts.length}개)',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 텍스트 아이템들
        ..._filteredTexts.map((text) => _buildTextItem(context, text)),
      ],
    );
  }

  // 텍스트 아이템
  Widget _buildTextItem(BuildContext context, SharedText text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목과 카테고리
          Row(
            children: [
              Expanded(
                child: Text(
                  text.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text.category,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 작성자와 난이도
          Row(
            children: [
              const Icon(Icons.person,
                  color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 4),
              Text(
                text.authorName,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.bar_chart,
                  color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 4),
              Text(
                text.difficulty,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 내용 미리보기
          Text(
            text.content.length > 100
                ? '${text.content.substring(0, 100)}...'
                : text.content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // 다운로드 버튼과 정보
          Row(
            children: [
              CosmicButton(
                label: '연습하기',
                icon: Icons.play_arrow,
                type: CosmicButtonType.primary,
                size: CosmicButtonSize.small,
                onPressed: () {
                  print('연습하기 버튼 onPressed 호출됨');
                  _startPractice(text);
                },
              ),
              const SizedBox(width: 12),
              CosmicButton(
                label: '다운로드',
                icon: Icons.download,
                type: CosmicButtonType.outline,
                size: CosmicButtonSize.small,
                onPressed: () {
                  print('다운로드 버튼 onPressed 호출됨');
                  _downloadText(text);
                },
              ),
              const Spacer(),
              Text(
                '다운로드 ${text.downloadCount}회',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 로딩 위젯
  Widget _buildLoadingWidget() {
    return const CosmicCard(
      title: '로딩 중...',
      titleIcon: Icons.hourglass_empty,
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  // 빈 목록 위젯
  Widget _buildEmptyWidget() {
    return CosmicCard(
      title: '검색 결과 없음',
      titleIcon: Icons.search_off,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(
              Icons.text_snippet_outlined,
              color: AppColors.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              '검색 조건에 맞는 텍스트가 없습니다.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CosmicButton(
              label: '필터 초기화',
              icon: Icons.refresh,
              type: CosmicButtonType.outline,
              size: CosmicButtonSize.medium,
              onPressed: _resetFilters,
            ),
          ],
        ),
      ),
    );
  }

  // 드롭다운 빌더
  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.backgroundLighter,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            underline: const SizedBox(),
            isExpanded: true,
            dropdownColor: AppColors.backgroundLighter,
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  // 필터 초기화
  void _resetFilters() {
    print('필터 초기화 버튼 클릭됨');
    setState(() {
      _selectedCategory = '전체';
      _selectedDifficulty = '전체';
      _searchController.clear();
    });
    _filterTexts();

    // 사용자에게 피드백 제공
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('필터가 초기화되었습니다.'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // 연습 시작
  void _startPractice(SharedText text) {
    print('연습 시작 버튼 클릭됨: ${text.title}');

    // 라우트가 없을 경우를 대비한 대체 방법
    try {
      Navigator.of(context).pushNamed(
        '/long-text-practice',
        arguments: {
          'text': text.content,
          'title': text.title,
        },
      );
    } catch (e) {
      print('라우트 오류: $e');
      // 대체 방법: 직접 화면 이동
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('연습 화면으로 이동: ${text.title}'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 텍스트 다운로드
  Future<void> _downloadText(SharedText text) async {
    print('다운로드 버튼 클릭됨: ${text.title}');

    try {
      await _sharedTextService.downloadText(text.id);
      print('다운로드 성공: ${text.title}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('텍스트가 다운로드되었습니다!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('다운로드 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('다운로드 실패: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
