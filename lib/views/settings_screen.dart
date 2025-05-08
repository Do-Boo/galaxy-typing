// 설정 화면
// 작성: 2024-05-15
// 업데이트: 2024-06-10 (다국어 지원 적용)
// 앱의 설정을 관리하는 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../models/game_settings.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../utils/localization.dart';
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
  // Provider에서 참조할 컨트롤러를 저장할 필드
  late SettingsController _settingsController;

  @override
  void initState() {
    super.initState();

    // 음악 중지 (space_defense_screen 전용)
    _audioService.stop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // didChangeDependencies에서 컨트롤러 참조 가져오기
    _settingsController =
        Provider.of<SettingsController>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                              title: context.tr('settings'),
                              titleFontSize: isDesktop ? 32 : 24,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 모바일 스타일로 통일 - 항상 세로로 배치
                      Column(
                        children: [
                          _buildGameSettingsCard(context, _settingsController),
                          const SizedBox(height: 24),
                          _buildAppSettingsCard(context, _settingsController),
                          const SizedBox(height: 24),
                          _buildAccessibilitySettingsCard(
                              context, _settingsController),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 하단 버튼들
                      Row(
                        children: [
                          if (isDesktop || isTablet)
                            // 기본값으로 재설정 버튼 (데스크톱 및 태블릿에서는 좌측에 배치)
                            Expanded(
                              child: CosmicButton(
                                label: context.tr('reset_defaults'),
                                type: CosmicButtonType.secondary,
                                size: isDesktop
                                    ? CosmicButtonSize.large
                                    : CosmicButtonSize.medium,
                                icon: Icons.restore,
                                isFullWidth: true,
                                onPressed: () async {
                                  // 재설정 확인 대화상자 표시
                                  final confirmed =
                                      await _showResetConfirmDialog(context);
                                  if (confirmed) {
                                    await _settingsController.resetToDefaults();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(context.tr('reset_success')),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),

                          if (isDesktop || isTablet) const SizedBox(width: 16),

                          // 저장 버튼 (데스크톱 및 태블릿에서는 우측에 배치)
                          Expanded(
                            child: CosmicButton(
                              label: context.tr('save'),
                              type: CosmicButtonType.primary,
                              size: isDesktop
                                  ? CosmicButtonSize.large
                                  : CosmicButtonSize.medium,
                              icon: Icons.save,
                              isFullWidth: true,
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                await _settingsController.saveSettings();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(context.tr('settings_saved')),
                                      backgroundColor: AppColors.success,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                                navigator.pop();
                              },
                            ),
                          ),
                        ],
                      ),

                      // 모바일에서는 재설정 버튼 하단에 추가
                      if (!isDesktop && !isTablet)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: CosmicButton(
                            label: context.tr('reset_defaults'),
                            type: CosmicButtonType.secondary,
                            size: CosmicButtonSize.medium,
                            icon: Icons.restore,
                            isFullWidth: true,
                            onPressed: () async {
                              // 재설정 확인 대화상자 표시
                              final confirmed =
                                  await _showResetConfirmDialog(context);
                              if (confirmed) {
                                await _settingsController.resetToDefaults();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(context.tr('reset_success')),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              }
                            },
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

  // 게임 설정 카드
  Widget _buildGameSettingsCard(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return CosmicCard(
      title: context.tr('game_settings'),
      titleIcon: Icons.sports_esports,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타자연습 언어 설정
          _buildSettingSection(
            context: context,
            title: context.tr('typing_language'),
            icon: Icons.keyboard,
            child: _buildTypingLanguageSelector(context, settingsController),
          ),

          const Divider(color: AppColors.borderColor),

          // 난이도 설정
          _buildSettingSection(
            context: context,
            title: context.tr('difficulty'),
            icon: Icons.stacked_line_chart,
            child: _buildDifficultySelector(context, settingsController),
          ),

          const Divider(color: AppColors.borderColor),

          // 타이머 설정
          _buildSettingSection(
            context: context,
            title: context.tr('timer_seconds'),
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
      title: context.tr('app_settings'),
      titleIcon: Icons.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 테마 설정
          _buildSettingSection(
            context: context,
            title: context.tr('theme'),
            icon: Icons.dark_mode,
            child: _buildThemeSelector(context, settingsController),
          ),

          const Divider(color: AppColors.borderColor),

          // 효과음 설정
          _buildSettingSwitch(
            context,
            title: context.tr('sound_effects'),
            icon: Icons.volume_up,
            value: settingsController.soundEnabled,
            onChanged: (value) {
              settingsController.soundEnabled = value;
            },
          ),

          // 효과음이 활성화된 경우에만 볼륨 슬라이더 표시
          if (settingsController.soundEnabled)
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, right: 16.0, bottom: 8.0),
              child: _buildVolumeSlider(
                context,
                value: settingsController.soundVolume,
                onChanged: (value) {
                  settingsController.soundVolume = value;
                },
                label: '${(settingsController.soundVolume * 100).round()}%',
              ),
            ),

          const Divider(color: AppColors.borderColor),

          // 음악 설정
          _buildSettingSwitch(
            context,
            title: context.tr('background_music'),
            icon: Icons.music_note,
            value: settingsController.musicEnabled,
            onChanged: (value) {
              settingsController.musicEnabled = value;
            },
          ),

          // 음악이 활성화된 경우에만 볼륨 슬라이더 표시
          if (settingsController.musicEnabled)
            Padding(
              padding:
                  const EdgeInsets.only(left: 40.0, right: 16.0, bottom: 8.0),
              child: _buildVolumeSlider(
                context,
                value: settingsController.musicVolume,
                onChanged: (value) {
                  settingsController.setMusicVolume(value);
                },
                label: '${(settingsController.musicVolume * 100).round()}%',
              ),
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
      title: context.tr('accessibility'),
      titleIcon: Icons.accessibility_new,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 하이 콘트라스트 모드
          _buildSettingSwitch(
            context,
            title: context.tr('high_contrast'),
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
            title: context.tr('language'),
            icon: Icons.language,
            child: _buildLanguageSelector(context, settingsController),
          ),

          const Divider(color: AppColors.borderColor),

          // 글꼴 크기 설정
          _buildSettingSection(
            context: context,
            title: context.tr('font_size'),
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
      segments: [
        ButtonSegment<DifficultyLevel>(
          value: DifficultyLevel.easy,
          label: Text(context.tr('easy')),
          icon: const Icon(Icons.sentiment_satisfied),
        ),
        ButtonSegment<DifficultyLevel>(
          value: DifficultyLevel.medium,
          label: Text(context.tr('medium')),
          icon: const Icon(Icons.sentiment_neutral),
        ),
        ButtonSegment<DifficultyLevel>(
          value: DifficultyLevel.hard,
          label: Text(context.tr('hard')),
          icon: const Icon(Icons.sentiment_dissatisfied),
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
            title: context.tr('light'),
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
            title: context.tr('dark'),
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
              context.tr('small'),
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
              context.tr('large'),
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

  // 볼륨 슬라이더 위젯
  Widget _buildVolumeSlider(
    BuildContext context, {
    required double value,
    required ValueChanged<double> onChanged,
    required String label,
  }) {
    return Row(
      children: [
        const Icon(
          Icons.volume_down,
          size: 18,
          color: AppColors.textSecondary,
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: label,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ),
        const Icon(
          Icons.volume_up,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  // 타자연습 언어 선택 위젯
  Widget _buildTypingLanguageSelector(
    BuildContext context,
    SettingsController settingsController,
  ) {
    return SegmentedButton<LanguageOption>(
      segments: [
        ButtonSegment<LanguageOption>(
          value: LanguageOption.korean,
          label: Text(context.tr('korean_typing')),
          icon: const Icon(Icons.language),
        ),
        ButtonSegment<LanguageOption>(
          value: LanguageOption.english,
          label: Text(context.tr('english_typing')),
          icon: const Icon(Icons.language),
        ),
        ButtonSegment<LanguageOption>(
          value: LanguageOption.mixedKoreanEnglish,
          label: Text(context.tr('mixed_typing')),
          icon: const Icon(Icons.language),
        ),
      ],
      selected: {settingsController.typingLanguage},
      onSelectionChanged: (newSelection) {
        if (newSelection.isNotEmpty) {
          settingsController.typingLanguage = newSelection.first;
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

  // 설정 재설정 확인 대화상자
  Future<bool> _showResetConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundLighter,
              title: Text(
                context.tr('reset_confirm_title'),
                style: AppTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                context.tr('reset_confirm_message'),
                style: AppTextStyles.bodyMedium(context),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    context.tr('cancel'),
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    context.tr('reset'),
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
