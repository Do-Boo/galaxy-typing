// 우주 디펜스 게임 카운트다운 위젯
// 작성: 2024-06-16
// 게임 시작 전 카운트다운 애니메이션을 표시하는 위젯

import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';

/// 게임 카운트다운 위젯
class GameCountdownWidget extends StatelessWidget {
  /// 카운트다운 값 (예: 3, 2, 1)
  final int countdownValue;

  /// 생성자
  const GameCountdownWidget({
    super.key,
    required this.countdownValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('준비하세요!', style: AppTextStyles.titleLarge(context)),
            const SizedBox(height: 24),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: Center(
                child: Text(
                  '$countdownValue',
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 36,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '단어를 입력하여 우주선을 방어하세요',
              style: AppTextStyles.bodyLarge(context),
            ),
            const SizedBox(height: 10),
            Container(
              width: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLighter.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '파워업 아이템',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '다양한 색상의 아이템을 타이핑하여 특수 능력을 획득하세요!',
                    style: AppTextStyles.bodySmall(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPowerUpHint(
                        context,
                        Icons.hourglass_bottom,
                        Colors.lightBlue,
                        '시간 감속',
                      ),
                      _buildPowerUpHint(
                        context,
                        Icons.shield,
                        Colors.blue,
                        '보호막',
                      ),
                      _buildPowerUpHint(
                        context,
                        Icons.favorite,
                        Colors.red,
                        '생명 회복',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 파워업 힌트 위젯
  Widget _buildPowerUpHint(
    BuildContext context,
    IconData icon,
    Color color,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall(context).copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
