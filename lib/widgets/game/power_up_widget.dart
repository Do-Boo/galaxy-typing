// 우주 디펜스 게임 파워업 아이템 위젯
// 작성: 2024-06-16
// 파워업 아이템 객체를 화면에 표시하는 위젯

import 'package:flutter/material.dart';

import '../../models/power_up_item.dart';
import '../../utils/app_theme.dart';

/// 파워업 아이템 위젯
class PowerUpWidget extends StatelessWidget {
  /// 표시할 파워업 아이템 모델
  final PowerUpItem powerUp;

  /// 생성자
  const PowerUpWidget({
    super.key,
    required this.powerUp,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: powerUp.rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: powerUp.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: powerUp.color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: powerUp.color.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(powerUp.icon, color: powerUp.color, size: 18),
            const SizedBox(width: 6),
            Text(
              powerUp.word,
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: powerUp.color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
