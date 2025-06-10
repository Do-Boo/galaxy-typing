// 텍스트 업로드 화면
// 작성: 2025-06-10
// 사용자가 새로운 텍스트를 업로드하여 공유할 수 있는 화면

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
  final _sharedTextService = SharedTextService();
  final _formKey = GlobalKey<FormState>();

  // 폼 컨트롤러들
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  // 선택된 값들
  String _selectedCategory = TextCategories.essay;
  String _selectedDifficulty = TextDifficulties.intermediate;
  String _selectedLanguage = TextLanguages.korean;

  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
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

      final sharedText = SharedText(
        id: '', // 서비스에서 생성
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        language: _selectedLanguage,
        authorName: _authorController.text.trim(),
        createdAt: DateTime.now(),
        description: _descriptionController.text.trim(),
        tags: tags,
      );

      final success = await _sharedTextService.uploadText(sharedText);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('텍스트가 성공적으로 업로드되었습니다!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true); // 성공 결과 반환
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('업로드에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
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
                            titleFontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  // 폼 영역
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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

                              // 카테고리, 난이도, 언어 선택
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdown(
                                      label: '카테고리',
                                      value: _selectedCategory,
                                      items: TextCategories.all,
                                      onChanged: (value) {
                                        setState(() => _selectedCategory = value!);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDropdown(
                                      label: '난이도',
                                      value: _selectedDifficulty,
                                      items: TextDifficulties.all,
                                      onChanged: (value) {
                                        setState(() => _selectedDifficulty = value!);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDropdown(
                                      label: '언어',
                                      value: _selectedLanguage,
                                      items: TextLanguages.all,
                                      onChanged: (value) {
                                        setState(() => _selectedLanguage = value!);
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // 설명
                              _buildTextField(
                                controller: _descriptionController,
                                label: '설명 (선택사항)',
                                hint: '텍스트에 대한 간단한 설명을 입력하세요',
                                maxLines: 2,
                              ),

                              const SizedBox(height: 16),

                              // 태그
                              _buildTextField(
                                controller: _tagsController,
                                label: '태그 (선택사항)',
                                hint: '태그를 쉼표로 구분하여 입력하세요 (예: 감성, 일상, 힐링)',
                              ),

                              const SizedBox(height: 16),

                              // 내용
                              _buildTextField(
                                controller: _contentController,
                                label: '내용',
                                hint: '타이핑 연습에 사용할 텍스트를 입력하세요',
                                maxLines: 10,
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

                              const SizedBox(height: 24),

                              // 업로드 버튼
                              CosmicButton(
                                label: _isUploading ? '업로드 중...' : '텍스트 업로드',
                                icon: _isUploading ? null : Icons.upload,
                                type: CosmicButtonType.primary,
                                size: CosmicButtonSize.large,
                                onPressed: _isUploading ? null : _uploadText,
                              ),

                              const SizedBox(height: 16),

                              // 안내 텍스트
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: const Text(
                                  '업로드된 텍스트는 다른 사용자들과 공유되며, 타이핑 연습에 사용됩니다. '
                                  '저작권이 있는 내용이나 부적절한 내용은 업로드하지 마세요.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
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
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            );
          }).toList(),
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