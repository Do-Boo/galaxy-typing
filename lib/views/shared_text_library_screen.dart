// 공유 텍스트 라이브러리 화면
// 작성: 2025-06-10
// 사용자들이 공유한 텍스트를 탐색하고 다운로드할 수 있는 화면

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/shared_text.dart';
import '../services/shared_text_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/back_button.dart';
import '../widgets/cosmic_button.dart';
import '../widgets/page_header.dart';
import '../widgets/space_background.dart';
import 'long_text_practice_screen.dart';
import 'text_upload_screen.dart';

class SharedTextLibraryScreen extends StatefulWidget {
  const SharedTextLibraryScreen({super.key});

  @override
  _SharedTextLibraryScreenState createState() =>
      _SharedTextLibraryScreenState();
}

class _SharedTextLibraryScreenState extends State<SharedTextLibraryScreen> {
  final _sharedTextService = SharedTextService();
  final _searchController = TextEditingController();

  List<SharedText> _allTexts = [];
  List<SharedText> _filteredTexts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTexts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTexts() async {
    setState(() => _isLoading = true);

    try {
      final texts = await _sharedTextService.getAllSharedTexts();
      setState(() {
        _allTexts = texts;
        _filteredTexts = texts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTexts = _allTexts.where((text) {
        // 검색어 필터
        final searchQuery = _searchController.text.toLowerCase();
        if (searchQuery.isNotEmpty) {
          if (!text.title.toLowerCase().contains(searchQuery) &&
              !text.content.toLowerCase().contains(searchQuery) &&
              !text.tags
                  .any((tag) => tag.toLowerCase().contains(searchQuery))) {
            return false;
          }
        }

        return true;
      }).toList();

      // 최신순으로 정렬
      _filteredTexts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> _downloadAndPractice(SharedText text) async {
    // 다운로드 수 증가
    await _sharedTextService.downloadText(text.id);

    // 긴글 연습 화면으로 이동
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LongTextPracticeScreen(
            customText: text.content,
            customTitle: text.title,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: !kIsWeb,
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: ResponsiveHelper.centeredContent(
              context: context,
              child: Column(
                children: [
                  // 헤더
                  Padding(
                    padding: ResponsiveHelper.screenPadding(context),
                    child: Row(
                      children: [
                        CosmicBackButton(
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: PageHeader(
                            title: 'TEXT LIBRARY',
                            subtitle: '사용자들이 공유한 텍스트 모음',
                            centerAlign: true,
                            titleFontSize:
                                isDesktop ? 32 : (isTablet ? 28 : 24),
                          ),
                        ),
                        // 업로드 버튼
                        CosmicButton(
                          label:
                              ResponsiveHelper.isMobile(context) ? '' : '업로드',
                          icon: Icons.upload,
                          type: CosmicButtonType.primary,
                          size: ResponsiveHelper.isMobile(context)
                              ? CosmicButtonSize.small
                              : CosmicButtonSize.medium,
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const TextUploadScreen(),
                              ),
                            );
                            if (result == true) {
                              _loadTexts(); // 새로 업로드된 텍스트 반영
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 검색 바
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '제목, 내용, 태그로 검색...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: AppColors.textSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  _applyFilters();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.07),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 2),
                        ),
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      onChanged: (_) => _applyFilters(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 텍스트 목록
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          )
                        : _filteredTexts.isEmpty
                            ? _buildEmptyState()
                            : _buildTextList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextList() {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final crossAxisCount = isDesktop ? 2 : 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: isDesktop ? 2.5 : 1.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredTexts.length,
        itemBuilder: (context, index) {
          final text = _filteredTexts[index];
          return _buildTextCard(text);
        },
      ),
    );
  }

  Widget _buildTextCard(SharedText text) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    text.category,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 내용 미리보기
            Text(
              text.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // 메타 정보
            Row(
              children: [
                _buildMetaChip(Icons.person, text.authorName),
                const SizedBox(width: 8),
                _buildMetaChip(Icons.download, '${text.downloadCount}'),
                const SizedBox(width: 8),
                _buildMetaChip(Icons.timer, '${text.estimatedMinutes}분'),
              ],
            ),

            const SizedBox(height: 12),

            // 액션 버튼
            Row(
              children: [
                Expanded(
                  child: CosmicButton(
                    label: '연습하기',
                    icon: Icons.play_arrow,
                    type: CosmicButtonType.primary,
                    size: CosmicButtonSize.small,
                    onPressed: () => _downloadAndPractice(text),
                  ),
                ),
                const SizedBox(width: 8),
                CosmicButton(
                  label: '',
                  icon: Icons.info_outline,
                  type: CosmicButtonType.outline,
                  size: CosmicButtonSize.small,
                  onPressed: () => _showTextDetails(text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 검색어를 시도해보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showTextDetails(SharedText text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLighter,
        title: Text(text.title,
            style: const TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (text.description.isNotEmpty) ...[
                Text(text.description,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
              ],
              _buildDetailRow('작성자', text.authorName),
              _buildDetailRow('카테고리', text.category),
              _buildDetailRow('난이도', text.difficulty),
              _buildDetailRow('언어', text.language),
              _buildDetailRow('길이', '${text.textLength}자'),
              _buildDetailRow('문장 수', '${text.sentenceCount}개'),
              _buildDetailRow('예상 시간', '${text.estimatedMinutes}분'),
              _buildDetailRow('다운로드', '${text.downloadCount}회'),
              if (text.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('태그:',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: text.tags
                      .map((tag) => Chip(
                            label:
                                Text(tag, style: const TextStyle(fontSize: 10)),
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadAndPractice(text);
            },
            child:
                const Text('연습하기', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
