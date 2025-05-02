// 반응형 레이아웃을 위한 헬퍼 유틸리티
// 작성: 2024-06-07
// 다양한 화면 크기에 따라 레이아웃을 조정하는 유틸리티 함수 모음

import 'package:flutter/material.dart';

/// 다양한 디바이스 크기에 따른 반응형 UI를 위한 헬퍼 클래스
class ResponsiveHelper {
  /// 화면 너비에 따른 디바이스 타입 구분 기준점
  static const mobileBreakpoint = 600;
  static const tabletBreakpoint = 1200;

  /// 디바이스가 모바일 크기인지 확인 (600dp 미만)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// 디바이스가 태블릿 크기인지 확인 (600dp 이상, 900dp 미만)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// 디바이스가 데스크톱 크기인지 확인 (900dp 이상)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// 현재 화면 크기에 따른 패딩 값 반환
  static EdgeInsets screenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    }
  }

  /// 화면 크기에 따른 폰트 크기 계수 반환
  static double fontScaleFactor(BuildContext context) {
    if (isMobile(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.15;
    } else {
      return 1.3;
    }
  }

  /// 현재 화면 크기에 기반한 최대 콘텐츠 너비 계산
  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (isDesktop(context)) {
      // 데스크톱에서는 콘텐츠 너비 제한
      return 1200.0;
    } else {
      // 모바일과 태블릿에서는 화면 전체 사용 (패딩 고려)
      return width;
    }
  }

  /// 화면 크기에 따른 그리드 열 개수 반환
  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 3; // 데스크톱은 3열
    } else if (isTablet(context)) {
      return 2; // 태블릿은 2열
    } else {
      return 1; // 모바일은 1열
    }
  }

  /// 콘텐츠를 화면 중앙에 배치하는 래퍼 위젯
  static Widget centeredContent({
    required BuildContext context,
    required Widget child,
    double maxWidth = 1200,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: child,
      ),
    );
  }

  /// 반응형 위젯 선택
  /// 화면 크기에 따라 다른 위젯을 반환
  static Widget responsive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// 화면 너비에 맞게 폰트 크기 조정
  static double responsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// 화면 크기에 따른 마진 조정
  static double responsiveMargin(BuildContext context) {
    if (isDesktop(context)) {
      return 24.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 12.0;
    }
  }

  /// 수평/수직 공간 적용을 위한 헬퍼 함수
  static Widget verticalSpace(BuildContext context, {bool small = false}) {
    final factor = small ? 0.5 : 1.0;
    if (isDesktop(context)) {
      return SizedBox(height: 24.0 * factor);
    } else if (isTablet(context)) {
      return SizedBox(height: 16.0 * factor);
    } else {
      return SizedBox(height: 12.0 * factor);
    }
  }

  static Widget horizontalSpace(BuildContext context, {bool small = false}) {
    final factor = small ? 0.5 : 1.0;
    if (isDesktop(context)) {
      return SizedBox(width: 24.0 * factor);
    } else if (isTablet(context)) {
      return SizedBox(width: 16.0 * factor);
    } else {
      return SizedBox(width: 12.0 * factor);
    }
  }
}
