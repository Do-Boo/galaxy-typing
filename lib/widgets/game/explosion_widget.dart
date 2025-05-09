// 우주 디펜스 게임 폭발 효과 위젯
// 작성: 2024-06-16
// 폭발 효과 객체를 화면에 표시하는 위젯

import 'package:flutter/material.dart';

import '../../models/game_explosion_model.dart';

/// 폭발 효과 위젯
class ExplosionWidget extends StatelessWidget {
  /// 표시할 폭발 효과 모델
  final GameExplosionModel explosion;

  /// 현재 시간
  final DateTime now;

  /// 생성자
  const ExplosionWidget({
    super.key,
    required this.explosion,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    // 시간에 따른 폭발 효과 애니메이션
    final timeElapsed =
        now.difference(explosion.startTime).inMilliseconds / 1000.0;

    // 1초가 지나면 폭발 효과 사라짐
    if (timeElapsed >= 1.0) {
      return const SizedBox.shrink(); // 비어있는 위젯 반환
    }

    // 시간에 따라 크기와 투명도 조정
    final size = explosion.size * (1.0 + timeElapsed); // 점점 커짐
    final opacity = 1.0 - timeElapsed; // 점점 투명해짐

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.yellow.withOpacity(opacity * 0.8),
            Colors.orange.withOpacity(opacity * 0.6),
            Colors.red.withOpacity(opacity * 0.3),
            Colors.transparent,
          ],
          stops: const [0.2, 0.5, 0.7, 1.0],
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
