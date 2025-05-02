// 우주 배경 위젯
// 작성: 2024-05-15
// 업데이트: 2024-06-02 (애니메이션 성능 최적화)
// 앱 배경으로 사용되는 움직이는 별 배경

import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SpaceBackground extends StatefulWidget {
  final bool animateStars;
  final bool showPlanets;
  final int particleDensity;

  const SpaceBackground({
    Key? key,
    this.animateStars = true,
    this.showPlanets = true,
    this.particleDensity = 100, // 기본 입자 수: 100개
  }) : super(key: key);

  @override
  _SpaceBackgroundState createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground> {
  late List<Star> _stars;
  late List<Star> _planets;
  final Random _random = Random();
  Timer? _animationTimer;
  double _animationValue = 0.0;
  final double _animationSpeed = 0.00005; // 애니메이션 속도 (값이 클수록 빠름)

  @override
  void initState() {
    super.initState();

    // 입자 수 최적화 (너무 많으면 성능이 저하될 수 있음)
    final actualDensity = widget.particleDensity > 150
        ? 150 // 최대 밀도 제한
        : widget.particleDensity;

    // 별 생성
    _stars = List.generate(
      actualDensity,
      (index) => _generateStar(),
    );

    // 행성 생성 (더 적은 수, 더 큰 별로 표현)
    _planets = widget.showPlanets
        ? List.generate(
            min(3, actualDensity ~/ 30), // 밀도에 비례해 행성 수 조정
            (index) => _generatePlanet(),
          )
        : [];

    // 타이머로 애니메이션 구현 (애니메이션 컨트롤러 대신)
    if (widget.animateStars) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    // 기존 타이머 취소
    _animationTimer?.cancel();

    // 60FPS에 가까운 주기로 타이머 설정 (약 16.6ms)
    _animationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        // 애니메이션 값 증가 (0.0-1.0 사이를 순환)
        _animationValue = (_animationValue + _animationSpeed) % 1.0;
      });
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  // 별 생성 함수
  Star _generateStar() {
    return Star(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 2 + 0.5, // 0.5-2.5 크기
      speed: _random.nextDouble() * 0.5 + 0.1, // 별 이동 속도
      blinkSpeed: _random.nextDouble() * 3 + 1, // 깜박임 속도
      color: _getRandomStarColor(), // 랜덤 색상
    );
  }

  // 행성 생성 함수 (큰 별로 표현)
  Star _generatePlanet() {
    return Star(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 4 + 3, // 3-7 크기 (큰 크기)
      speed: _random.nextDouble() * 0.05 + 0.01, // 행성은 더 느리게 이동
      blinkSpeed: _random.nextDouble() * 2 + 0.5, // 깜박임 속도
      color: _getRandomPlanetColor(), // 행성 색상
    );
  }

  // 랜덤 별 색상
  Color _getRandomStarColor() {
    final colors = [
      Colors.white,
      Colors.white.withOpacity(0.9),
      Colors.blue.shade100,
      Colors.yellow.shade100,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  // 랜덤 행성 색상
  Color _getRandomPlanetColor() {
    final colors = [
      Colors.blue.shade200,
      Colors.purple.shade200,
      Colors.orange.shade200,
      Colors.red.shade200,
      Colors.teal.shade200,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: SpaceBackgroundPainter(
          stars: _stars,
          planets: _planets,
          animationValue: _animationValue,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// 별 클래스
class Star {
  final double x;
  final double y;
  final double size;
  final double speed; // 별 이동 속도
  final double blinkSpeed; // 깜박임 속도
  final Color color;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.blinkSpeed,
    this.color = Colors.white,
  });
}

// 우주 배경 페인터
class SpaceBackgroundPainter extends CustomPainter {
  final List<Star> stars;
  final List<Star> planets;
  final double animationValue;

  SpaceBackgroundPainter({
    required this.stars,
    required this.animationValue,
    this.planets = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 그라데이션
    final Rect rect = Offset.zero & size;
    final Paint backgroundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.backgroundDarker,
          AppColors.background,
        ],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    // 별 그리기
    final starPaint = Paint();

    // 모든 별 그리기
    for (final star in stars) {
      final x = star.x * size.width;

      // 애니메이션 값과 별의 속도에 따라 y 위치 계산
      final yOffset = (animationValue * star.speed * 10) % 1.0;
      final y = (star.y + yOffset) % 1.0 * size.height;

      // 깜박임 효과
      final blinkValue = (sin(animationValue * 20 * star.blinkSpeed) + 1) / 2;
      final opacity = 0.3 + blinkValue * 0.7;

      starPaint.color = star.color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), star.size, starPaint);
    }

    // 행성 그리기
    for (final planet in planets) {
      final x = planet.x * size.width;

      // 행성은 더 천천히 이동
      final yOffset = (animationValue * planet.speed * 5) % 1.0;
      final y = (planet.y + yOffset) % 1.0 * size.height;

      // 행성 색상 및 글로우 효과
      final opacity =
          0.7 + (sin(animationValue * 10 * planet.blinkSpeed) + 1) * 0.15;

      final planetPaint = Paint()
        ..color = planet.color.withOpacity(opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, planet.size * 0.5);

      canvas.drawCircle(Offset(x, y), planet.size, planetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SpaceBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
