// 우주 디펜스 게임 플레이어 우주선 위젯
// 작성: 2024-06-16
// 플레이어의 우주선을 화면에 표시하는 위젯

import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';

/// 플레이어 우주선 위젯
class PlayerSpaceshipWidget extends StatelessWidget {
  /// 보호막 활성화 여부
  final bool hasShield;

  /// 생성자
  const PlayerSpaceshipWidget({
    super.key,
    this.hasShield = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 우주선 본체
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.rocket,
            color: Colors.white,
            size: 36,
          ),
        ),

        // 보호막 효과 표시
        if (hasShield)
          Positioned(
            left: -5,
            top: -5,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.2),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.8),
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
