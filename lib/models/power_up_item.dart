// 우주 디펜스 게임 아이템 모델
// 작성: 2024-06-05
// 게임 내 다양한 파워업 아이템을 정의하는 모델

import 'package:flutter/material.dart';

/// 파워업 아이템 종류
enum PowerUpType {
  /// 시간 감속 - 적들의 속도를 일시적으로 감소시킵니다.
  slowTime,

  /// 다중 공격 - 일정 시간 동안 자동으로 무작위 적을 공격합니다.
  multiShot,

  /// 실드 - 일정 시간 동안 또는 단 한 번 데미지를 방어합니다.
  shield,

  /// 생명력 회복 - 플레이어의 생명력을 1 회복합니다.
  extraLife,

  /// 폭발 - 화면 내 모든 적을 한 번에 파괴합니다.
  explosion,
}

/// 파워업 아이템 클래스
class PowerUpItem {
  /// 아이템 유형
  final PowerUpType type;

  /// 화면상의 X 위치 (0.0 ~ 1.0)
  double xPosition;

  /// 화면상의 Y 위치 (0.0 ~ 1.0)
  double yPosition;

  /// 아이템 이동 속도
  final double speed;

  /// 아이템 회전 각도
  final double rotation;

  /// 아이템 생성 시간
  final DateTime spawnTime;

  /// 아이템 지속 시간 (초)
  final int duration;

  /// 아이템에 할당된 단어
  final String word;

  /// 아이템 생성자
  PowerUpItem({
    required this.type,
    required this.xPosition,
    required this.yPosition,
    required this.speed,
    required this.rotation,
    required this.spawnTime,
    required this.duration,
    required this.word,
  });

  /// 아이템 유형에 따른 아이콘
  IconData get icon {
    switch (type) {
      case PowerUpType.slowTime:
        return Icons.hourglass_bottom;
      case PowerUpType.multiShot:
        return Icons.auto_awesome;
      case PowerUpType.shield:
        return Icons.shield;
      case PowerUpType.extraLife:
        return Icons.favorite;
      case PowerUpType.explosion:
        return Icons.local_fire_department;
    }
  }

  /// 아이템 유형에 따른 색상
  Color get color {
    switch (type) {
      case PowerUpType.slowTime:
        return Colors.lightBlue;
      case PowerUpType.multiShot:
        return Colors.purple;
      case PowerUpType.shield:
        return Colors.blue;
      case PowerUpType.extraLife:
        return Colors.red;
      case PowerUpType.explosion:
        return Colors.orange;
    }
  }

  /// 아이템 유형에 따른 설명
  String get description {
    switch (type) {
      case PowerUpType.slowTime:
        return '적들의 속도를 $duration초 동안 50% 감소시킵니다.';
      case PowerUpType.multiShot:
        return '$duration초 동안 자동으로 무작위 적을 공격합니다.';
      case PowerUpType.shield:
        return '$duration초 동안 피해를 방어합니다.';
      case PowerUpType.extraLife:
        return '생명력을 1 회복합니다.';
      case PowerUpType.explosion:
        return '화면 내 모든 적을 즉시 파괴합니다.';
    }
  }

  /// 아이템 유형에 따른 표시 이름
  String get displayName {
    switch (type) {
      case PowerUpType.slowTime:
        return '시간 감속';
      case PowerUpType.multiShot:
        return '다중 공격';
      case PowerUpType.shield:
        return '보호막';
      case PowerUpType.extraLife:
        return '생명력 회복';
      case PowerUpType.explosion:
        return '대폭발';
    }
  }
}
