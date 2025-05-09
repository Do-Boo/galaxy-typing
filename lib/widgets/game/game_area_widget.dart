// 우주 디펜스 게임 영역 위젯
// 작성: 2024-06-16
// 게임 요소들을 포함하는 메인 게임 영역 위젯

import 'package:flutter/material.dart';

import '../../models/boss_enemy.dart';
import '../../models/enemy_word_model.dart';
import '../../models/game_bullet_model.dart';
import '../../models/game_explosion_model.dart';
import '../../models/power_up_item.dart';
import 'boss_widget.dart';
import 'bullet_widget.dart';
import 'enemy_widget.dart';
import 'explosion_widget.dart';
import 'player_spaceship_widget.dart';
import 'power_up_widget.dart';

/// 게임 영역 위젯
class GameAreaWidget extends StatelessWidget {
  /// 적 목록
  final List<EnemyWordModel> enemies;

  /// 총알 목록
  final List<GameBulletModel> bullets;

  /// 폭발 효과 목록
  final List<GameExplosionModel> explosions;

  /// 파워업 아이템 목록
  final List<PowerUpItem> powerUps;

  /// 보스 (없을 수 있음)
  final BossEnemy? boss;

  /// 보호막 활성화 여부
  final bool hasShield;

  /// 현재 시간
  final DateTime now;

  /// 생성자
  const GameAreaWidget({
    super.key,
    required this.enemies,
    required this.bullets,
    required this.explosions,
    required this.powerUps,
    this.boss,
    this.hasShield = false,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // 적 (단어) 렌더링
          ...enemies.map((enemy) {
            return Positioned(
              left: enemy.xPosition * screenSize.width - 50,
              top: enemy.yPosition * screenSize.height,
              child: EnemyWidget(enemy: enemy),
            );
          }),

          // 파워업 아이템 렌더링
          ...powerUps.map((powerUp) {
            return Positioned(
              left: powerUp.xPosition * screenSize.width - 30,
              top: powerUp.yPosition * screenSize.height,
              child: PowerUpWidget(powerUp: powerUp),
            );
          }),

          // 총알 렌더링
          ...bullets.map((bullet) {
            final position = _calculateBulletPosition(bullet);
            return Positioned(
              left: position.dx * screenSize.width - bullet.size / 2,
              top: position.dy * screenSize.height - bullet.size / 2,
              child: BulletWidget(
                bullet: bullet,
                now: now,
              ),
            );
          }),

          // 폭발 효과 렌더링
          ...explosions.map((explosion) {
            return Positioned(
              left: explosion.xPosition * screenSize.width - explosion.size / 2,
              top: explosion.yPosition * screenSize.height - explosion.size / 2,
              child: ExplosionWidget(
                explosion: explosion,
                now: now,
              ),
            );
          }),

          // 우주선 (하단 중앙)
          Positioned(
            bottom: 20,
            left: screenSize.width / 2 - 25,
            child: PlayerSpaceshipWidget(
              hasShield: hasShield,
            ),
          ),

          // 보스 렌더링
          if (boss != null)
            Positioned(
              left: boss!.xPosition * screenSize.width - boss!.scale * 45,
              top: boss!.yPosition * screenSize.height - 10.0,
              child: BossWidget(boss: boss!),
            ),
        ],
      ),
    );
  }

  /// 총알의 현재 위치를 계산합니다 (0.0~1.0 사이의 비율)
  Offset _calculateBulletPosition(GameBulletModel bullet) {
    final timeElapsed =
        now.difference(bullet.startTime).inMilliseconds / 1000.0;
    final progress = timeElapsed * bullet.speed * 50;

    if (progress >= 1.0) {
      return Offset(bullet.targetX, bullet.targetY);
    }

    final currentX =
        bullet.startX + (bullet.targetX - bullet.startX) * progress;
    final currentY =
        bullet.startY + (bullet.targetY - bullet.startY) * progress;

    return Offset(currentX, currentY);
  }
}
