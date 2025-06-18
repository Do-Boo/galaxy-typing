// 앱의 메인 화면 - 홈 화면 및 게임 모드 선택 화면
// 작성: 2023-05-10
// 업데이트: 2024-05-15 (PressStart2P 폰트 일관성 개선)
// 업데이트: 2024-06-07 (웹버전 스타일 기반 반응형 개선)
// 게임 모드 선택 및 통계 요약을 보여주는 메인 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/cosmic_button.dart';
import '../widgets/cosmic_pulsing_text.dart';
import '../widgets/mouse_interaction_handler.dart';
import '../widgets/space_background.dart';
import 'basic_practice_screen.dart';
import 'long_text_practice_screen.dart';
import 'settings_screen.dart';
import 'shared_text_library_screen.dart';
import 'space_defense_screen.dart';
import 'stats_screen.dart';
import 'time_challenge_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    // 메인 화면에서는 음악을 재생하지 않음 (space_defense_screen 전용)
    _audioService.stop(); // 모든 음악 중지
  }

  @override
  Widget build(BuildContext context) {
    // 설정 및 통계 컨트롤러
    final settingsController = Provider.of<SettingsController>(context);
    final statsController = Provider.of<StatsController>(context);

    // 화면 크기에 따른 패딩 계산
    final screenPadding = ResponsiveHelper.screenPadding(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return MouseInteractionHandler(
      enableTrail: true,
      enableClickParticles: true,
      trailColor: AppColors.primary,
      particleColor: AppColors.secondary,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // 배경 효과
            const SpaceBackground(
              particleDensity: 80, // 밀도 줄임 (원래 값: 150/100/70)
              animateStars: true,
            ),

            // 메인 콘텐츠
            SafeArea(
              child: ResponsiveHelper.centeredContent(
                context: context,
                child: Scrollbar(
                  thumbVisibility: false, // 스크롤바 숨김
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: screenPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: isDesktop ? 20 : 10),

                          // 로고 및 제목
                          Container(
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                // 반짝이는 로고 텍스트
                                CosmicPulsingText(
                                  text: 'GALAXY TYPING',
                                  fontSize:
                                      isDesktop ? 36 : (isTablet ? 32 : 26),
                                  enablePulsing: true,
                                ),
                                const SizedBox(height: 6),
                                // 부제목
                                Text(
                                  '은하계를 누비는 타자 연습',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: isDesktop ? 16 : 14,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: isDesktop ? 30 : 20),

                          // 반응형 레이아웃 - 데스크톱에서는 통계 카드와 메뉴를 나란히 배치
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 메인 콘텐츠 영역 (통계 + 게임 모드)
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    children: [
                                      // 통계 카드
                                      _buildStatsCard(context, statsController),
                                      const SizedBox(height: 20),
                                      // 게임 모드
                                      _buildGameModes(context),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // 사이드바 (광고 영역)
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    children: [
                                      // 사이드바 광고 placeholder
                                      _buildSidebarAdPlaceholder(context),
                                      const SizedBox(height: 20),
                                      // 추가 사이드바 광고 placeholder
                                      _buildSidebarAdPlaceholder(context,
                                          isSecondary: true),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                // 통계 카드
                                _buildStatsCard(context, statsController),
                                const SizedBox(height: 16),
                                // 모바일 광고 placeholder
                                _buildAdPlaceholder(context),
                                const SizedBox(height: 20),
                                // 게임 모드
                                _buildGameModes(context),
                                const SizedBox(height: 16),
                                // 하단 광고 placeholder (모바일만)
                                _buildBottomAdPlaceholder(context),
                              ],
                            ),

                          // 하단 버튼 행 (모든 화면 크기에서 공통)
                          const SizedBox(height: 16),
                          _buildBottomButtons(context, settingsController),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 통계 요약 카드 위젯
  Widget _buildStatsCard(
    BuildContext context,
    StatsController statsController,
  ) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return HoverEffectWrapper(
      hoverScale: 1.02,
      hoverColor: AppColors.secondary,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundLighter.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      color: AppColors.primary,
                      size: isDesktop ? 28 : 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '내 타이핑 현황',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: isDesktop ? 22 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                // 전체보기 버튼
                TextButton(
                  onPressed: () {
                    // 상세 통계 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StatsScreen()),
                    );
                  },
                  child: Text(
                    '전체보기',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(color: AppColors.borderColor, height: 30),

            // 통계 내용 - 모든 화면 크기에서 가로 배치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  context,
                  label: '평균 CPM',
                  value: statsController.averageCpm.toString(),
                  icon: Icons.speed,
                  color: AppColors.primary,
                  horizontal: true,
                ),
                _verticalDivider(),
                _buildStatItem(
                  context,
                  label: '정확도',
                  value: '${statsController.accuracy.round()}%',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  horizontal: true,
                ),
                _verticalDivider(),
                _buildStatItem(
                  context,
                  label: '최고 웨이브',
                  value: statsController.highestWave.toString(),
                  icon: Icons.waves,
                  color: AppColors.secondary,
                  horizontal: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 통계 아이템 위젯
  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool horizontal = false,
  }) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    if (horizontal) {
      return Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isDesktop ? 24 : 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  // 세로 구분선
  Widget _verticalDivider() {
    return Container(
      height: 50,
      width: 1,
      color: AppColors.borderColor,
    );
  }

  // 게임 모드 섹션
  Widget _buildGameModes(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final columns = ResponsiveHelper.gridColumns(context);

    // 타이틀
    final header = Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Row(
        children: [
          Icon(
            Icons.sports_esports,
            color: AppColors.primary,
            size: isDesktop ? 28 : 24,
          ),
          const SizedBox(width: 8),
          Text(
            '게임 모드',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isDesktop ? 22 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    // 게임 모드 항목들
    final modeItems = [
      _buildGameModeItem(
        context: context,
        title: '기본 연습',
        description: '자신만의 페이스로 타이핑 연습',
        icon: Icons.keyboard,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BasicPracticeScreen()),
        ),
      ),
      _buildGameModeItem(
        context: context,
        title: '긴글 연습',
        description: '문단 단위의 긴 텍스트로 실력 향상',
        icon: Icons.article,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const LongTextPracticeScreen()),
        ),
      ),
      _buildGameModeItem(
        context: context,
        title: '텍스트 라이브러리',
        description: '사용자들이 공유한 다양한 텍스트 모음',
        icon: Icons.library_books,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const SharedTextLibraryScreen()),
        ),
      ),
      _buildGameModeItem(
        context: context,
        title: '시간 도전',
        description: '제한 시간 내 최대한 많은 단어 입력',
        icon: Icons.timer,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TimeChallengeScreen()),
        ),
      ),
      _buildGameModeItem(
        context: context,
        title: '우주 디펜스',
        description: '단어를 입력해 외계 침략자 방어',
        icon: Icons.rocket_launch,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SpaceDefenseScreen()),
        ),
      ),
      _buildGameModeItem(
        context: context,
        title: '통계 분석',
        description: '타이핑 성과 확인 및 개인 성장 추적',
        icon: Icons.insights,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatsScreen()),
        ),
      ),
    ];

    // 태블릿과 데스크톱에서는 그리드 뷰로 표시
    if (isTablet || isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              // childAspectRatio: isDesktop ? 1.5 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: modeItems.length,
            itemBuilder: (context, index) => modeItems[index],
          ),
        ],
      );
    }
    // 모바일에서는 기존 리스트 형태로 표시
    else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          ...modeItems,
        ],
      );
    }
  }

  // 게임 모드 항목 위젯
  Widget _buildGameModeItem({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    // 태블릿과 데스크톱에서는 카드 형태로
    if (isTablet || isDesktop) {
      return HoverEffectWrapper(
        hoverScale: 1.05,
        hoverColor: AppColors.secondary,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLighter.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderColor,
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: isDesktop ? 48 : 36,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: isDesktop ? 15 : 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    // 모바일에서는 리스트 아이템 형태로
    else {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundLighter.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 아이콘
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      size: 28,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 텍스트 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // 화살표 아이콘
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  // 하단 버튼 행
  Widget _buildBottomButtons(
    BuildContext context,
    SettingsController settingsController,
  ) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final buttonSize =
        isDesktop ? CosmicButtonSize.large : CosmicButtonSize.medium;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HoverEffectWrapper(
            hoverScale: 1.1,
            hoverColor: AppColors.primary,
            child: CosmicButton(
              label: '설정',
              icon: Icons.settings,
              type: CosmicButtonType.outline,
              size: buttonSize,
              onPressed: () {
                // 설정 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          HoverEffectWrapper(
            hoverScale: 1.1,
            hoverColor: AppColors.secondary,
            child: CosmicButton(
              label: '도움말',
              icon: Icons.help_outline,
              type: CosmicButtonType.text,
              size: buttonSize,
              onPressed: () {
                _showHelpDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 도움말 다이얼로그
  void _showHelpDialog(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLighter,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderColor, width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              '도움말',
              style: TextStyle(
                fontSize: isDesktop ? 22 : 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '갤럭시 타이핑은 즐겁게 타자 연습을 할 수 있는 앱입니다. 다양한 모드를 선택하여 연습해보세요!',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHelpItem('기본 연습: 부담 없이 타자 연습하기', Icons.keyboard),
                  const SizedBox(height: 8),
                  _buildHelpItem('시간 도전: 제한 시간 안에 많은 단어 입력하기', Icons.timer),
                  const SizedBox(height: 8),
                  _buildHelpItem(
                      '우주 디펜스: 단어를 입력해 침략자 물리치기', Icons.rocket_launch),
                  const SizedBox(height: 8),
                  _buildHelpItem('통계 분석: 자신의 타이핑 능력 확인하기', Icons.insights),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              '확인',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: isDesktop ? 16 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // 도움말 아이템
  Widget _buildHelpItem(String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // 광고 placeholder 위젯
  Widget _buildAdPlaceholder(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      width: double.infinity,
      height: isDesktop ? 120 : (isTablet ? 100 : 80),
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ads_click,
              color: AppColors.primary.withOpacity(0.5),
              size: isDesktop ? 32 : 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Advertisement',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.5),
                fontSize: isDesktop ? 14 : 12,
                fontFamily: 'Rajdhani',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 하단 광고 placeholder 위젯
  Widget _buildBottomAdPlaceholder(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      width: double.infinity,
      height: isDesktop ? 100 : (isTablet ? 80 : 60),
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : (isTablet ? 24 : 16),
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Banner Advertisement',
          style: TextStyle(
            color: AppColors.primary.withOpacity(0.4),
            fontSize: isDesktop ? 12 : 10,
            fontFamily: 'Rajdhani',
          ),
        ),
      ),
    );
  }

  // 사이드바 광고 placeholder 위젯
  Widget _buildSidebarAdPlaceholder(BuildContext context,
      {bool isSecondary = false}) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: double.infinity,
      height: isSecondary ? 200 : 250,
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSecondary ? Icons.campaign : Icons.ads_click,
              color: AppColors.primary.withOpacity(0.5),
              size: isDesktop ? 32 : 24,
            ),
            const SizedBox(height: 8),
            Text(
              isSecondary ? 'Promotion' : 'Advertisement',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.5),
                fontSize: isDesktop ? 14 : 12,
                fontFamily: 'Rajdhani',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isSecondary ? '300x200' : '300x250',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.3),
                fontSize: isDesktop ? 10 : 8,
                fontFamily: 'Rajdhani',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
