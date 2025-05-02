// 애니메이션 로고 위젯
// 작성: 2023-05-10
// 애플리케이션의 애니메이션 로고를 렌더링하는 위젯

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AnimatedLogo extends StatefulWidget {
  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // 발광 애니메이션
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    // 맥박 애니메이션
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );

    // 회전 애니메이션
    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              height: 120,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1 * _glowAnimation.value),
                    AppColors.background.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(
                      0.2 * _glowAnimation.value,
                    ),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 로켓 아이콘
                  _buildRocketIcon(),
                  SizedBox(width: 16),
                  // 로고 텍스트
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('COSMIC', style: AppTextStyles.logoStyle(context)),
                      Text('TYPER', style: AppTextStyles.logoStyle(context)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRocketIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(_glowAnimation.value),
          width: 2 * _glowAnimation.value,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 별 배경
          Icon(
            Icons.star,
            color: AppColors.secondary.withOpacity(0.3),
            size: 40,
          ),
          // 로켓
          Transform.translate(
            offset: Offset(0, 2 * (1 - _glowAnimation.value)), // 위아래로 약간 움직임
            child: Icon(
              Icons.rocket_launch,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
