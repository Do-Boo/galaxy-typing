// Flutter 앱의 메인 진입점
// 작성: 2023-05-10
// 업데이트: 2024-06-10 (언어 및 글꼴 크기 설정 적용)
// 업데이트: 2024-06-12 (로컬라이제이션 설정 추가, 초기화 최적화)
// 앱의 진입점 및 전체 앱 구성을 초기화하는 파일

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'controllers/settings_controller.dart';
import 'controllers/stats_controller.dart';
import 'models/game_settings.dart';
import 'services/audio_service.dart';
import 'utils/app_theme.dart';
import 'views/splash_screen.dart';

// 앱 구성 요소의 전역 인스턴스
// 앱 전체에서 일관된 인스턴스 사용을 위한 변수들
late final SettingsController settingsController;
late final StatsController statsController;
late final AudioService audioService;

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화 (로컬 데이터 스토리지)
  await Hive.initFlutter();

  if (kDebugMode) {
    print('앱 초기화 시작...');
  }

  // 주요 컨트롤러 및 서비스 초기화
  settingsController = SettingsController();
  statsController = StatsController();
  audioService = AudioService();

  // 병렬로 초기화 작업 실행 (성능 향상)
  await Future.wait([
    settingsController.initialize(),
    statsController.initialize(),
    // AudioService는 생성할 때마다 초기화할 필요 없음
    // 필요한 시점에 자동으로 초기화됨
  ]);

  if (kDebugMode) {
    print('컨트롤러 및 서비스 초기화 완료');
    // 디버깅용 설정값 출력
    settingsController.printCurrentSettings();
    await settingsController.printStoredSettings();
  }

  // 시스템 UI 상태 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // 앱 실행
  runApp(const CosmicTyperApp());
}

class CosmicTyperApp extends StatelessWidget {
  const CosmicTyperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 초기화된 컨트롤러를 제공
        ChangeNotifierProvider<SettingsController>.value(
            value: settingsController),
        ChangeNotifierProvider<StatsController>.value(value: statsController),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          // 테마 모드 설정에 따라 테마 변경
          final themeMode = settingsController.darkThemeEnabled
              ? ThemeMode.dark
              : ThemeMode.light;

          // 접근성 설정
          const isAccessibilityMode = false; // 기본값으로 설정 (필요 시 나중에 구현)

          // 언어 설정 적용
          final currentLocale =
              settingsController.language == LanguageOption.korean
                  ? const Locale('ko', 'KR')
                  : const Locale('en', 'US');

          return MaterialApp(
            title: 'Cosmic Typer',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,

            // 로컬라이제이션 설정
            locale: currentLocale,
            supportedLocales: const [
              Locale('ko', 'KR'),
              Locale('en', 'US'),
            ],

            // 로컬라이제이션 델리게이트 설정
            localizationsDelegates: const [
              // 기본 Material 위젯 로컬라이제이션
              GlobalMaterialLocalizations.delegate,
              // 기본 위젯 로컬라이제이션
              GlobalWidgetsLocalizations.delegate,
              // RTL/LTR 텍스트 방향 로컬라이제이션
              GlobalCupertinoLocalizations.delegate,
            ],

            home: const SplashScreen(),

            // 접근성 및 글꼴 크기 설정
            builder: (context, child) {
              // 설정된 글꼴 크기와 접근성 설정 적용
              final textScaleFactor =
                  isAccessibilityMode ? 1.2 : settingsController.fontSize;

              // MediaQuery를 사용하여 글꼴 크기 조정
              // Flutter 3.16 이상에서는 textScaler 사용,
              // 이전 버전과의 호환성을 위해 try-catch로 처리
              try {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScaleFactor),
                  ),
                  child: child!,
                );
              } catch (e) {
                // 이전 버전의 Flutter에서는 textScaleFactor 사용
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScaleFactor),
                  ),
                  child: child!,
                );
              }
            },
          );
        },
      ),
    );
  }
}
