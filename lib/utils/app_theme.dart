// 앱의 테마와 색상 상수를 정의하는 파일
// 작성: 2023-05-10
// 테마, 색상, 텍스트 스타일 등의 중앙 집중식 관리를 위한 파일

import 'package:flutter/material.dart';
// Google Fonts 패키지 사용 안 함
// import 'package:google_fonts/google_fonts.dart';

/// 앱 전체에서 사용되는 색상 상수
class AppColors {
  // 주요 색상
  static const primary = Color(0xFF4CC9F0);
  static const primaryLight = Color(0xFF7FDBF5);
  static const primaryDark = Color(0xFF31A3C7);

  // 보조 색상
  static const secondary = Color(0xFF7B2CBF);
  static const secondaryLight = Color(0xFF9D4EDA);
  static const secondaryDark = Color(0xFF5A1B8F);

  // 강조 색상
  static const accent = Color(0xFFF72585);

  // 배경 색상
  static const background = Color(0xFF0A0E21);
  static const backgroundLighter = Color(0xFF1D1E33);
  static const backgroundDarker = Color(0xFF070B17); // 더 어두운 배경 색상 추가
  static const cardBg = Color(0x730A0A25); // 70% 투명도

  // 텍스트 색상
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF); // 70% 흰색
  static const textMuted = Color(0x80FFFFFF); // 50% 흰색

  // 테두리 색상
  static const borderColor = Color(0x334CC9F0); // 20% primary
  static const borderColorHover = Color(0x664CC9F0); // 40% primary

  // 상태 색상
  static const success = Color(0xFF50FA7B);
  static const error = Color(0xFFFF5555);
  static const warning = Color(0xFFFFBD4A);
  static const info = Color(0xFF8BE9FD);
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

  // 버튼 텍스트 스타일
  static TextStyle buttonTextStyle(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Rajdhani',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
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

/// 앱 전체에서 사용되는 테마 데이터
class AppTheme {
  // 라이트 테마 (현재 사용하지 않음)
  static ThemeData lightTheme() {
    return ThemeData(
      // 기본 설정
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Rajdhani',

      // 텍스트 테마
      textTheme: const TextTheme().copyWith(
          // 이곳에 필요한 텍스트 스타일 정의
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

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
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
        fillColor: AppColors.backgroundLighter.withOpacity(0.5),
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
            width: 1.5,
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
    );
  }

  // 다크 테마 (기본 테마)
  static ThemeData darkTheme() {
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
      ),

      // 나머지 설정은 라이트 테마와 동일
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

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
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

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLighter.withOpacity(0.5),
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
            width: 1.5,
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
    );
  }
}

// 화면 크기에 따른 스타일 조정을 위한 유틸리티 함수
bool _isTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.shortestSide >= 600;
}
