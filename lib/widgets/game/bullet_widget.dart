// 우주 디펜스 게임 총알 위젯
// 작성: 2024-06-16
// 총알 객체를 화면에 표시하는 위젯

import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/game_bullet_model.dart';
import '../../utils/app_theme.dart';

/// 총알 위젯
class BulletWidget extends StatelessWidget {
  /// 표시할 총알 모델
  final GameBulletModel bullet;

  /// 현재 시간
  final DateTime now;

  /// 생성자
  const BulletWidget({
    super.key,
    required this.bullet,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    // 적 총알은 다른 색상 사용
    final bulletColor = bullet.isEnemyBullet ? Colors.red : AppColors.primary;

    return Container(
      width: bullet.size,
      height: bullet.size,
      decoration: BoxDecoration(
        color: bulletColor,
        borderRadius: BorderRadius.circular(bullet.size / 2),
        boxShadow: [
          BoxShadow(
            color: bulletColor.withOpacity(0.8),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  /// 총알의 현재 위치를 계산합니다 (0.0~1.0 사이의 비율)
  Offset calculateCurrentPosition() {
    final timeElapsed =
        now.difference(bullet.startTime).inMilliseconds / 1000.0;
    final progress = min(1.0, timeElapsed * bullet.speed * 50);

    final currentX =
        bullet.startX + (bullet.targetX - bullet.startX) * progress;
    final currentY =
        bullet.startY + (bullet.targetY - bullet.startY) * progress;

    return Offset(currentX, currentY);
  }
}
