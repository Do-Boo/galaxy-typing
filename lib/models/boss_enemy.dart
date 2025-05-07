// 우주 디펜스 게임 보스 모델
// 작성: 2024-06-05
// 특정 웨이브마다 등장하는 보스 적을 정의하는 모델

import 'package:flutter/material.dart';

/// 보스 유형
enum BossType {
  /// 파괴자 - 속도가 느리지만 생명력이 강한 보스
  destroyer,

  /// 분열자 - 파괴되면 여러 개의 적으로 분열되는 보스
  splitter,

  /// 소환자 - 주기적으로 일반 적을 소환하는 보스
  summoner,
}

/// 보스 적 클래스
class BossEnemy {
  /// 보스 유형
  final BossType type;

  /// 화면상의 X 위치 (0.0 ~ 1.0)
  double xPosition;

  /// 화면상의 Y 위치 (0.0 ~ 1.0)
  double yPosition;

  /// 보스 이동 속도
  final double speed;

  /// 보스 회전 각도
  final double rotation;

  /// 보스 생성 시간
  final DateTime spawnTime;

  /// 보스에 할당된 단어들 (여러 단어를 입력해야 파괴됨)
  final List<String> words;

  /// 현재 타겟팅된 단어 인덱스
  int currentWordIndex = 0;

  /// 보스 생명력 (남은 단어 수와 별개로 직접적인 체력)
  int health;

  /// 보스 최대 생명력 (UI 표시용)
  final int maxHealth;

  /// 보스 크기 배율 (일반 적 대비)
  final double scale;

  /// 보스 특수 능력 사용 간격 (밀리초)
  final int specialAbilityInterval;

  /// 마지막 특수 능력 사용 시간
  DateTime lastSpecialAbilityTime = DateTime.now();

  /// 보스 특수 능력이 활성화되었는지 여부
  bool isSpecialAbilityActive = false;

  /// 보스 생성자
  BossEnemy({
    required this.type,
    required this.xPosition,
    required this.yPosition,
    required this.speed,
    required this.rotation,
    required this.spawnTime,
    required this.words,
    required this.health,
    required this.scale,
    required this.specialAbilityInterval,
  }) : maxHealth = health;

  /// 현재 타겟팅된 단어
  String get currentWord => words[currentWordIndex];

  /// 남은 단어 수
  int get remainingWords => words.length - currentWordIndex;

  /// 보스 진행률 (파괴까지) (0.0 ~ 1.0)
  double get progressPercentage => currentWordIndex / words.length;

  /// 체력 진행률 (0.0 ~ 1.0)
  double get healthPercentage => health / maxHealth;

  /// 특수 능력을 사용할 수 있는지 여부
  bool canUseSpecialAbility() {
    return DateTime.now().difference(lastSpecialAbilityTime).inMilliseconds >=
        specialAbilityInterval;
  }

  /// 특수 능력 사용 시간 업데이트
  void updateSpecialAbilityTime() {
    lastSpecialAbilityTime = DateTime.now();
  }

  /// 보스 유형에 따른 색상
  Color get color {
    switch (type) {
      case BossType.destroyer:
        return Colors.red.shade700;
      case BossType.splitter:
        return Colors.purple.shade700;
      case BossType.summoner:
        return Colors.orange.shade700;
    }
  }

  /// 보스 유형에 따른 제목
  String get title {
    switch (type) {
      case BossType.destroyer:
        return '파괴자';
      case BossType.splitter:
        return '분열자';
      case BossType.summoner:
        return '소환자';
    }
  }

  /// 보스 유형에 따른 아이콘
  IconData get icon {
    switch (type) {
      case BossType.destroyer:
        return Icons.local_fire_department;
      case BossType.splitter:
        return Icons.copy_all;
      case BossType.summoner:
        return Icons.group_add;
    }
  }

  /// 보스 유형에 따른 설명
  String get description {
    switch (type) {
      case BossType.destroyer:
        return '강력한 장갑으로 여러 번 타격을 입어도 파괴되지 않습니다.';
      case BossType.splitter:
        return '파괴되면 여러 개의 작은 적으로 분열됩니다.';
      case BossType.summoner:
        return '주기적으로 일반 적을 소환합니다.';
    }
  }
}
