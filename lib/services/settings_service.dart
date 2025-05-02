// 사용자 게임 설정을 관리하는 서비스
// 작성: 2023-05-10
// 게임 설정을 로드, 저장 및 업데이트하는 기능 제공

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_settings.dart';

class SettingsService {
  static const String _settingsKey = 'game_settings';
  GameSettings? _cachedSettings;

  // 설정 불러오기
  Future<GameSettings> loadSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        _cachedSettings = GameSettings.fromJson(json.decode(settingsJson));
        return _cachedSettings!;
      }
    } catch (e) {
      print('설정 로드 오류: $e');
    }

    // 기본 설정 반환 (저장된 설정이 없거나 오류 발생 시)
    _cachedSettings = GameSettings.defaults;
    return _cachedSettings!;
  }

  // 설정 저장
  Future<bool> saveSettings(GameSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(settings.toJson());

      final success = await prefs.setString(_settingsKey, settingsJson);
      if (success) {
        _cachedSettings = settings;
      }
      return success;
    } catch (e) {
      print('설정 저장 오류: $e');
      return false;
    }
  }

  // 난이도 변경
  Future<bool> setDifficulty(DifficultyLevel difficulty) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(difficulty: difficulty);
      return await saveSettings(updatedSettings);
    } catch (e) {
      print('난이도 설정 오류: $e');
      return false;
    }
  }

  // 사운드 효과 레벨 변경
  Future<bool> setSoundEffectsLevel(SoundEffectLevel level) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(soundEffects: level);
      return await saveSettings(updatedSettings);
    } catch (e) {
      print('사운드 효과 설정 오류: $e');
      return false;
    }
  }

  // 음악 볼륨 변경
  Future<bool> setMusicVolume(double volume) async {
    try {
      // 유효한 볼륨 범위 확인 (0.0 ~ 1.0)
      final validVolume = volume.clamp(0.0, 1.0);

      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(
        musicVolume: validVolume,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      print('음악 볼륨 설정 오류: $e');
      return false;
    }
  }

  // 진동 피드백 설정 변경
  Future<bool> setHapticFeedback(bool enabled) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(hapticFeedback: enabled);
      return await saveSettings(updatedSettings);
    } catch (e) {
      print('진동 피드백 설정 오류: $e');
      return false;
    }
  }

  // 테마 변경
  Future<bool> setTheme(GameTheme theme) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(theme: theme);
      return await saveSettings(updatedSettings);
    } catch (e) {
      print('테마 설정 오류: $e');
      return false;
    }
  }

  // 사용자 이름 변경
  Future<bool> setUsername(String username) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(username: username);
      return await saveSettings(updatedSettings);
    } catch (e) {
      print('사용자 이름 설정 오류: $e');
      return false;
    }
  }

  // 커스텀 단어 세트 업데이트
  Future<bool> updateCustomWordSets(List<String> wordSets) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(
        customWordSets: wordSets,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      print('커스텀 단어 세트 업데이트 오류: $e');
      return false;
    }
  }

  // 접근성 모드 설정 변경
  Future<bool> setAccessibilityMode(bool enabled) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(
        accessibilityMode: enabled,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      print('접근성 모드 설정 오류: $e');
      return false;
    }
  }

  // 고대비 모드 설정 변경
  Future<bool> setHighContrastMode(bool enabled) async {
    try {
      final currentSettings = await loadSettings();
      final updatedSettings = currentSettings.copyWith(
        highContrastMode: enabled,
      );
      return await saveSettings(updatedSettings);
    } catch (e) {
      print('고대비 모드 설정 오류: $e');
      return false;
    }
  }

  // 설정 초기화 (앱 초기화용)
  Future<bool> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_settingsKey);

      if (success) {
        _cachedSettings = GameSettings.defaults;
      }

      return success;
    } catch (e) {
      print('설정 초기화 오류: $e');
      return false;
    }
  }
}
