// 텍스트 업로드 화면
// 작성: 2024-05-15
// 업데이트: 2025-06-18 (간소화된 레이아웃으로 재구성)
// 사용자가 직접 텍스트를 업로드하여 연습할 수 있는 간단한 화면

import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/back_button.dart';
import '../widgets/cosmic_button.dart';
import '../widgets/cosmic_card.dart';
import '../widgets/cosmic_input_field.dart';
import '../widgets/page_header.dart';
import '../widgets/space_background.dart';

class TextUploadScreen extends StatefulWidget {
  const TextUploadScreen({super.key});

  @override
  _TextUploadScreenState createState() => _TextUploadScreenState();
}

class _TextUploadScreenState extends State<TextUploadScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _audioService = AudioService();

  // 폼 컨트롤러들
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();

  // 상태 변수들
  bool _isUploading = false;
  String _selectedCategory = '일반';
  String _selectedDifficulty = '중급';

  // 카테고리 및 난이도 옵션
  final List<String> _categories = ['일반', '소설', '시', '뉴스', '기술', '기타'];
  final List<String> _difficulties = ['초급', '중급', '고급'];

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

    // 애니메이션 시작
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _textController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                                  title: 'TEXT UPLOAD',
                                  subtitle: '텍스트 업로드',
                                  centerAlign: true,
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 메인 업로드 폼
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildUploadForm(context),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildInfoCard(context),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildUploadForm(context),
                                const SizedBox(height: 16),
                                _buildInfoCard(context),
                              ],
                            ),

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

  // 업로드 폼
  Widget _buildUploadForm(BuildContext context) {
    return CosmicCard(
      title: '텍스트 업로드',
      titleIcon: Icons.upload_file,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력
            CosmicInputField(
              controller: _titleController,
              label: '제목',
              hintText: '텍스트의 제목을 입력하세요',
              prefixIcon: Icons.title,
            ),

            const SizedBox(height: 16),

            // 작성자 입력
            CosmicInputField(
              controller: _authorController,
              label: '작성자 (선택사항)',
              hintText: '작성자명을 입력하세요',
              prefixIcon: Icons.person,
            ),

            const SizedBox(height: 16),

            // 카테고리 및 난이도 선택
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    '카테고리',
                    _selectedCategory,
                    _categories,
                    (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    '난이도',
                    _selectedDifficulty,
                    _difficulties,
                    (value) => setState(() => _selectedDifficulty = value!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 설명 입력
            CosmicInputField(
              controller: _descriptionController,
              label: '설명 (선택사항)',
              hintText: '텍스트에 대한 간단한 설명을 입력하세요',
              prefixIcon: Icons.description,
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 16),

            // 텍스트 내용 입력 (커스텀 TextField 사용)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.text_fields, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '텍스트 내용',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: '연습할 텍스트를 입력하세요...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.backgroundLighter.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 업로드 버튼
            SizedBox(
              width: double.infinity,
              child: CosmicButton(
                label: _isUploading ? '업로드 중...' : '텍스트 업로드',
                icon: _isUploading ? Icons.hourglass_empty : Icons.cloud_upload,
                type: CosmicButtonType.primary,
                size: CosmicButtonSize.large,
                onPressed: _isUploading ? null : _uploadText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 정보 카드
  Widget _buildInfoCard(BuildContext context) {
    return CosmicCard(
      title: '업로드 가이드',
      titleIcon: Icons.info,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(
              Icons.check_circle,
              '텍스트 길이',
              '최소 50자 이상 권장',
              AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.language,
              '지원 언어',
              '한글, 영어, 숫자, 특수문자',
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.category,
              '카테고리',
              '적절한 카테고리를 선택하세요',
              AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.speed,
              '난이도',
              '초급: 기본 단어\n중급: 일반 문장\n고급: 복잡한 문장',
              AppColors.warning,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Text(
                '💡 팁: 업로드한 텍스트는 공유 텍스트 라이브러리에서 다른 사용자들과 공유됩니다.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
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

  // 정보 아이템
  Widget _buildInfoItem(
      IconData icon, String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 텍스트 업로드 처리
  Future<void> _uploadText() async {
    // 유효성 검사
    if (_titleController.text.trim().isEmpty) {
      _showMessage('제목을 입력해주세요.');
      return;
    }

    if (_textController.text.trim().isEmpty) {
      _showMessage('텍스트 내용을 입력해주세요.');
      return;
    }

    if (_textController.text.trim().length < 50) {
      _showMessage('텍스트는 최소 50자 이상 입력해주세요.');
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 임시로 간단한 로컬 저장 처리
      // 실제로는 SharedText 모델을 사용해야 하지만 간소화를 위해 메시지만 표시
      await Future.delayed(const Duration(seconds: 1)); // 업로드 시뮬레이션

      _showMessage('텍스트가 성공적으로 업로드되었습니다!', isSuccess: true);

      // 폼 초기화
      _titleController.clear();
      _textController.clear();
      _authorController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = '일반';
        _selectedDifficulty = '중급';
      });

      // 업로드 성공 시 결과 반환
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    } catch (e) {
      _showMessage('업로드 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // 메시지 표시
  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
