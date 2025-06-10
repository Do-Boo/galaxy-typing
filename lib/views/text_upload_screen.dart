// 텍스트 업로드 화면
// 작성: 2025-06-10
// 사용자가 자신의 텍스트를 업로드하여 다른 사용자들과 공유할 수 있는 화면

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

class TextUploadScreen extends StatefulWidget {
  const TextUploadScreen({super.key});

  @override
  _TextUploadScreenState createState() => _TextUploadScreenState();
}

class _TextUploadScreenState extends State<TextUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sharedTextService = SharedTextService();

  // 폼 컨트롤러들
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  // 선택된 값들
  String _selectedCategory = TextCategories.all.first;
  String _selectedDifficulty = TextDifficulties.all.first;
  String _selectedLanguage = TextLanguages.all.first;

  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _uploadText() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      // 태그 파싱
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // SharedText 객체 생성
      final sharedText = SharedText(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorName: _authorController.text.trim(),
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        language: _selectedLanguage,
        description: _descriptionController.text.trim(),
        tags: tags,
        createdAt: DateTime.now(),
      );

      // 업로드
      await _sharedTextService.uploadText(sharedText);

      if (mounted) {
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('텍스트가 성공적으로 업로드되었습니다!'),
            backgroundColor: AppColors.success,
          ),
        );

        // 이전 화면으로 돌아가기 (업로드 성공 표시)
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('업로드 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
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
                            title: 'TEXT UPLOAD',
                            subtitle: '새로운 텍스트를 공유해보세요',
                            centerAlign: true,
                            titleFontSize:
                                isDesktop ? 32 : (isTablet ? 28 : 24),
                          ),
                        ),
                        const SizedBox(width: 48), // 뒤로가기 버튼과 균형 맞추기
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 폼 영역
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 안내 메시지
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '저작권이 있는 텍스트는 업로드하지 마세요. 모든 사용자가 자유롭게 연습할 수 있는 텍스트만 공유해주세요.',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: isDesktop ? 14 : 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 제목
                            _buildTextField(
                              controller: _titleController,
                              label: '제목',
                              hint: '텍스트의 제목을 입력하세요',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '제목을 입력해주세요';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // 작성자
                            _buildTextField(
                              controller: _authorController,
                              label: '작성자',
                              hint: '작성자 이름을 입력하세요',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '작성자를 입력해주세요';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // 카테고리, 난이도, 언어 (반응형 레이아웃)
                            isDesktop
                                ? Row(
                                    children: [
                                      Expanded(
                                          child: _buildDropdown(
                                              '카테고리',
                                              _selectedCategory,
                                              TextCategories.all,
                                              (value) => setState(() =>
                                                  _selectedCategory = value!))),
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: _buildDropdown(
                                              '난이도',
                                              _selectedDifficulty,
                                              TextDifficulties.all,
                                              (value) => setState(() =>
                                                  _selectedDifficulty =
                                                      value!))),
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: _buildDropdown(
                                              '언어',
                                              _selectedLanguage,
                                              TextLanguages.all,
                                              (value) => setState(() =>
                                                  _selectedLanguage = value!))),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildDropdown(
                                          '카테고리',
                                          _selectedCategory,
                                          TextCategories.all,
                                          (value) => setState(() =>
                                              _selectedCategory = value!)),
                                      const SizedBox(height: 16),
                                      _buildDropdown(
                                          '난이도',
                                          _selectedDifficulty,
                                          TextDifficulties.all,
                                          (value) => setState(() =>
                                              _selectedDifficulty = value!)),
                                      const SizedBox(height: 16),
                                      _buildDropdown(
                                          '언어',
                                          _selectedLanguage,
                                          TextLanguages.all,
                                          (value) => setState(() =>
                                              _selectedLanguage = value!)),
                                    ],
                                  ),

                            const SizedBox(height: 16),

                            // 내용
                            _buildTextField(
                              controller: _contentController,
                              label: '내용',
                              hint: '타이핑 연습에 사용할 텍스트를 입력하세요 (최소 50자)',
                              maxLines: 8,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '내용을 입력해주세요';
                                }
                                if (value.trim().length < 50) {
                                  return '최소 50자 이상 입력해주세요';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // 설명 (선택사항)
                            _buildTextField(
                              controller: _descriptionController,
                              label: '설명 (선택사항)',
                              hint: '텍스트에 대한 간단한 설명을 입력하세요',
                              maxLines: 3,
                            ),

                            const SizedBox(height: 16),

                            // 태그 (선택사항)
                            _buildTextField(
                              controller: _tagsController,
                              label: '태그 (선택사항)',
                              hint: '쉼표로 구분하여 태그를 입력하세요 (예: 소설, 감동, 한국문학)',
                            ),

                            const SizedBox(height: 32),

                            // 업로드 버튼
                            CosmicButton(
                              label: _isUploading ? '업로드 중...' : '업로드',
                              icon: _isUploading ? null : Icons.upload,
                              type: CosmicButtonType.primary,
                              size: CosmicButtonSize.large,
                              onPressed: _isUploading ? null : _uploadText,
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }

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
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item,
                        style: const TextStyle(color: AppColors.textPrimary)),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          dropdownColor: AppColors.backgroundLighter,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
