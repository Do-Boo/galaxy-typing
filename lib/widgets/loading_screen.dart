// 로딩 화면 위젯
// 작성: 2025-06-10
// 스플래시 이미지를 재사용하여 일관된 브랜딩을 제공하는 로딩 화면

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'space_background.dart';

class LoadingScreen extends StatefulWidget {
  final String? message;
  final bool showProgress;
  final double? progress; // 0.0 ~ 1.0

  const LoadingScreen({
    super.key,
    this.message,
    this.showProgress = false,
    this.progress,
  });

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 키보드 펄스 애니메이션
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 로딩 점들 애니메이션
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController.repeat(reverse: true);
    _dotsController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 우주 배경 효과
          const SpaceBackground(
            animateStars: true,
            showPlanets: true,
            particleDensity: 60, // 로딩용 적당한 밀도
          ),
          // 반투명 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withOpacity(0.5),
                  AppColors.backgroundDarker.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // 메인 콘텐츠
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // 키보드 아이콘 (스플래시와 동일한 디자인)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // 키보드 키들 표현
                            Positioned(
                              top: 15,
                              left: 15,
                              right: 15,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  8,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 30,
                              left: 15,
                              right: 15,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  7,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 45,
                              left: 15,
                              right: 15,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  6,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // 앱 이름 (PressStart2P 폰트)
                const Text(
                  'GALAXY TYPING',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 24,
                    color: AppColors.textPrimary,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 0),
                        blurRadius: 8,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 별 장식
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStar(AppColors.primary, 4),
                    const SizedBox(width: 20),
                    _buildStar(AppColors.secondary, 6),
                    const SizedBox(width: 20),
                    _buildStar(AppColors.primary, 4),
                  ],
                ),

                const SizedBox(height: 50),

                // 프로그레스 바 (선택사항)
                if (widget.showProgress) ...[
                  Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLighter,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 200 * (widget.progress ?? 0.0),
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 로딩 점들 또는 메시지
                if (widget.message != null) ...[
                  Text(
                    widget.message!,
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 애니메이션 점들
                AnimatedBuilder(
                  animation: _dotsController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final delay = index * 0.3;
                        final animationValue =
                            (_dotsController.value - delay).clamp(0.0, 1.0);
                        final opacity = (1.0 - (animationValue - 0.5).abs() * 2)
                            .clamp(0.3, 1.0);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Opacity(
                            opacity: opacity,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.6),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStar(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: size * 1.2,
            spreadRadius: size / 3,
          ),
        ],
      ),
    );
  }
}

// 로딩 화면을 쉽게 표시하기 위한 헬퍼 함수들
class LoadingHelper {
  static void show(
    BuildContext context, {
    String? message,
    bool showProgress = false,
    double? progress,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingScreen(
        message: message,
        showProgress: showProgress,
        progress: progress,
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  // 전체 화면 로딩 (페이지 전환용)
  static Widget fullScreen({
    String? message,
    bool showProgress = false,
    double? progress,
  }) {
    return LoadingScreen(
      message: message,
      showProgress: showProgress,
      progress: progress,
    );
  }
}
