// 폰트 데모 화면
// 작성: 2024-05-15
// 업데이트: 2024-06-03 (웹/데스크톱에서 모바일 스타일 유지)
// 앱에서 사용되는 폰트 스타일을 보여주는 개발자용 데모 화면

import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/back_button.dart';
import '../widgets/cosmic_card.dart';
import '../widgets/cosmic_pulsing_text.dart';
import '../widgets/page_header.dart';
import '../widgets/space_background.dart';

class FontDemoScreen extends StatefulWidget {
  const FontDemoScreen({super.key});

  @override
  _FontDemoScreenState createState() => _FontDemoScreenState();
}

class _FontDemoScreenState extends State<FontDemoScreen> {
  final _audioService = AudioService();

  @override
  void initState() {
    super.initState();

    // 음악 중지 (space_defense_screen 전용)
    _audioService.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 배경
          const SpaceBackground(),

          // 메인 콘텐츠
          SafeArea(
            child: ResponsiveHelper.centeredContent(
              context: context,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 헤더 및 뒤로가기 버튼
                      Row(
                        children: [
                          CosmicBackButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const Expanded(
                            child: PageHeader(
                              title: '폰트 데모',
                              subtitle: '앱에서 사용되는 폰트 스타일',
                              centerAlign: true,
                            ),
                          ),
                          const SizedBox(width: 48), // 뒤로가기 버튼과 균형 맞추기
                        ],
                      ),

                      const SizedBox(height: 16),

                      // 광고 placeholder 추가
                      _buildAdPlaceholder(context),

                      const SizedBox(height: 16),

                      // PressStart2P 폰트 섹션
                      _buildSection(
                        context,
                        title: 'PressStart2P 폰트',
                        description: '8비트 레트로 게임 스타일 폰트, 로고 및 강조 텍스트에 사용',
                      ),

                      // 기본 PressStart2P 텍스트
                      _buildFontExample(
                        context,
                        label: '기본 PressStart2P',
                        child: const Text(
                          'COSMIC TYPER',
                          style: TextStyle(
                            fontFamily: 'PressStart2P',
                            fontSize: 18,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      // CosmicPulsingText 위젯 예시
                      _buildFontExample(
                        context,
                        label: 'CosmicPulsingText (펄싱 효과)',
                        child: const CosmicPulsingText(
                          text: 'COSMIC TYPER',
                          fontSize: 18,
                          enablePulsing: true,
                        ),
                      ),

                      // 다양한 색상의 CosmicPulsingText
                      _buildFontExample(
                        context,
                        label: 'CosmicPulsingText (커스텀 색상)',
                        child: const CosmicPulsingText(
                          text: 'COSMIC TYPER',
                          fontSize: 18,
                          baseColor: AppColors.accent,
                          glowColor: AppColors.accent,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Rajdhani 폰트 섹션
                      _buildSection(
                        context,
                        title: 'Rajdhani 폰트',
                        description: '기본 텍스트 폰트, 보통 텍스트에 사용',
                      ),

                      // 다양한 Rajdhani 폰트 크기
                      _buildFontExample(
                        context,
                        label: 'titleLarge',
                        child: Text(
                          '타이틀 텍스트 큼',
                          style: AppTextStyles.titleLarge(context),
                        ),
                      ),

                      _buildFontExample(
                        context,
                        label: 'titleMedium',
                        child: Text(
                          '타이틀 텍스트 중간',
                          style: AppTextStyles.titleMedium(context),
                        ),
                      ),

                      _buildFontExample(
                        context,
                        label: 'bodyLarge',
                        child: Text(
                          '본문 텍스트 큼',
                          style: AppTextStyles.bodyLarge(context),
                        ),
                      ),

                      _buildFontExample(
                        context,
                        label: 'bodyMedium',
                        child: Text(
                          '본문 텍스트 중간',
                          style: AppTextStyles.bodyMedium(context),
                        ),
                      ),

                      _buildFontExample(
                        context,
                        label: 'bodySmall',
                        child: Text(
                          '본문 텍스트 작음',
                          style: AppTextStyles.bodySmall(context),
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
    );
  }

  // 폰트 섹션 헤더
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium(context).copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.bodyMedium(context),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderColor),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 폰트 예시 카드
  Widget _buildFontExample(
    BuildContext context, {
    required String label,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CosmicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall(context),
            ),
            const SizedBox(height: 8),
            Center(child: child),
          ],
        ),
      ),
    );
  }

  // 광고 placeholder 추가
  Widget _buildAdPlaceholder(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
