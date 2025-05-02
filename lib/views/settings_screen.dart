// 설정 화면
// 작성: 2024-05-15
// 앱의 설정을 관리하는 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../models/game_settings.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/back_button.dart';
import '../widgets/cosmic_button.dart';
import '../widgets/cosmic_card.dart';
import '../widgets/page_header.dart';
import '../widgets/space_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _audioService = AudioService();

  @override
  void initState() {
    super.initState();

    // 음악 중지 (space_defense_screen 전용)
    _audioService.stop();
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.screenPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 배경
          SpaceBackground(
            particleDensity: isDesktop ? 150 : (isTablet ? 100 : 70),
          ),

          // 메인 콘텐츠
          SafeArea(
            child: ResponsiveHelper.centeredContent(
              context: context,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 헤더 및 뒤로가기 버튼
                      Row(
                        children: [
                          CosmicBackButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          Expanded(
                            child: PageHeader(
                              title: '설정',
                              titleFontSize: isDesktop ? 32 : 24,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 모바일 스타일로 통일 - 항상 세로로 배치
                      Column(
                        children: [
                          _buildGameSettingsCard(context, settingsController),
                          const SizedBox(height: 24),
                          _buildAppSettingsCard(context, settingsController),
                          const SizedBox(height: 24),
                          _buildAccessibilitySettingsCard(
                              context, settingsController),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 하단 버튼
                      CosmicButton(
                        label: '저장',
                        type: CosmicButtonType.primary,
                        size: isDesktop
                            ? CosmicButtonSize.large
                            : CosmicButtonSize.medium,
                        icon: Icons.save,
                        isFullWidth: !isDesktop,
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          await settingsController.saveSettings();
                          navigator.pop();
                        },
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

  // 게임 설정 카드
  Widget _buildGameSettingsCard(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return CosmicCard(
      title: '게임 설정',
      titleIcon: Icons.sports_esports,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 난이도 설정
          _buildSettingSection(
            context: context,
            title: '난이도',
            icon: Icons.stacked_line_chart,
            child: _buildDifficultySelector(context, settingsController),
          ),

          const Divider(color: AppColors.borderColor),

          // 타이머 설정
          _buildSettingSection(
            context: context,
            title: '타이머 (초)',
            icon: Icons.timer,
            child: _buildTimerSlider(context, settingsController),
          ),
        ],
      ),
    );
  }

  // 앱 설정 카드
  Widget _buildAppSettingsCard(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return CosmicCard(
      title: '앱 설정',
      titleIcon: Icons.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 테마 설정
          _buildSettingSection(
            context: context,
            title: '테마',
            icon: Icons.dark_mode,
            child: _buildThemeSelector(context, settingsController),
          ),

          const Divider(color: AppColors.borderColor),

          // 효과음 설정
          _buildSettingSwitch(
            context,
            title: '효과음',
            icon: Icons.volume_up,
            value: settingsController.soundEnabled,
            onChanged: (value) {
              settingsController.soundEnabled = value;
            },
          ),

          const Divider(color: AppColors.borderColor),

          // 음악 설정
          _buildSettingSwitch(
            context,
            title: '배경 음악',
            icon: Icons.music_note,
            value: settingsController.musicEnabled,
            onChanged: (value) {
              settingsController.musicEnabled = value;
            },
          ),
        ],
      ),
    );
  }

  // 접근성 설정 카드
  Widget _buildAccessibilitySettingsCard(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return CosmicCard(
      title: '접근성',
      titleIcon: Icons.accessibility_new,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 하이 콘트라스트 모드
          _buildSettingSwitch(
            context,
            title: '고대비 모드',
            icon: Icons.contrast,
            value: settingsController.highContrastMode,
            onChanged: (value) {
              settingsController.highContrastMode = value;
            },
          ),

          const Divider(color: AppColors.borderColor),

          // 언어 설정
          _buildSettingSection(
            context: context,
            title: '언어 설정',
            icon: Icons.language,
            child: _buildLanguageSelector(context, settingsController),
          ),

          const Divider(color: AppColors.borderColor),

          // 글꼴 크기 설정
          _buildSettingSection(
            context: context,
            title: '글꼴 크기',
            icon: Icons.format_size,
            child: _buildFontSizeSlider(context, settingsController),
          ),
        ],
      ),
    );
  }

  // 설정 섹션 기본 위젯
  Widget _buildSettingSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyLarge(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // 스위치 설정 항목
  Widget _buildSettingSwitch(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge(context),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // 난이도 선택 위젯
  Widget _buildDifficultySelector(
    BuildContext context,
    SettingsController settingsController,
  ) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return SegmentedButton<DifficultyLevel>(
      segments: const [
        ButtonSegment<DifficultyLevel>(
          value: DifficultyLevel.easy,
          label: Text('쉬움'),
          icon: Icon(Icons.sentiment_satisfied),
        ),
        ButtonSegment<DifficultyLevel>(
          value: DifficultyLevel.medium,
          label: Text('보통'),
          icon: Icon(Icons.sentiment_neutral),
        ),
        ButtonSegment<DifficultyLevel>(
          value: DifficultyLevel.hard,
          label: Text('어려움'),
          icon: Icon(Icons.sentiment_dissatisfied),
        ),
      ],
      selected: {settingsController.difficulty},
      onSelectionChanged: (newSelection) {
        if (newSelection.isNotEmpty) {
          settingsController.difficulty = newSelection.first;
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.backgroundLighter;
          },
        ),
      ),
    );
  }

  // 타이머 슬라이더 위젯
  Widget _buildTimerSlider(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return Column(
      children: [
        Slider(
          value: settingsController.timerDuration.toDouble(),
          min: 15,
          max: 120,
          divisions: 7,
          label: '${settingsController.timerDuration}초',
          onChanged: (value) {
            settingsController.timerDuration = value.toInt();
          },
          activeColor: AppColors.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '15초',
              style: AppTextStyles.bodySmall(context),
            ),
            Text(
              '${settingsController.timerDuration}초',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '120초',
              style: AppTextStyles.bodySmall(context),
            ),
          ],
        ),
      ],
    );
  }

  // 테마 선택 위젯
  Widget _buildThemeSelector(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildThemeOption(
            context,
            title: '라이트',
            icon: Icons.light_mode,
            isSelected: !settingsController.darkThemeEnabled,
            onTap: () {
              settingsController.darkThemeEnabled = false;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildThemeOption(
            context,
            title: '다크',
            icon: Icons.dark_mode,
            isSelected: settingsController.darkThemeEnabled,
            onTap: () {
              settingsController.darkThemeEnabled = true;
            },
          ),
        ),
      ],
    );
  }

  // 테마 옵션 위젯
  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.backgroundLighter,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 글꼴 크기 슬라이더 위젯
  Widget _buildFontSizeSlider(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return Column(
      children: [
        Slider(
          value: settingsController.fontSize,
          min: 0.8,
          max: 1.4,
          divisions: 6,
          label:
              '${((settingsController.fontSize - 0.8) * 100 / 0.6).round()}%',
          onChanged: (value) {
            settingsController.fontSize = value;
          },
          activeColor: AppColors.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '작게',
              style: AppTextStyles.bodySmall(context),
            ),
            Text(
              '${((settingsController.fontSize - 0.8) * 100 / 0.6).round()}%',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '크게',
              style: AppTextStyles.bodySmall(context),
            ),
          ],
        ),
      ],
    );
  }

  // 언어 선택 위젯
  Widget _buildLanguageSelector(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return SegmentedButton<LanguageOption>(
      segments: const [
        ButtonSegment<LanguageOption>(
          value: LanguageOption.korean,
          label: Text('한국어'),
          icon: Icon(Icons.language),
        ),
        ButtonSegment<LanguageOption>(
          value: LanguageOption.english,
          label: Text('English'),
          icon: Icon(Icons.language),
        ),
      ],
      selected: {settingsController.language},
      onSelectionChanged: (newSelection) {
        if (newSelection.isNotEmpty) {
          settingsController.language = newSelection.first;
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.backgroundLighter;
          },
        ),
      ),
    );
  }
}
