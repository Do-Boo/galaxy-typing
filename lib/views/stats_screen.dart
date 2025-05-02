// 통계 화면
// 작성: 2024-05-15
// 사용자의 타이핑 통계를 표시하는 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/stats_controller.dart';
import '../models/session_data.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../widgets/back_button.dart';
import '../widgets/cosmic_button.dart';
import '../widgets/cosmic_card.dart';
import '../widgets/page_header.dart';
import '../widgets/space_background.dart';
import '../widgets/statistics_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['요약', '기록', '성장'];
  final _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 음악 중지 (space_defense_screen 전용)
    _audioService.stop();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsController = Provider.of<StatsController>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 배경
          const SpaceBackground(),

          // 메인 콘텐츠
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
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
                              title: '통계',
                              subtitle: '내 타이핑 성과 분석',
                              centerAlign: true,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 최상위 통계 요약 카드
                      _buildTopStatsCard(context, statsController),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // 탭 선택기
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLighter.withOpacity(0.5),
                    border: const Border(
                      bottom: BorderSide(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.labelLarge(context),
                    tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
                  ),
                ),

                // 탭 콘텐츠
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildSummaryTab(context, statsController),
                      _buildHistoryTab(context, statsController),
                      _buildGrowthTab(context, statsController),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 상단 통계 요약 카드
  Widget _buildTopStatsCard(
      BuildContext context, StatsController statsController) {
    return StatisticsCard(
      title: '전체 통계',
      titleIcon: Icons.analytics,
      items: [
        StatItem(
          value: statsController.totalSessionCount.toString(),
          label: '총 연습 횟수',
          icon: Icons.history,
        ),
        StatItem(
          value: statsController.totalTimeSpent.toString(),
          label: '총 연습 시간(분)',
          icon: Icons.timer,
        ),
        StatItem(
          value: statsController.totalCharTyped.toString(),
          label: '총 입력 문자',
          icon: Icons.keyboard,
        ),
        StatItem(
          value: statsController.averageCpm.toString(),
          label: '평균 CPM',
          icon: Icons.speed,
          valueColor: AppColors.primary,
        ),
        StatItem(
          value: '${statsController.accuracy}%',
          label: '평균 정확도',
          icon: Icons.check_circle_outline,
          valueColor: AppColors.success,
        ),
        StatItem(
          value: statsController.highestWave.toString(),
          label: '최고 웨이브',
          icon: Icons.waves,
          valueColor: AppColors.secondary,
        ),
      ],
      columns: 3,
    );
  }

  // 요약 탭
  Widget _buildSummaryTab(
      BuildContext context, StatsController statsController) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모드별 통계
          _buildModeStatsCard(context, statsController),

          const SizedBox(height: 20),

          // 일일 평균
          _buildDailyAveragesCard(context, statsController),

          const SizedBox(height: 20),

          // 성장 요약
          _buildGrowthSummaryCard(context, statsController),
        ],
      ),
    );
  }

  // 기록 탭
  Widget _buildHistoryTab(
      BuildContext context, StatsController statsController) {
    // 연습 세션 기록을 최신순으로 표시
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: statsController.recentSessions.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          // 헤더
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '최근 연습 기록',
              style: AppTextStyles.titleMedium(context),
            ),
          );
        }

        // 세션 데이터
        final session = statsController.recentSessions[index - 1];
        return _buildSessionCard(context, session);
      },
    );
  }

  // 성장 탭
  Widget _buildGrowthTab(
      BuildContext context, StatsController statsController) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 성장 그래프 (CPM)
          _buildGrowthGraphCard(
            context,
            title: 'CPM 성장 추세',
            subtitle: '시간에 따른 CPM 변화',
            icon: Icons.show_chart,
          ),

          const SizedBox(height: 20),

          // 성장 그래프 (정확도)
          _buildGrowthGraphCard(
            context,
            title: '정확도 성장 추세',
            subtitle: '시간에 따른 정확도 변화',
            icon: Icons.timeline,
          ),

          const SizedBox(height: 20),

          // 성장 추천사항
          CosmicCard(
            title: '개선 추천사항',
            titleIcon: Icons.lightbulb_outline,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTip(
                    context,
                    tip: '특수 문자 연습에 더 집중하세요',
                    detail: '특수 문자 입력 시 오류가 자주 발생합니다.',
                  ),
                  _buildTip(
                    context,
                    tip: '장시간 연습 세션을 늘려보세요',
                    detail: '5분 이상의 세션에서 집중력이 떨어지는 경향이 있습니다.',
                  ),
                  _buildTip(
                    context,
                    tip: '우주 디펜스 모드에 도전해보세요',
                    detail: '게임 요소를 통해 타이핑 재미와 속도를 향상시킬 수 있습니다.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 모드별 통계 카드
  Widget _buildModeStatsCard(
      BuildContext context, StatsController statsController) {
    return CosmicCard(
      title: '모드별 통계',
      titleIcon: Icons.dashboard,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            _buildModeStatRow(
              context,
              mode: '기본 연습',
              sessions: statsController.basicPracticeSessions,
              avgCpm: statsController.basicPracticeAvgCpm,
              icon: Icons.keyboard,
            ),
            const Divider(color: AppColors.borderColor),
            _buildModeStatRow(
              context,
              mode: '시간 도전',
              sessions: statsController.timeChallengeSessions,
              avgCpm: statsController.timeChallengeAvgCpm,
              icon: Icons.timer,
            ),
            const Divider(color: AppColors.borderColor),
            _buildModeStatRow(
              context,
              mode: '우주 디펜스',
              sessions: statsController.defenseModeSessions,
              avgCpm: statsController.defenseModeAvgCpm,
              icon: Icons.rocket_launch,
            ),
          ],
        ),
      ),
    );
  }

  // 모드별 통계 행
  Widget _buildModeStatRow(
    BuildContext context, {
    required String mode,
    required List<SessionData> sessions,
    required double avgCpm,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              mode,
              style: AppTextStyles.bodyLarge(context),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${sessions.length} 세션',
                style: AppTextStyles.bodySmall(context),
              ),
              Text(
                '평균 ${avgCpm.toStringAsFixed(0)} CPM',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 일일 평균 카드
  Widget _buildDailyAveragesCard(
      BuildContext context, StatsController statsController) {
    return CosmicCard(
      title: '일일 평균',
      titleIcon: Icons.calendar_today,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDailyAvgItem(
              context,
              value: statsController.dailyAvgSessions.toString(),
              label: '세션 수',
              icon: Icons.repeat,
            ),
            _buildDailyAvgItem(
              context,
              value: statsController.dailyAvgTimeSpent.toString(),
              label: '연습 시간(분)',
              icon: Icons.access_time,
            ),
            _buildDailyAvgItem(
              context,
              value: statsController.dailyAvgCpm.toString(),
              label: 'CPM',
              icon: Icons.speed,
              highlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  // 일일 평균 항목
  Widget _buildDailyAvgItem(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    bool highlighted = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: highlighted ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium(context).copyWith(
            color: highlighted ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall(context),
        ),
      ],
    );
  }

  // 성장 요약 카드
  Widget _buildGrowthSummaryCard(
      BuildContext context, StatsController statsController) {
    final improvementPercent = statsController.cpmImprovementPercent;
    final isImproved = improvementPercent > 0;

    return CosmicCard(
      title: '성장 요약',
      titleIcon: Icons.trending_up,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isImproved ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isImproved ? AppColors.success : AppColors.error,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${isImproved ? '+' : ''}${improvementPercent.toStringAsFixed(1)}%',
                  style: AppTextStyles.titleLarge(context).copyWith(
                    color: isImproved ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '지난 주 대비 CPM 성장률',
              style: AppTextStyles.bodyMedium(context),
            ),
            const SizedBox(height: 16),
            CosmicButton(
              label: '상세 분석 보기',
              icon: Icons.analytics,
              type: CosmicButtonType.outline,
              onPressed: () {
                _tabController.animateTo(2); // 성장 탭으로 이동
              },
            ),
          ],
        ),
      ),
    );
  }

  // 세션 카드
  Widget _buildSessionCard(BuildContext context, dynamic session) {
    // 실제 앱에서는 session 객체의 구조에 맞게 데이터를 추출
    const date = '2024-05-15 14:30';
    const duration = '12분';
    const mode = '기본 연습';
    const cpm = '145 CPM';
    const accuracy = '92%';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CosmicCard(
        useDarkVariant: true,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: AppTextStyles.bodySmall(context),
                  ),
                  Text(
                    mode,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: AppTextStyles.bodyMedium(context),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.speed,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        cpm,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        accuracy,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 그래프 카드 (실제 앱에서는 차트 라이브러리 사용 필요)
  Widget _buildGrowthGraphCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return CosmicCard(
      title: title,
      titleIcon: icon,
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                color: AppColors.primary.withOpacity(0.5),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium(context),
              ),
              const SizedBox(height: 8),
              Text(
                '실제 앱에서는 fl_chart 등의 라이브러리로 그래프 구현',
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 팁 아이템
  Widget _buildTip(
    BuildContext context, {
    required String tip,
    required String detail,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb,
            color: AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: AppTextStyles.bodyMedium(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
