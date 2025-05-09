// 우주 디펜스 게임 적 위젯
// 작성: 2024-06-16
// 적 (단어) 객체를 화면에 표시하는 위젯

import 'package:flutter/material.dart';

import '../../models/enemy_word_model.dart';
import '../../utils/app_theme.dart';

/// 적 (단어) 위젯
class EnemyWidget extends StatelessWidget {
  /// 표시할 적 모델
  final EnemyWordModel enemy;

  /// 생성자
  const EnemyWidget({
    super.key,
    required this.enemy,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: enemy.rotation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.backgroundLighter.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          enemy.word,
          style: AppTextStyles.bodyLarge(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
