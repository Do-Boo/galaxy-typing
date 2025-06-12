import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_theme.dart';

// 커스텀 마우스 커서 타입
enum CustomCursorType {
  normal,
  hover,
  click,
}

/// 웹 환경을 위한 마우스 인터랙션 핸들러
/// 마우스 트레일, 클릭 파티클, 호버 효과 등을 제공
class MouseInteractionHandler extends StatefulWidget {
  final Widget child;
  final bool enableTrail;
  final bool enableClickParticles;
  final bool enableHoverEffects;
  final Color trailColor;
  final Color particleColor;

  const MouseInteractionHandler({
    super.key,
    required this.child,
    this.enableTrail = true,
    this.enableClickParticles = true,
    this.enableHoverEffects = true,
    this.trailColor = Colors.cyan,
    this.particleColor = Colors.white,
  });

  @override
  State<MouseInteractionHandler> createState() =>
      _MouseInteractionHandlerState();
}

class _MouseInteractionHandlerState extends State<MouseInteractionHandler>
    with TickerProviderStateMixin {
  // 마우스 트레일 관련
  final List<TrailParticle> _trailParticles = [];
  late AnimationController _trailController;

  // 클릭 파티클 관련
  final List<ClickParticle> _clickParticles = [];
  late AnimationController _clickController;

  // 마우스 위치
  Offset _mousePosition = Offset.zero;
  bool _isMouseInside = false;

  // 커스텀 마우스 커서 타입
  CustomCursorType _currentCursorType = CustomCursorType.normal;

  @override
  void initState() {
    super.initState();

    // 트레일 애니메이션 컨트롤러
    _trailController = AnimationController(
      duration: const Duration(milliseconds: 16), // 60fps
      vsync: this,
    )..repeat();

    // 클릭 파티클 애니메이션 컨트롤러
    _clickController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..repeat();

    _trailController.addListener(_updateTrailParticles);
    _clickController.addListener(_updateClickParticles);
  }

  @override
  void dispose() {
    _trailController.dispose();
    _clickController.dispose();
    super.dispose();
  }

  void _updateTrailParticles() {
    setState(() {
      // 새 트레일 파티클 추가 (마우스가 움직일 때만)
      if (_isMouseInside && widget.enableTrail) {
        _trailParticles.add(TrailParticle(
          position: _mousePosition,
          color: widget.trailColor,
          createdAt: DateTime.now(),
        ));
      }

      // 오래된 파티클 제거
      _trailParticles.removeWhere((particle) {
        final age =
            DateTime.now().difference(particle.createdAt).inMilliseconds;
        return age > 500; // 0.5초 후 제거
      });
    });
  }

  void _updateClickParticles() {
    setState(() {
      // 클릭 파티클 업데이트
      _clickParticles.removeWhere((particle) {
        particle.update();
        return particle.isDead;
      });
    });
  }

  void _onPointerMove(PointerEvent event) {
    setState(() {
      _mousePosition = event.localPosition;
      _isMouseInside = true;
    });
  }

  void _onPointerExit(PointerEvent event) {
    setState(() {
      _isMouseInside = false;
    });
  }

  void _onPointerDown(PointerEvent event) {
    if (!widget.enableClickParticles) return;

    // 클릭 위치에 파티클 폭발 생성
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _clickParticles.add(ClickParticle(
        position: event.localPosition,
        velocity: Offset(
          (random.nextDouble() - 0.5) * 200,
          (random.nextDouble() - 0.5) * 200,
        ),
        color: widget.particleColor,
        size: random.nextDouble() * 4 + 2,
      ));
    }
  }

  void _setCursorType(CustomCursorType type) {
    if (_currentCursorType != type) {
      setState(() {
        _currentCursorType = type;
      });
    }
  }

  // 커스텀 커서 스타일 반환
  SystemMouseCursor _getCustomCursor() {
    switch (_currentCursorType) {
      case CustomCursorType.hover:
        return SystemMouseCursors.click;
      case CustomCursorType.click:
        return SystemMouseCursors.grab;
      default:
        return SystemMouseCursors.basic;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 웹이 아닌 경우 기본 child만 반환
    if (!kIsWeb) {
      return widget.child;
    }

    return MouseRegion(
      cursor: _getCustomCursor(),
      onEnter: (_) => setState(() => _isMouseInside = true),
      onExit: (_) => setState(() => _isMouseInside = false),
      child: Listener(
        onPointerMove: _onPointerMove,
        onPointerDown: _onPointerDown,
        child: Stack(
          children: [
            // 메인 콘텐츠
            widget.child,

            // 마우스 효과 오버레이
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: MouseEffectsPainter(
                    trailParticles: _trailParticles,
                    clickParticles: _clickParticles,
                    mousePosition: _mousePosition,
                    cursorType: _currentCursorType,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 마우스 트레일 파티클 클래스
class TrailParticle {
  final Offset position;
  final Color color;
  final DateTime createdAt;

  TrailParticle({
    required this.position,
    required this.color,
    required this.createdAt,
  });

  double get opacity {
    final age = DateTime.now().difference(createdAt).inMilliseconds;
    return math.max(0, 1 - (age / 500)); // 0.5초에 걸쳐 페이드아웃
  }

  double get size {
    final age = DateTime.now().difference(createdAt).inMilliseconds;
    final progress = age / 500;
    return math.max(0, 8 * (1 - progress)); // 크기도 점점 작아짐
  }
}

/// 클릭 파티클 클래스
class ClickParticle {
  Offset position;
  Offset velocity;
  final Color color;
  final double initialSize;
  double life;
  bool isDead;

  ClickParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required double size,
  })  : initialSize = size,
        life = 1.0,
        isDead = false;

  void update() {
    // 위치 업데이트
    position += velocity * 0.016; // 60fps 기준

    // 중력 효과
    velocity = Offset(velocity.dx * 0.98, velocity.dy + 200 * 0.016);

    // 생명력 감소
    life -= 0.016 * 2; // 0.5초 생존

    if (life <= 0) {
      isDead = true;
    }
  }

  double get opacity => math.max(0, life);
  double get size => initialSize * life;
}

/// 마우스 효과를 그리는 커스텀 페인터
class MouseEffectsPainter extends CustomPainter {
  final List<TrailParticle> trailParticles;
  final List<ClickParticle> clickParticles;
  final Offset mousePosition;
  final CustomCursorType cursorType;

  MouseEffectsPainter({
    required this.trailParticles,
    required this.clickParticles,
    required this.mousePosition,
    required this.cursorType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 트레일 파티클 그리기
    for (final particle in trailParticles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );

      // 글로우 효과
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(
        particle.position,
        particle.size * 2,
        glowPaint,
      );
    }

    // 클릭 파티클 그리기
    for (final particle in clickParticles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );

      // 별 모양으로 그리기 (선택적)
      if (particle.size > 2) {
        _drawStar(canvas, particle.position, particle.size, paint);
      }
    }

    // 마우스 커서 주변 글로우 (선택적)
    if (mousePosition != Offset.zero) {
      final glowSize = cursorType == CustomCursorType.hover ? 15.0 : 10.0;
      final glowOpacity = cursorType == CustomCursorType.hover ? 0.3 : 0.2;

      final glowPaint = Paint()
        ..color = AppColors.primary.withOpacity(glowOpacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

      canvas.drawCircle(mousePosition, glowSize, glowPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final outerRadius = size;
    final innerRadius = size * 0.5;

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 2 * math.pi / 5) - math.pi / 2;
      final innerAngle = ((i + 0.5) * 2 * math.pi / 5) - math.pi / 2;

      final outerX = center.dx + outerRadius * math.cos(outerAngle);
      final outerY = center.dy + outerRadius * math.sin(outerAngle);
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 호버 효과를 위한 래퍼 위젯
class HoverEffectWrapper extends StatefulWidget {
  final Widget child;
  final double hoverScale;
  final Color? hoverColor;
  final Duration duration;
  final bool enableShadow;

  const HoverEffectWrapper({
    super.key,
    required this.child,
    this.hoverScale = 1.05,
    this.hoverColor,
    this.duration = const Duration(milliseconds: 200),
    this.enableShadow = true,
  });

  @override
  State<HoverEffectWrapper> createState() => _HoverEffectWrapperState();
}

class _HoverEffectWrapperState extends State<HoverEffectWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.hoverScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 웹이 아닌 경우 기본 child만 반환
    if (!kIsWeb) {
      return widget.child;
    }

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: widget.duration,
              decoration: BoxDecoration(
                boxShadow: _isHovered && widget.enableShadow
                    ? [
                        BoxShadow(
                          color: (widget.hoverColor ?? Colors.cyan)
                              .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
