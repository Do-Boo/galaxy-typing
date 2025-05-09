// 우주 디펜스 게임 적 모델
// 작성: 2024-06-15
// 화면에 표시되는 적 (단어) 객체를 정의하는 모델

/// 적 (단어) 클래스
class EnemyWordModel {
  /// 표시되는 단어
  final String word;

  /// 화면상의 X 위치 (0.0 ~ 1.0)
  double xPosition;

  /// 화면상의 Y 위치 (0.0 ~ 1.0)
  double yPosition;

  /// 이동 속도 (픽셀/초)
  final double speed;

  /// 회전 각도
  final double rotation;

  /// 적 생성자
  EnemyWordModel({
    required this.word,
    required this.xPosition,
    required this.yPosition,
    required this.speed,
    required this.rotation,
  });
}
