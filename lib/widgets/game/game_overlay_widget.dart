// 우주 디펜스 게임 오버레이 위젯
// 작성: 2024-06-16
// 게임 일시정지, 게임 오버 등 오버레이를 표시하는 위젯

import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import '../cosmic_button.dart';

/// 오버레이 유형
enum GameOverlayType {
  /// 일시정지
  pause,

  /// 게임 오버
  gameOver,
}

/// 게임 오버레이 위젯
class GameOverlayWidget extends StatelessWidget {
  /// 오버레이 유형
  final GameOverlayType type;

  /// 점수 (게임 오버 시 표시)
  final int? score;

  /// 최대 웨이브 (게임 오버 시 표시)
  final int? maxWave;

  /// 처치한 적 수 (게임 오버 시 표시)
  final int? enemiesDefeated;

  /// 계속하기 버튼 핸들러
  final VoidCallback? onContinue;

  /// 다시 시작 버튼 핸들러
  final VoidCallback? onRestart;

  /// 나가기 버튼 핸들러
  final VoidCallback? onExit;

  /// 생성자
  const GameOverlayWidget({
    super.key,
    required this.type,
    this.score,
    this.maxWave,
    this.enemiesDefeated,
    this.onContinue,
    this.onRestart,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background.withOpacity(0.7),
      child: Center(
        child: type == GameOverlayType.pause
            ? _buildPauseOverlay(context)
            : _buildGameOverOverlay(context),
      ),
    );
  }

  /// 일시정지 오버레이
  Widget _buildPauseOverlay(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('일시정지', style: AppTextStyles.titleLarge(context)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CosmicButton(
              label: '계속하기',
              icon: Icons.play_arrow,
              type: CosmicButtonType.primary,
              onPressed: onContinue,
            ),
            const SizedBox(width: 16),
            CosmicButton(
              label: '나가기',
              icon: Icons.exit_to_app,
              type: CosmicButtonType.outline,
              onPressed: onExit,
            ),
          ],
        ),
      ],
    );
  }

  /// 게임 오버 오버레이
  Widget _buildGameOverOverlay(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 타이틀
        Text('게임 오버', style: AppTextStyles.titleLarge(context)),
        const SizedBox(height: 20),

        // 점수 표시
        if (score != null)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 15),
            child: Column(
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('점수', style: AppTextStyles.bodyMedium(context)),
              ],
            ),
          ),

        // 결과 통계
        if (maxWave != null && enemiesDefeated != null)
          Container(
            width: 280,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundLighter.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor, width: 1),
            ),
            child: Column(
              children: [
                _buildResultRow(context, '최대 웨이브', '$maxWave'),
                _buildResultRow(context, '처치한 적', '$enemiesDefeated'),
              ],
            ),
          ),

        const SizedBox(height: 25),

        // 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CosmicButton(
              label: '다시 시작',
              icon: Icons.replay,
              type: CosmicButtonType.primary,
              onPressed: onRestart,
            ),
            const SizedBox(width: 16),
            CosmicButton(
              label: '나가기',
              icon: Icons.exit_to_app,
              type: CosmicButtonType.outline,
              onPressed: onExit,
            ),
          ],
        ),
      ],
    );
  }

  /// 결과 행 위젯
  Widget _buildResultRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
