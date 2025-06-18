// 설정 화면
// 작성: 2024-05-15
// 업데이트: 2024-06-10 (다국어 지원 적용)
// 업데이트: 2025-06-18 (다크/라이트 모드 제거, 단일 우주 테마 적용)
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
    _audioService.stop();
  }

  @override
  Widget build(BuildContext context) {
    final settingsController =
        Provider.of<SettingsController>(context, listen: true);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenPadding = ResponsiveHelper.screenPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SpaceBackground(
            particleDensity: isDesktop ? 150 : (isTablet ? 100 : 70),
          ),
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
                      Row(
                        children: [
                          CosmicBackButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAdPlaceholder(context),
                      const SizedBox(height: 16),
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
                      Row(
                        children: [
                          if (isDesktop || isTablet)
                            Expanded(
                              child: CosmicButton(
                                label: '기본값 복원',
                                type: CosmicButtonType.secondary,
                                size: isDesktop
                                    ? CosmicButtonSize.large
                                    : CosmicButtonSize.medium,
                                icon: Icons.restore,
                                isFullWidth: true,
                                onPressed: () async {
                                  await settingsController.resetToDefaults();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('설정이 초기화되었습니다'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          if (isDesktop || isTablet) const SizedBox(width: 16),
                          Expanded(
                            child: CosmicButton(
                              label: '저장',
                              type: CosmicButtonType.primary,
                              size: isDesktop
                                  ? CosmicButtonSize.large
                                  : CosmicButtonSize.medium,
                              icon: Icons.save,
                              isFullWidth: true,
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                await settingsController.saveSettings();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('설정이 저장되었습니다'),
                                      backgroundColor: AppColors.success,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                                navigator.pop();
                              },
                            ),
                          ),
                        ],
                      ),
                      if (!isDesktop && !isTablet)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: CosmicButton(
                            label: '기본값 복원',
                            type: CosmicButtonType.secondary,
                            size: CosmicButtonSize.medium,
                            icon: Icons.restore,
                            isFullWidth: true,
                            onPressed: () async {
                              await settingsController.resetToDefaults();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('설정이 초기화되었습니다'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
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

  Widget _buildAdPlaceholder(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      height: isDesktop ? 100 : (isTablet ? 80 : 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '광고 영역',
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildGameSettingsCard(
      BuildContext context, SettingsController settingsController) {
    return CosmicCard(
      title: '게임 설정',
      titleIcon: Icons.games,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingSection(
            context: context,
            title: '난이도',
            icon: Icons.tune,
            child: _buildDifficultySelector(context, settingsController),
          ),
          const Divider(color: AppColors.borderColor),
          _buildSettingSection(
            context: context,
            title: '타이머 시간',
            icon: Icons.timer,
            child: _buildTimerSlider(context, settingsController),
          ),
          const Divider(color: AppColors.borderColor),
          _buildSettingSection(
            context: context,
            title: '타자연습 언어',
            icon: Icons.keyboard,
            child: _buildTypingLanguageSelector(context, settingsController),
          ),
          const Divider(color: AppColors.borderColor),
          _buildSettingSwitch(
            context,
            title: '파티클 효과',
            icon: Icons.auto_awesome,
            value: settingsController.particleEffectsEnabled,
            onChanged: (value) {
              settingsController.setParticleEffectsEnabled(value);
            },
          ),
          _buildSettingSwitch(
            context,
            title: '타이핑 효과',
            icon: Icons.keyboard_alt,
            value: settingsController.typingEffectsEnabled,
            onChanged: (value) {
              settingsController.setTypingEffectsEnabled(value);
            },
          ),
          _buildSettingSwitch(
            context,
            title: '타이핑 사운드',
            icon: Icons.keyboard_voice,
            value: settingsController.typingSoundEnabled,
            onChanged: (value) {
              settingsController.setTypingSoundEnabled(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard(
      BuildContext context, SettingsController settingsController) {
    return CosmicCard(
      title: '앱 설정',
      titleIcon: Icons.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingSwitch(
            context,
            title: '효과음',
            icon: Icons.volume_up,
            value: settingsController.soundEnabled,
            onChanged: (value) {
              settingsController.soundEnabled = value;
            },
          ),
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
          _buildSettingSwitch(
            context,
            title: '배경음악',
            icon: Icons.music_note,
            value: settingsController.musicEnabled,
            onChanged: (value) {
              settingsController.musicEnabled = value;
            },
          ),
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

  Widget _buildAccessibilitySettingsCard(
      BuildContext context, SettingsController settingsController) {
    return CosmicCard(
      title: '접근성',
      titleIcon: Icons.accessibility_new,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _buildSettingSection(
            context: context,
            title: '언어',
            icon: Icons.language,
            child: _buildLanguageSelector(context, settingsController),
          ),
          const Divider(color: AppColors.borderColor),
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
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.bodyLarge(context)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

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
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title, style: AppTextStyles.bodyLarge(context)),
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

  Widget _buildDifficultySelector(
      BuildContext context, SettingsController settingsController) {
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

  Widget _buildTimerSlider(
      BuildContext context, SettingsController settingsController) {
    return Column(
      children: [
        Slider(
          value: settingsController.timerDuration.toDouble(),
          min: 15,
          max: 120,
          divisions: 7,
          label: '${settingsController.timerDuration}초',
          onChanged: (value) {
            settingsController.timerDuration = value.round();
          },
          activeColor: AppColors.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15초', style: AppTextStyles.bodySmall(context)),
            Text(
              '${settingsController.timerDuration}초',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('120초', style: AppTextStyles.bodySmall(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider(
      BuildContext context, SettingsController settingsController) {
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
            Text('작게', style: AppTextStyles.bodySmall(context)),
            Text(
              '${((settingsController.fontSize - 0.8) * 100 / 0.6).round()}%',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('크게', style: AppTextStyles.bodySmall(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(
      BuildContext context, SettingsController settingsController) {
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

  Widget _buildVolumeSlider(
    BuildContext context, {
    required double value,
    required ValueChanged<double> onChanged,
    required String label,
  }) {
    return Row(
      children: [
        const Icon(Icons.volume_down, size: 18, color: AppColors.textSecondary),
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
        const Icon(Icons.volume_up, size: 18, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildTypingLanguageSelector(
      BuildContext context, SettingsController settingsController) {
    return SegmentedButton<LanguageOption>(
      segments: const [
        ButtonSegment<LanguageOption>(
          value: LanguageOption.korean,
          label: Text('한국어 타자'),
          icon: Icon(Icons.language),
        ),
        ButtonSegment<LanguageOption>(
          value: LanguageOption.english,
          label: Text('영어 타자'),
          icon: Icon(Icons.language),
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
}
