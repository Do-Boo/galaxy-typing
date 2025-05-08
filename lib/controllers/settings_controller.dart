// 설정 컨트롤러
// 작성: 2024-05-15
// 업데이트: 2024-06-02 (다국어 지원 추가)
// 업데이트: 2024-06-10 (설정 적용 및 저장 로직 개선)
// 업데이트: 2024-06-12 (디버깅 도구 추가)
// 앱 설정을 관리하는 컨트롤러

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_settings.dart';
import '../services/audio_service.dart';

/// 앱의 모든 설정을 관리하는 컨트롤러
class SettingsController with ChangeNotifier {
  // 싱글톤 인스턴스
  static SettingsController? _instance;

  // SharedPreferences 인스턴스
  late SharedPreferences _prefs;

  // 오디오 서비스
  final AudioService _audioService = AudioService();

  // 설정 키 값들
  static const String _keyMusicVolume = 'music_volume';
  static const String _keySoundEffectsVolume = 'sound_effects_volume';
  static const String _keyTypingSoundEnabled = 'typing_sound_enabled';
  static const String _keyParticleEffectsEnabled = 'particle_effects_enabled';
  static const String _keyTypingEffectsEnabled = 'typing_effects_enabled';
  static const String _keyFontSize = 'font_size';
  static const String _keyDifficulty = 'difficulty';
  static const String _keyTimeChallengeDuration = 'time_challenge_duration';
  static const String _keyDarkThemeEnabled = 'dark_theme_enabled';
  static const String _keyHighContrastMode = 'high_contrast_mode';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keySoundVolume = 'sound_volume';
  static const String _keyLanguage = 'language';
  static const String _keyTimerDuration = 'timer_duration';

  // 설정 값들
  double _musicVolume = 0.5;
  double _soundEffectsVolume = 0.7;
  bool _typingSoundEnabled = true;
  bool _particleEffectsEnabled = true;
  bool _typingEffectsEnabled = true;
  double _fontSize = 1.0;
  DifficultyLevel _difficulty = DifficultyLevel.medium;
  int _timeChallengeDuration = 60;
  bool _darkThemeEnabled = true;
  bool _highContrastMode = false;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  int _timerDuration = 60; // 기본 타이머 시간 (초)
  LanguageOption _language = LanguageOption.korean; // 기본 언어: 한국어

  // 생성자 (private)
  SettingsController._create();

  // 팩토리 생성자
  factory SettingsController() {
    _instance ??= SettingsController._create();
    return _instance!;
  }

  // 초기화 메서드
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();

    // 설정 변경 시 자동 저장 리스너 추가
    addListener(() {
      _saveSettingsAsync();
      _updateAudioSettings();
    });
  }

  // 오디오 설정 업데이트
  void _updateAudioSettings() {
    // 음향 전역 활성화/비활성화 설정
    _audioService.setAudioEnabled(_soundEnabled);

    // 현재 설정에 따라 오디오 서비스 업데이트
    if (_musicEnabled) {
      _audioService.setMusicVolume(_musicVolume);
    } else {
      // 음악 비활성화 시 음악 중지
      _audioService.stop();
    }

    // 효과음 볼륨 설정
    _audioService.setSoundVolume(_soundEffectsVolume);
  }

  // 설정 로드
  void _loadSettings() {
    _musicVolume = _prefs.getDouble(_keyMusicVolume) ?? 0.5;
    _soundEffectsVolume = _prefs.getDouble(_keySoundEffectsVolume) ?? 0.7;
    _typingSoundEnabled = _prefs.getBool(_keyTypingSoundEnabled) ?? true;
    _particleEffectsEnabled =
        _prefs.getBool(_keyParticleEffectsEnabled) ?? true;
    _typingEffectsEnabled = _prefs.getBool(_keyTypingEffectsEnabled) ?? true;
    _fontSize = _prefs.getDouble(_keyFontSize) ?? 1.0;
    _darkThemeEnabled = _prefs.getBool(_keyDarkThemeEnabled) ?? true;
    _highContrastMode = _prefs.getBool(_keyHighContrastMode) ?? false;
    _soundEnabled = _prefs.getBool(_keySoundEnabled) ?? true;
    _musicEnabled = _prefs.getBool(_keyMusicEnabled) ?? true;
    _soundEffectsVolume = _prefs.getDouble(_keySoundVolume) ?? 0.7;

    // 열거형 값 로드
    final difficultyIndex = _prefs.getInt(_keyDifficulty) ?? 1;
    _difficulty = DifficultyLevel.values[difficultyIndex];

    final languageIndex = _prefs.getInt(_keyLanguage) ?? 0;
    _language = LanguageOption.values[languageIndex];

    _timeChallengeDuration = _prefs.getInt(_keyTimeChallengeDuration) ?? 60;
    _timerDuration = _prefs.getInt(_keyTimerDuration) ?? 60;

    notifyListeners();
  }

  // 설정 저장 (비동기 호출용)
  void _saveSettingsAsync() {
    // 백그라운드에서 저장
    _saveSettings();
  }

  // 설정 저장
  Future<void> _saveSettings() async {
    await _prefs.setDouble(_keyMusicVolume, _musicVolume);
    await _prefs.setDouble(_keySoundEffectsVolume, _soundEffectsVolume);
    await _prefs.setBool(_keyTypingSoundEnabled, _typingSoundEnabled);
    await _prefs.setBool(_keyParticleEffectsEnabled, _particleEffectsEnabled);
    await _prefs.setBool(_keyTypingEffectsEnabled, _typingEffectsEnabled);
    await _prefs.setDouble(_keyFontSize, _fontSize);
    await _prefs.setInt(_keyDifficulty, _difficulty.index);
    await _prefs.setInt(_keyTimeChallengeDuration, _timeChallengeDuration);
    await _prefs.setBool(_keyDarkThemeEnabled, _darkThemeEnabled);
    await _prefs.setBool(_keyHighContrastMode, _highContrastMode);
    await _prefs.setBool(_keySoundEnabled, _soundEnabled);
    await _prefs.setBool(_keyMusicEnabled, _musicEnabled);
    await _prefs.setDouble(_keySoundVolume, _soundEffectsVolume);
    await _prefs.setInt(_keyLanguage, _language.index);
    await _prefs.setInt(_keyTimerDuration, _timerDuration);
  }

  // 기본값으로 재설정
  Future<void> resetToDefaults() async {
    _musicVolume = 0.5;
    _soundEffectsVolume = 0.7;
    _typingSoundEnabled = true;
    _particleEffectsEnabled = true;
    _typingEffectsEnabled = true;
    _fontSize = 1.0;
    _difficulty = DifficultyLevel.medium;
    _timeChallengeDuration = 60;
    _timerDuration = 60;
    _darkThemeEnabled = true;
    _highContrastMode = false;
    _soundEnabled = true;
    _musicEnabled = true;
    _language = LanguageOption.korean;

    await _saveSettings();
    notifyListeners();
  }

  // 통계 삭제 기능 (StatsController와 연동 필요)
  Future<void> clearAllStats() async {
    // TODO: StatsController 연동 필요
    // 예: await StatsController().clearAllStats();
    notifyListeners();
  }

  // Getters 및 Setters

  double get musicVolume => _musicVolume;
  Future<void> setMusicVolume(double value) async {
    _musicVolume = value;
    await _saveSettings();
    notifyListeners();
  }

  double get soundEffectsVolume => _soundEffectsVolume;
  Future<void> setSoundEffectsVolume(double value) async {
    _soundEffectsVolume = value;
    await _saveSettings();
    notifyListeners();
  }

  bool get typingSoundEnabled => _typingSoundEnabled;
  Future<void> setTypingSoundEnabled(bool value) async {
    _typingSoundEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  bool get particleEffectsEnabled => _particleEffectsEnabled;
  Future<void> setParticleEffectsEnabled(bool value) async {
    _particleEffectsEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  bool get typingEffectsEnabled => _typingEffectsEnabled;
  Future<void> setTypingEffectsEnabled(bool value) async {
    _typingEffectsEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  // [getter/setter] - FontSize
  double get fontSize => _fontSize;
  set fontSize(double size) {
    _fontSize = size;
    _saveSettingsAsync();
    notifyListeners();
  }

  DifficultyLevel get difficulty => _difficulty;
  set difficulty(DifficultyLevel level) {
    _difficulty = level;
    _saveSettingsAsync();
    notifyListeners();
  }

  // [getter/setter] - Language
  LanguageOption get language => _language;
  set language(LanguageOption value) {
    _language = value;
    _saveSettingsAsync();
    notifyListeners();
  }

  int get timeChallengeDuration => _timeChallengeDuration;
  Future<void> setTimeChallengeDuration(int value) async {
    _timeChallengeDuration = value;
    await _saveSettings();
    notifyListeners();
  }

  bool get darkThemeEnabled => _darkThemeEnabled;
  set darkThemeEnabled(bool enabled) {
    _darkThemeEnabled = enabled;
    _saveSettingsAsync();
    notifyListeners();
  }

  bool get highContrastMode => _highContrastMode;
  set highContrastMode(bool value) {
    _highContrastMode = value;
    _saveSettingsAsync();
    notifyListeners();
  }

  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) {
    _soundEnabled = value;
    _saveSettingsAsync();
    notifyListeners();
  }

  bool get musicEnabled => _musicEnabled;
  set musicEnabled(bool value) {
    _musicEnabled = value;
    _updateAudioSettings();
    _saveSettingsAsync();
    notifyListeners();
  }

  double get soundVolume => _soundEffectsVolume;
  set soundVolume(double value) {
    _soundEffectsVolume = value;
    _audioService.setSoundVolume(value);
    _saveSettingsAsync();
    notifyListeners();
  }

  // 테마 모드 가져오기
  ThemeMode get themeMode =>
      _darkThemeEnabled ? ThemeMode.dark : ThemeMode.light;

  // [getter/setter] - TimerDuration
  int get timerDuration => _timerDuration;
  set timerDuration(int seconds) {
    _timerDuration = seconds;
    _saveSettingsAsync();
    notifyListeners();
  }

  // 설정 저장
  Future<void> saveSettings() async {
    await _saveSettings();
    if (kDebugMode) {
      print('설정이 저장되었습니다.');
      printCurrentSettings();
    }
    return Future.delayed(const Duration(milliseconds: 300));
  }

  // 디버깅: 현재 메모리에 있는 설정값 출력
  void printCurrentSettings() {
    if (!kDebugMode) return;

    print('===== 현재 설정값 =====');
    print('언어: $_language');
    print('글꼴 크기: $_fontSize');
    print('다크 테마: $_darkThemeEnabled');
    print('고대비 모드: $_highContrastMode');
    print('배경음악: $_musicEnabled (볼륨: $_musicVolume)');
    print('효과음: $_soundEnabled (볼륨: $_soundEffectsVolume)');
    print('타이핑 소리: $_typingSoundEnabled');
    print('입자 효과: $_particleEffectsEnabled');
    print('타이핑 효과: $_typingEffectsEnabled');
    print('난이도: $_difficulty');
    print('시간 도전 타이머: $_timeChallengeDuration초');
    print('일반 타이머: $_timerDuration초');
    print('=====================');
  }

  // 디버깅: SharedPreferences에 저장된 설정값 출력
  Future<void> printStoredSettings() async {
    if (!kDebugMode) return;

    final prefs = await SharedPreferences.getInstance();

    print('===== 저장된 설정값 =====');
    print('언어: ${prefs.getInt(_keyLanguage)}');
    print('글꼴 크기: ${prefs.getDouble(_keyFontSize)}');
    print('다크 테마: ${prefs.getBool(_keyDarkThemeEnabled)}');
    print('고대비 모드: ${prefs.getBool(_keyHighContrastMode)}');
    print(
        '배경음악: ${prefs.getBool(_keyMusicEnabled)} (볼륨: ${prefs.getDouble(_keyMusicVolume)})');
    print(
        '효과음: ${prefs.getBool(_keySoundEnabled)} (볼륨: ${prefs.getDouble(_keySoundVolume)})');
    print('타이핑 소리: ${prefs.getBool(_keyTypingSoundEnabled)}');
    print('입자 효과: ${prefs.getBool(_keyParticleEffectsEnabled)}');
    print('타이핑 효과: ${prefs.getBool(_keyTypingEffectsEnabled)}');
    print('난이도: ${prefs.getInt(_keyDifficulty)}');
    print('시간 도전 타이머: ${prefs.getInt(_keyTimeChallengeDuration)}초');
    print('일반 타이머: ${prefs.getInt(_keyTimerDuration)}초');
    print('=====================');
  }
}
