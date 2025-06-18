// 통계 화면
// 작성: 2024-05-15
// 업데이트: 2025-06-18 (간소화된 레이아웃으로 재구성)
// 사용자의 타이핑 통계를 표시하는 간단한 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/stats_controller.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/back_button.dart';
import '../widgets/cosmic_card.dart';
import '../widgets/page_header.dart';
import '../widgets/space_background.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _audioService = AudioService();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsController = Provider.of<StatsController>(context);
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
                                  title: 'TYPING STATISTICS',
                                  subtitle: '타이핑 통계',
                                  centerAlign: true,
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 메인 통계 카드들
                          if (isDesktop)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMainStatsCard(
                                      context, statsController),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildGameModeStats(
                                      context, statsController),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildMainStatsCard(context, statsController),
                                const SizedBox(height: 16),
                                _buildGameModeStats(context, statsController),
                              ],
                            ),

                          const SizedBox(height: 20),

                          // 추가 통계
                          _buildDetailedStats(context, statsController),

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

  // 메인 통계 카드
  Widget _buildMainStatsCard(
      BuildContext context, StatsController statsController) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return CosmicCard(
      title: '전체 통계',
      titleIcon: Icons.analytics,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    '평균 타수',
                    '${statsController.averageCpm}',
                    'CPM',
                    Icons.speed,
                    AppColors.primary,
                  ),
                ),
                if (isDesktop) const SizedBox(width: 20),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '정확도',
                    '${statsController.accuracy}',
                    '%',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    '총 세션',
                    '${statsController.totalSessionCount}',
                    '회',
                    Icons.history,
                    AppColors.secondary,
                  ),
                ),
                if (isDesktop) const SizedBox(width: 20),
                Expanded(
                  child: _buildStatItem(
                    context,
                    '최고 웨이브',
                    '${statsController.highestWave}',
                    'Wave',
                    Icons.waves,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 게임 모드별 통계
  Widget _buildGameModeStats(
      BuildContext context, StatsController statsController) {
    return CosmicCard(
      title: '모드별 통계',
      titleIcon: Icons.dashboard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildModeStatRow(
              context,
              '기본 연습',
              '${statsController.basicPracticeAvgCpm} CPM',
              Icons.keyboard,
              AppColors.success,
            ),
            const SizedBox(height: 12),
            _buildModeStatRow(
              context,
              '시간 도전',
              '${statsController.timeChallengeAvgCpm} CPM',
              Icons.timer,
              AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _buildModeStatRow(
              context,
              '우주 디펜스',
              '${statsController.defenseModeAvgCpm} CPM',
              Icons.rocket_launch,
              AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  // 상세 통계
  Widget _buildDetailedStats(
      BuildContext context, StatsController statsController) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return CosmicCard(
      title: '상세 통계',
      titleIcon: Icons.insights,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildDetailRow(
                            '총 타자 수', '${statsController.totalCharTyped}자'),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                            '총 플레이 시간', '${statsController.totalTimeSpent}분'),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                            '최고 웨이브', '${statsController.highestWave} Wave'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _buildDetailRow(
                            '완료한 단어', '${statsController.totalWordsTyped}개'),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                            '최고 점수', '${statsController.highestScore}점'),
                        const SizedBox(height: 8),
                        _buildDetailRow('일평균 세션',
                            '${statsController.dailyAvgSessions.toStringAsFixed(1)}회'),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildDetailRow(
                      '총 타자 수', '${statsController.totalCharTyped}자'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      '총 플레이 시간', '${statsController.totalTimeSpent}분'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      '완료한 단어', '${statsController.totalWordsTyped}개'),
                  const SizedBox(height: 8),
                  _buildDetailRow('최고 점수', '${statsController.highestScore}점'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      '최고 웨이브', '${statsController.highestWave} Wave'),
                  const SizedBox(height: 8),
                  _buildDetailRow('일평균 세션',
                      '${statsController.dailyAvgSessions.toStringAsFixed(1)}회'),
                ],
              ),
      ),
    );
  }

  // 통계 아이템
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isDesktop ? 24 : 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Rajdhani',
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: color,
              fontSize: isDesktop ? 12 : 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isDesktop ? 12 : 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 모드 통계 행
  Widget _buildModeStatRow(
    BuildContext context,
    String mode,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            mode,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Rajdhani',
          ),
        ),
      ],
    );
  }

  // 상세 정보 행
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Rajdhani',
          ),
        ),
      ],
    );
  }
}
