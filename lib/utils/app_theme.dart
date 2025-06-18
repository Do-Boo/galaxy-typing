// 앱의 테마와 색상 상수를 정의하는 파일
// 작성: 2023-05-10
// 업데이트: 2025-06-18 (다크/라이트 모드 제거, 단일 우주 테마 적용)
// 테마, 색상, 텍스트 스타일 등의 중앙 집중식 관리를 위한 파일

import 'package:flutter/material.dart';
// Google Fonts 패키지 사용 안 함
// import 'package:google_fonts/google_fonts.dart';

/// 앱 전체에서 사용되는 색상 상수
class AppColors {
  // 주요 색상 (더 밝고 대비가 좋은 색상으로 조정)
  static const primary = Color(0xFF00D4FF); // 더 밝은 시안
  static const primaryLight = Color(0xFF66E0FF);
  static const primaryDark = Color(0xFF0099CC);

  // 보조 색상 (더 밝고 선명한 색상)
  static const secondary = Color(0xFF9C4DFF); // 더 밝은 보라
  static const secondaryLight = Color(0xFFB366FF);
  static const secondaryDark = Color(0xFF7B2CBF);

  // 강조 색상
  static const accent = Color(0xFFFF4081); // 더 밝은 핑크

  // 배경 색상 (우주 테마 유지)
  static const background = Color(0xFF0A0E21);
  static const backgroundLighter = Color(0xFF1D1E33);
  static const backgroundDarker = Color(0xFF070B17);
  static const cardBg = Color(0xFF1D1E33); // 투명도 제거하여 더 명확한 배경

  // 텍스트 색상 (대비 개선)
  static const textPrimary = Color(0xFFFFFFFF); // 순백색
  static const textSecondary = Color(0xFFE0E0E0); // 더 밝은 회색
  static const textMuted = Color(0xFFB0B0B0); // 더 밝은 회색

  // 테두리 색상 (적절한 가시성과 조화를 위한 중간 톤)
  static const borderColor = Color(0xFF3A4A5C); // 적당히 보이는 어두운 푸른 회색
  static const borderColorHover = Color(0xFF4A5A6C); // 호버 시 더 밝게

  // 상태 색상 (더 밝고 명확한 색상)
  static const success = Color(0xFF4CAF50); // 표준 녹색
  static const error = Color(0xFFF44336); // 표준 빨간색
  static const warning = Color(0xFFFF9800); // 표준 주황색
  static const info = Color(0xFF2196F3); // 표준 파란색

  // 버튼 색상 (대비 개선)
  static const buttonPrimaryBg = primary;
  static const buttonPrimaryText = Color(0xFF000000); // 검은색 텍스트로 대비 개선
  static const buttonSecondaryBg = secondary;
  static const buttonSecondaryText = Color(0xFFFFFFFF); // 흰색 텍스트
  static const buttonOutlineBg = Colors.transparent;
  static const buttonOutlineText = primary;
  static const buttonOutlineBorder = Color(0xFF4A5A6C); // 적당히 보이는 테두리 색상
}

/// 앱 전체에서 사용되는 텍스트 스타일
class AppTextStyles {
  // 로고 스타일 (PressStart2P 폰트 사용)
  static TextStyle logoStyle(BuildContext context) {
    return const TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: 24,
      letterSpacing: -0.5,
      color: AppColors.textPrimary,
      height: 1.2,
    );
  }

  // 제목 텍스트 스타일
  static TextStyle titleLarge(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.25,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle titleSmall(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: AppColors.textPrimary,
    );
  }

  // 본문 텍스트 스타일
  static TextStyle bodyLarge(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.25,
      color: AppColors.textSecondary,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
      color: AppColors.textSecondary,
    );
  }

  // 버튼 텍스트 스타일 (대비 개선)
  static TextStyle buttonTextStyle(BuildContext context, {Color? color}) {
    return TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: color ?? AppColors.textPrimary,
    );
  }

  // 라벨 텍스트 스타일
  static TextStyle labelLarge(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle labelMedium(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColors.textSecondary,
    );
  }

  static TextStyle labelSmall(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColors.textSecondary,
    );
  }

  // 부제목 스타일
  static TextStyle subtitleStyle(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.5,
      color: AppColors.textSecondary,
    );
  }
}

/// 앱 전체에서 사용되는 테마 데이터 (단일 우주 테마)
class AppTheme {
  // 단일 우주 테마
  static ThemeData cosmicTheme() {
    return ThemeData(
      // 기본 설정
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Rajdhani',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.backgroundLighter,
        onPrimary: AppColors.buttonPrimaryText,
        onSecondary: AppColors.buttonSecondaryText,
        onSurface: AppColors.textPrimary,
      ),

      // 앱바 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Rajdhani',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
        ),
      ),

      // 버튼 테마 (대비 개선)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimaryBg,
          foregroundColor: AppColors.buttonPrimaryText,
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),

      // 아웃라인 버튼 테마
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.buttonOutlineBg,
          foregroundColor: AppColors.buttonOutlineText,
          side: const BorderSide(
            color: AppColors.buttonOutlineBorder,
            width: 2,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // 텍스트 버튼 테마
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 카드 테마
      cardTheme: CardTheme(
        color: AppColors.cardBg,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
      ),

      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLighter.withOpacity(0.8),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Rajdhani',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontFamily: 'Rajdhani',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // 스낵바 테마
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.backgroundLighter,
        contentTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Rajdhani',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppColors.primary,
      ),

      // 다이얼로그 테마
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.backgroundLighter,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'Rajdhani',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Rajdhani',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // 체크박스 테마
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.buttonPrimaryText),
        side: const BorderSide(color: AppColors.borderColor, width: 2),
      ),

      // 라디오 버튼 테마
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
      ),

      // 스위치 테마
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.5);
          }
          return AppColors.textMuted.withOpacity(0.3);
        }),
      ),

      // 슬라이더 테마
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.textMuted.withOpacity(0.3),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: const TextStyle(
          color: AppColors.buttonPrimaryText,
          fontFamily: 'Rajdhani',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// 화면 크기에 따른 스타일 조정을 위한 유틸리티 함수
bool _isTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.shortestSide >= 600;
}
