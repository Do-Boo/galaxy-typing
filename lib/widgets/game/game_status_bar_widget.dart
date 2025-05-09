// 우주 디펜스 게임 상태 표시 바 위젯
// 작성: 2024-06-16
// 게임 상태 (점수, 웨이브, 생명력, 활성화된 아이템 등)를 표시하는 위젯

import 'package:flutter/material.dart';

import '../../models/power_up_item.dart';
import '../../utils/app_theme.dart';
import '../back_button.dart';

/// 게임 상태 표시 바 위젯
class GameStatusBarWidget extends StatelessWidget {
  /// 현재 점수
  final int score;

  /// 현재 웨이브
  final int wave;

  /// 현재 생명력
  final int lives;

  /// 보호막 활성화 여부
  final bool hasShield;

  /// 활성화된 파워업 효과들
  final Map<PowerUpType, DateTime> activePowerUpEffects;

  /// 뒤로가기 버튼 클릭 핸들러
  final VoidCallback onBackPressed;

  /// 현재 시간
  final DateTime now;

  /// 생성자
  const GameStatusBarWidget({
    super.key,
    required this.score,
    required this.wave,
    required this.lives,
    required this.hasShield,
    required this.activePowerUpEffects,
    required this.onBackPressed,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 뒤로가기 버튼
        CosmicBackButton(
          onPressed: onBackPressed,
        ),

        // 생명력 및 파워업 효과 표시
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 생명력 아이콘
              ...List.generate(3, (index) {
                final isActive = index < lives;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.favorite,
                        color:
                            isActive ? AppColors.error : AppColors.borderColor,
                        size: 24,
                      ),
                      if (index == 0 && hasShield)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 2),
                          ),
                        ),
                    ],
                  ),
                );
              }),

              // 활성화된 파워업 효과 표시
              ..._buildActivePowerUpIcons(),
            ],
          ),
        ),

        // 점수 및 웨이브 표시
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundLighter.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              Text('웨이브 $wave', style: AppTextStyles.bodySmall(context)),
            ],
          ),
        ),
      ],
    );
  }

  /// 활성화된 파워업 효과 아이콘 빌드
  List<Widget> _buildActivePowerUpIcons() {
    final icons = <Widget>[];

    activePowerUpEffects.forEach((type, endTime) {
      // 보호막은 생명력 아이콘에 통합해서 표시하므로 건너뜀
      if (type == PowerUpType.shield) return;

      // 남은 시간 계산
      final remainingSeconds = endTime.difference(now).inSeconds;

      if (remainingSeconds <= 0) return;

      // 파워업 아이콘 생성
      final powerUp = PowerUpItem(
        type: type,
        xPosition: 0,
        yPosition: 0,
        speed: 0,
        rotation: 0,
        spawnTime: DateTime.now(),
        duration: 0,
        word: '',
      );

      icons.add(
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Tooltip(
            message: '${powerUp.displayName}: $remainingSeconds초',
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: powerUp.color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: powerUp.color, width: 1),
              ),
              child: Icon(powerUp.icon, color: powerUp.color, size: 14),
            ),
          ),
        ),
      );
    });

    return icons;
  }
}
