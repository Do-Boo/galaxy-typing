// 커스텀 스플래시 스크린
// 작성: 2025-06-10
// 앱 시작 시 보여주는 스플래시 화면 (앱 초기화 포함)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/shared_text_service.dart';
import '../utils/app_theme.dart';
import '../widgets/space_background.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 상태바 스타일 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
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

    // 페이드 아웃 애니메이션
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _dotsController.repeat();
  }

  Future<void> _initializeApp() async {
    try {
      // 최소 스플래시 표시 시간 (2초)
      await Future.delayed(const Duration(seconds: 2));

      // SharedTextService 초기화
      final sharedTextService = SharedTextService();
      await Future.delayed(const Duration(milliseconds: 500)); // 초기화 시뮬레이션

      // 다른 필요한 초기화 작업들...
      await Future.delayed(const Duration(milliseconds: 500));

      // 페이드 아웃 후 메인 화면으로 이동
      await _fadeController.forward();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainScreen(),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (error) {
      // 에러 발생 시에도 메인 화면으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                // 우주 배경 효과
                const SpaceBackground(
                  animateStars: true,
                  showPlanets: true,
                  particleDensity: 80, // 스플래시용 적당한 밀도
                ),
                // 반투명 오버레이
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withOpacity(0.4),
                        AppColors.backgroundDarker.withOpacity(0.6),
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

                      // 키보드 아이콘 (메인 로고)
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 140,
                              height: 90,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // 키보드 키들 표현 (더 상세하게)
                                  Positioned(
                                    top: 18,
                                    left: 18,
                                    right: 18,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(
                                        9,
                                        (index) => Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 35,
                                    left: 18,
                                    right: 18,
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
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 52,
                                    left: 18,
                                    right: 18,
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
                                            borderRadius:
                                                BorderRadius.circular(2),
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

                      const SizedBox(height: 40),

                      // 앱 이름 (PressStart2P 폰트)
                      const Text(
                        'GALAXY TYPING',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 28,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 0),
                              blurRadius: 10,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 부제목
                      const Text(
                        '우주 테마 타자연습',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 18,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // 별 장식 (더 많이)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStar(AppColors.primary, 4),
                          const SizedBox(width: 15),
                          _buildStar(AppColors.secondary, 6),
                          const SizedBox(width: 15),
                          _buildStar(AppColors.primary, 5),
                          const SizedBox(width: 15),
                          _buildStar(AppColors.secondary, 4),
                          const SizedBox(width: 15),
                          _buildStar(AppColors.primary, 4),
                        ],
                      ),

                      const SizedBox(height: 80),

                      // 로딩 메시지
                      const Text(
                        '초기화 중...',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 애니메이션 점들
                      AnimatedBuilder(
                        animation: _dotsController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              final delay = index * 0.3;
                              final animationValue =
                                  (_dotsController.value - delay)
                                      .clamp(0.0, 1.0);
                              final opacity =
                                  (1.0 - (animationValue - 0.5).abs() * 2)
                                      .clamp(0.3, 1.0);

                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Opacity(
                                  opacity: opacity,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.6),
                                          blurRadius: 8,
                                          spreadRadius: 2,
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
        },
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
            blurRadius: size * 1.5,
            spreadRadius: size / 3,
          ),
        ],
      ),
    );
  }
}
