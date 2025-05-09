// 우주 디펜스 게임 총알 모델
// 작성: 2024-06-15
// 화면에 표시되는 총알 객체를 정의하는 모델

/// 총알 클래스
class GameBulletModel {
  /// 시작 X 위치 (0.0 ~ 1.0)
  final double startX;

  /// 시작 Y 위치 (0.0 ~ 1.0)
  final double startY;

  /// 목표 X 위치 (0.0 ~ 1.0)
  final double targetX;

  /// 목표 Y 위치 (0.0 ~ 1.0)
  final double targetY;

  /// 이동 속도
  final double speed;

  /// 총알 생성 시간
  final DateTime startTime;

  /// 적의 총알인지 여부
  final bool isEnemyBullet;

  /// 총알 크기
  final double size;

  /// 총알 생성자
  GameBulletModel({
    required this.startX,
    required this.startY,
    required this.targetX,
    required this.targetY,
    required this.speed,
    required this.startTime,
    this.isEnemyBullet = false, // 기본값은 플레이어 총알
    this.size = 10.0, // 기본 사이즈
  });
}
