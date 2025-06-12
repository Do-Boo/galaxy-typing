// 커스텀 스플래시 스크린
// 작성: 2025-06-10
// 앱 시작 시 보여주는 스플래시 화면 (앱 초기화 포함)

import 'dart:math' as math;

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
  late AnimationController _typingController;
  late AnimationController _particleController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _typingAnimation;
  late Animation<double> _progressAnimation;

  String _typingText = '';
  final String _fullText = 'GALAXY TYPING';
  double _loadingProgress = 0.0;
  String _loadingMessage = '시스템 초기화 중...';

  final List<FloatingParticle> _particles = [];

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
    _initializeParticles();
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

    // 타이핑 애니메이션
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    ));

    // 파티클 애니메이션
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // 진행률 애니메이션
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _dotsController.repeat();
    _particleController.repeat();

    // 타이핑 애니메이션 리스너
    _typingAnimation.addListener(() {
      final progress = _typingAnimation.value;
      final charCount = (_fullText.length * progress).floor();
      setState(() {
        _typingText = _fullText.substring(0, charCount);
      });
    });

    // 진행률 애니메이션 리스너
    _progressAnimation.addListener(() {
      setState(() {
        _loadingProgress = _progressAnimation.value;

        // 로딩 메시지 변경
        if (_loadingProgress < 0.3) {
          _loadingMessage = '시스템 초기화 중...';
        } else if (_loadingProgress < 0.6) {
          _loadingMessage = '우주 데이터 로딩 중...';
        } else if (_loadingProgress < 0.9) {
          _loadingMessage = '타이핑 엔진 준비 중...';
        } else {
          _loadingMessage = '완료!';
        }
      });
    });

    // 애니메이션 시작
    _typingController.forward();
    _progressController.forward();
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _particles.add(FloatingParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.5 + random.nextDouble() * 1.0,
        char: _getRandomChar(),
        color: _getRandomColor(),
        size: 12 + random.nextDouble() * 8,
      ));
    }
  }

  String _getRandomChar() {
    const chars = [
      'G',
      'A',
      'L',
      'A',
      'X',
      'Y',
      'T',
      'Y',
      'P',
      'I',
      'N',
      'G',
      '0',
      '1',
      '{',
      '}',
      '<',
      '>',
      '/',
      '*',
      '+',
      '-',
      '='
    ];
    return chars[math.Random().nextInt(chars.length)];
  }

  Color _getRandomColor() {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      Colors.cyan,
      Colors.purple,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  Future<void> _initializeApp() async {
    try {
      // 최소 스플래시 표시 시간 (3.5초)
      await Future.delayed(const Duration(milliseconds: 3500));

      // SharedTextService 초기화
      final sharedTextService = SharedTextService();
      await Future.delayed(const Duration(milliseconds: 300));

      // 다른 필요한 초기화 작업들...
      await Future.delayed(const Duration(milliseconds: 200));

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
    _typingController.dispose();
    _particleController.dispose();
    _progressController.dispose();
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
                  particleDensity: 80,
                ),

                // 떠다니는 파티클들
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ParticlePainter(
                          _particles, _particleController.value),
                      size: Size.infinite,
                    );
                  },
                ),

                // 반투명 오버레이
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withOpacity(0.3),
                        AppColors.backgroundDarker.withOpacity(0.5),
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

                      // 키보드 아이콘 (메인 로고) - 심플한 사선 키보드
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // 원근감
                                ..rotateX(-0.3) // X축 회전 (위에서 보는 각도)
                                ..rotateY(0.2), // Y축 회전 (약간 오른쪽으로)
                              child: Container(
                                width: 160,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.backgroundDarker,
                                      AppColors.backgroundDarker
                                          .withOpacity(0.8),
                                      AppColors.backgroundDarker
                                          .withOpacity(0.6),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color:
                                          AppColors.secondary.withOpacity(0.2),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // 키보드 키들 - 실제 QWERTY 레이아웃
                                    ...List.generate(4, (row) {
                                      // 실제 키보드 배열에 맞는 키 개수와 오프셋
                                      final keysInRow = [
                                        10,
                                        9,
                                        7,
                                        3
                                      ][row]; // Q줄, A줄, Z줄, 스페이스줄
                                      final rowOffset = [0, 6, 12, 30][row]
                                          .toDouble(); // 각 줄의 들여쓰기

                                      return Positioned(
                                        top: 15 + (row * 18.0),
                                        left: 15 + rowOffset,
                                        right: 15,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children:
                                              List.generate(keysInRow, (index) {
                                            final keyIndex = row * 10 + index;
                                            final delay = keyIndex * 0.03;
                                            final keyAnimation =
                                                (_typingAnimation.value - delay)
                                                    .clamp(0.0, 1.0);

                                            // 키 눌림 효과 계산
                                            final pressAnimation =
                                                (_dotsController.value * 10 +
                                                        keyIndex) %
                                                    1;
                                            final isPressed =
                                                pressAnimation > 0.7 &&
                                                    pressAnimation < 0.9;
                                            final pressDepth =
                                                isPressed ? 2.0 : 0.0;

                                            // 스페이스바 크기 결정
                                            double keyWidth = 8;
                                            if (row == 3) {
                                              if (index == 1)
                                                keyWidth = 40; // 스페이스바
                                              else
                                                keyWidth = 12; // 좌우 키들
                                            }

                                            return AnimatedBuilder(
                                              animation: _dotsController,
                                              builder: (context, child) {
                                                return AnimatedOpacity(
                                                  opacity: keyAnimation,
                                                  duration: const Duration(
                                                      milliseconds: 100),
                                                  child: Transform.translate(
                                                    offset:
                                                        Offset(0, pressDepth),
                                                    child: Container(
                                                      width: keyWidth,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        color: isPressed
                                                            ? AppColors.accent
                                                            : AppColors.primary
                                                                .withOpacity(
                                                                    0.8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3),
                                                        border: Border.all(
                                                          color: AppColors
                                                              .primary
                                                              .withOpacity(0.4),
                                                          width: 0.5,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: isPressed
                                                                ? AppColors
                                                                    .accent
                                                                    .withOpacity(
                                                                        0.8)
                                                                : AppColors
                                                                    .primary
                                                                    .withOpacity(
                                                                        0.6),
                                                            blurRadius:
                                                                isPressed
                                                                    ? 8
                                                                    : 4,
                                                            spreadRadius:
                                                                isPressed
                                                                    ? 2
                                                                    : 1,
                                                            offset: Offset(
                                                                0,
                                                                isPressed
                                                                    ? 1
                                                                    : 3),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }),
                                        ),
                                      );
                                    }),

                                    // 타이핑 파티클 효과
                                    AnimatedBuilder(
                                      animation: _dotsController,
                                      builder: (context, child) {
                                        return CustomPaint(
                                          size: const Size(160, 100),
                                          painter: TypingParticlePainter(
                                            animation: _dotsController.value,
                                            primaryColor: AppColors.primary,
                                            secondaryColor: AppColors.secondary,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 50),

                      // 앱 이름 (타이핑 효과)
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _typingText,
                              style: const TextStyle(
                                fontFamily: 'PressStart2P',
                                fontSize: 28,
                                color: AppColors.textPrimary,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 0),
                                    blurRadius: 15,
                                    color: AppColors.primary,
                                  ),
                                  Shadow(
                                    offset: Offset(2, 2),
                                    blurRadius: 5,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                            // 타이핑 커서
                            if (_typingText.length < _fullText.length)
                              AnimatedBuilder(
                                animation: _dotsController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity:
                                        (_dotsController.value * 2) % 1.0 > 0.5
                                            ? 1.0
                                            : 0.0,
                                    child: Container(
                                      width: 3,
                                      height: 28,
                                      margin: const EdgeInsets.only(left: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(1),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.8),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // 부제목
                      const Text(
                        '우주 테마 타자연습',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 18,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w300,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 80),

                      // 진행률 바
                      Container(
                        width: 280,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDarker,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _loadingProgress,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 진행률 퍼센트
                      Text(
                        '${(_loadingProgress * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Rajdhani',
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: AppColors.primary.withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 로딩 메시지
                      Text(
                        _loadingMessage,
                        style: const TextStyle(
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
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Opacity(
                                  opacity: opacity,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.8),
                                          blurRadius: 10,
                                          spreadRadius: 3,
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

                      const Spacer(flex: 2),
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
}

// 떠다니는 파티클 클래스
class FloatingParticle {
  double x;
  double y;
  final double speed;
  final String char;
  final Color color;
  final double size;

  FloatingParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.char,
    required this.color,
    required this.size,
  });

  void update() {
    y -= speed * 0.01;
    if (y < -0.1) {
      y = 1.1;
      x = math.Random().nextDouble();
    }
  }
}

// 파티클 페인터
class ParticlePainter extends CustomPainter {
  final List<FloatingParticle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color.withOpacity(0.6)
        ..style = PaintingStyle.fill;

      final textPainter = TextPainter(
        text: TextSpan(
          text: particle.char,
          style: TextStyle(
            color: particle.color.withOpacity(0.7),
            fontSize: particle.size,
            fontFamily: 'PressStart2P',
            shadows: [
              Shadow(
                color: particle.color.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          particle.x * size.width - textPainter.width / 2,
          particle.y * size.height - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 타이핑 파티클 페인터 클래스
class TypingParticlePainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;

  TypingParticlePainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 타이핑 파티클들 (작은 글자들이 떠다니는 효과)
    final particles = ['G', 'A', 'L', 'A', 'X', 'Y', '•', '★', '◦'];

    for (int i = 0; i < particles.length; i++) {
      final progress = (animation * 2 + i * 0.3) % 1;
      final opacity = (1 - progress) * 0.6;

      if (opacity > 0) {
        final x =
            (size.width * 0.2) + (i * size.width * 0.08) + (progress * 20);
        final y = size.height * 0.3 + (progress * size.height * 0.4);

        final textPainter = TextPainter(
          text: TextSpan(
            text: particles[i],
            style: TextStyle(
              color: (i % 2 == 0 ? primaryColor : secondaryColor)
                  .withOpacity(opacity),
              fontSize: 8 + (progress * 4),
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: (i % 2 == 0 ? primaryColor : secondaryColor)
                      .withOpacity(opacity * 0.8),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
