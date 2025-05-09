// 다국어 지원 유틸리티
// 작성: 2024-06-10
// 업데이트: 2024-06-20 (미저장 변경사항 및 한영 혼합 관련 번역 추가)
// 앱의 텍스트를 다국어로 표시하기 위한 유틸리티

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../models/game_settings.dart';

/// 앱의 다국어 지원을 위한 로컬라이제이션 유틸리티
class AppLocalizations {
  // 지원하는 언어 코드
  static const String kLanguageKorean = 'ko';
  static const String kLanguageEnglish = 'en';
  static const String kLanguageMixed = 'ko_en';

  // 모든 번역 데이터
  static final Map<String, Map<String, String>> _localizedValues = {
    kLanguageKorean: {
      // 공통
      'app_name': 'Cosmic Typer',
      'app_subtitle': '우주를 누비는 타자 연습',

      // 설정 관련 알림
      'settings_auto_saved': '설정이 자동으로 저장되었습니다',
      'settings_saved': '설정이 저장되었습니다',
      'unsaved_changes_title': '저장되지 않은 변경사항',
      'unsaved_changes_message': '변경사항이 저장되지 않았습니다. 저장하지 않고 나가시겠습니까?',
      'proceed': '나가기',

      // 메인 화면
      'my_typing_status': '내 타이핑 현황',
      'accuracy': '정확도',
      'speed': '속도',
      'sessions': '세션 수',
      'view_all': '전체보기',
      'game_modes': '게임 모드',
      'basic_practice': '기본 연습',
      'time_challenge': '시간 도전',
      'space_defense': '우주 디펜스',
      'settings': '설정',
      'stats': '통계',

      // 설정 화면
      'game_settings': '게임 설정',
      'difficulty': '난이도',
      'timer_seconds': '타이머 (초)',
      'app_settings': '앱 설정',
      'theme': '테마',
      'sound_effects': '효과음',
      'background_music': '배경 음악',
      'accessibility': '접근성',
      'high_contrast': '고대비 모드',
      'language': '언어 설정',
      'font_size': '글꼴 크기',
      'save': '저장',
      'reset_defaults': '기본값으로 재설정',
      'reset_confirm_title': '설정 초기화',
      'reset_confirm_message': '모든 설정을 기본값으로 되돌리시겠습니까?',
      'reset': '초기화',
      'cancel': '취소',
      'reset_success': '설정이 기본값으로 재설정되었습니다',

      // 타자연습 언어 설정
      'typing_language': '타자연습 언어',
      'korean_typing': '한글 타자연습',
      'english_typing': '영문 타자연습',
      'mixed_typing': '한영 혼합 타자연습',

      // 난이도
      'easy': '쉬움',
      'medium': '보통',
      'hard': '어려움',

      // 테마
      'light': '라이트',
      'dark': '다크',

      // 글꼴 크기
      'small': '작게',
      'large': '크게',

      // 게임 화면
      'score': '점수',
      'lives': '생명',
      'level': '레벨',
      'wave': '웨이브',
      'time': '시간',
      'pause': '일시정지',
      'resume': '계속하기',
      'game_over': '게임 오버',
      'try_again': '다시 시도',
      'back_to_menu': '메뉴로',
    },
    kLanguageEnglish: {
      // 공통
      'app_name': 'Cosmic Typer',
      'app_subtitle': 'Space-themed Typing Practice',

      // 설정 관련 알림
      'settings_auto_saved': 'Settings automatically saved',
      'settings_saved': 'Settings saved',
      'unsaved_changes_title': 'Unsaved Changes',
      'unsaved_changes_message':
          'You have unsaved changes. Are you sure you want to leave without saving?',
      'proceed': 'Leave',

      // 메인 화면
      'my_typing_status': 'My Typing Stats',
      'accuracy': 'Accuracy',
      'speed': 'Speed',
      'sessions': 'Sessions',
      'view_all': 'View All',
      'game_modes': 'Game Modes',
      'basic_practice': 'Basic Practice',
      'time_challenge': 'Time Challenge',
      'space_defense': 'Space Defense',
      'settings': 'Settings',
      'stats': 'Statistics',

      // 설정 화면
      'game_settings': 'Game Settings',
      'difficulty': 'Difficulty',
      'timer_seconds': 'Timer (sec)',
      'app_settings': 'App Settings',
      'theme': 'Theme',
      'sound_effects': 'Sound Effects',
      'background_music': 'Background Music',
      'accessibility': 'Accessibility',
      'high_contrast': 'High Contrast Mode',
      'language': 'Language',
      'font_size': 'Font Size',
      'save': 'Save',
      'reset_defaults': 'Reset to Defaults',
      'reset_confirm_title': 'Reset Settings',
      'reset_confirm_message':
          'Are you sure you want to reset all settings to default values?',
      'reset': 'Reset',
      'cancel': 'Cancel',
      'reset_success': 'Settings have been reset to defaults',

      // 타자연습 언어 설정
      'typing_language': 'Typing Language',
      'korean_typing': 'Korean Typing Practice',
      'english_typing': 'English Typing Practice',
      'mixed_typing': 'Mixed Typing Practice',

      // 난이도
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',

      // 테마
      'light': 'Light',
      'dark': 'Dark',

      // 글꼴 크기
      'small': 'Small',
      'large': 'Large',

      // 게임 화면
      'score': 'Score',
      'lives': 'Lives',
      'level': 'Level',
      'wave': 'Wave',
      'time': 'Time',
      'pause': 'Pause',
      'resume': 'Resume',
      'game_over': 'Game Over',
      'try_again': 'Try Again',
      'back_to_menu': 'Back to Menu',
    },
  };

  /// 현재 언어 설정에 따른 번역된 텍스트 가져오기
  static String get(BuildContext context, String key) {
    // 설정에서 현재 언어 가져오기
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);

    String locale;
    switch (settingsController.language) {
      case LanguageOption.korean:
        locale = kLanguageKorean;
        break;
      case LanguageOption.english:
        locale = kLanguageEnglish;
        break;
      case LanguageOption.mixedKoreanEnglish:
        // 한영 혼합 모드에서는 기본적으로 한국어 사용
        locale = kLanguageKorean;
        break;
      default:
        locale = kLanguageKorean;
    }

    // 해당 키의 번역 반환 (없으면 키 그대로 반환)
    final translation = _localizedValues[locale]?[key];
    if (translation == null && kDebugMode) {
      print('Missing translation for key: $key in $locale');
    }
    return translation ?? key;
  }

  /// 언어 코드에 따른 번역된 텍스트 가져오기 (컨텍스트 없이 사용 가능)
  static String getWithLanguage(String key, LanguageOption language) {
    String locale;
    switch (language) {
      case LanguageOption.korean:
        locale = kLanguageKorean;
        break;
      case LanguageOption.english:
        locale = kLanguageEnglish;
        break;
      case LanguageOption.mixedKoreanEnglish:
        // 한영 혼합 모드에서는 기본적으로 한국어 사용
        locale = kLanguageKorean;
        break;
      default:
        locale = kLanguageKorean;
    }

    return _localizedValues[locale]?[key] ?? key;
  }

  /// 키가 정의되어 있는지 확인
  static bool hasKey(String key, LanguageOption language) {
    String locale;
    switch (language) {
      case LanguageOption.korean:
        locale = kLanguageKorean;
        break;
      case LanguageOption.english:
        locale = kLanguageEnglish;
        break;
      case LanguageOption.mixedKoreanEnglish:
        locale = kLanguageKorean;
        break;
      default:
        locale = kLanguageKorean;
    }

    return _localizedValues[locale]?.containsKey(key) ?? false;
  }
}

// 편의성을 위한 확장 메서드 - 컨텍스트에서 번역 호출 가능
extension LocalizationExtension on BuildContext {
  /// 번역된 텍스트 가져오기 (context.tr('key'))
  String tr(String key) {
    return AppLocalizations.get(this, key);
  }
}
