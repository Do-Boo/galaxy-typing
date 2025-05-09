// 우주 디펜스 게임 폭발 효과 모델
// 작성: 2024-06-15
// 화면에 표시되는 폭발 효과 객체를 정의하는 모델

/// 폭발 효과 클래스
class GameExplosionModel {
  /// X 위치 (0.0 ~ 1.0)
  final double xPosition;

  /// Y 위치 (0.0 ~ 1.0)
  final double yPosition;

  /// 폭발 크기
  final double size;

  /// 폭발 시작 시간
  final DateTime startTime;

  /// 폭발 효과 생성자
  GameExplosionModel({
    required this.xPosition,
    required this.yPosition,
    required this.size,
    required this.startTime,
  });
}
