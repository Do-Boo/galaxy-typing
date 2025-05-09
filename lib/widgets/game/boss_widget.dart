// 우주 디펜스 게임 보스 위젯
// 작성: 2024-06-16
// 보스 적 객체를 화면에 표시하는 위젯

import 'package:flutter/material.dart';

import '../../models/boss_enemy.dart';
import '../../utils/app_theme.dart';

/// 보스 적 위젯
class BossWidget extends StatelessWidget {
  /// 표시할 보스 모델
  final BossEnemy boss;

  /// 생성자
  const BossWidget({
    super.key,
    required this.boss,
  });

  @override
  Widget build(BuildContext context) {
    // 보스 색상 결정 (활성화 중일 때 더 밝게)
    final baseColor = boss.color;
    final bossColor = boss.isSpecialAbilityActive
        ? baseColor.withOpacity(0.9)
        : baseColor.withOpacity(0.7);

    // 보스 크기 (일반 적보다 큼)
    final size = boss.scale * 90.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 보스 체력바
        Container(
          width: size,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey[600]!, width: 1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: boss.healthPercentage,
            child: Container(
              decoration: BoxDecoration(
                color: boss.healthPercentage > 0.5
                    ? Colors.green
                    : boss.healthPercentage > 0.2
                        ? Colors.orange
                        : Colors.red,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // 보스 본체
        Stack(
          alignment: Alignment.center,
          children: [
            // 보스 몸체
            Transform.rotate(
              angle: boss.rotation,
              child: Container(
                width: size,
                height: size * 0.8,
                decoration: BoxDecoration(
                  color: bossColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(size / 4),
                  border: Border.all(color: bossColor, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: bossColor.withOpacity(0.7),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(boss.icon, color: bossColor, size: size / 2),
                ),
              ),
            ),

            // 보스 주변 빛나는 효과 (특수 능력 사용 중)
            if (boss.isSpecialAbilityActive)
              Container(
                width: size * 1.1,
                height: size * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: bossColor.withOpacity(0.8),
                      blurRadius: 30,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // 현재 입력해야 할 단어
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bossColor, width: 1.5),
          ),
          child: Text(
            boss.currentWord,
            style: AppTextStyles.titleSmall(
              context,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 4),

        // 보스 이름 표시
        Text(
          boss.title,
          style: AppTextStyles.bodySmall(
            context,
          ).copyWith(color: bossColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
