// Flutter 앱의 메인 진입점
// 작성: 2023-05-10
// 앱의 진입점 및 전체 앱 구성을 초기화하는 파일

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'utils/app_theme.dart';
import 'views/main_screen.dart';
import 'controllers/settings_controller.dart';
import 'controllers/stats_controller.dart';
import 'services/audio_service.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 가로 모드 고정 (필요한 경우)
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.landscapeLeft,
  //   DeviceOrientation.landscapeRight,
  // ]);

  // Google Fonts 설정 제거 (더 이상 필요하지 않음)

  // Hive 초기화 (로컬 데이터 스토리지)
  await Hive.initFlutter();

  // 오디오 서비스 초기화
  final audioService = AudioService();
  await audioService.initialize();

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
  runApp(CosmicTyperApp());
}

class CosmicTyperApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 설정 컨트롤러 제공
        ChangeNotifierProvider(
          create: (_) => SettingsController()..initialize(),
        ),

        // 통계 컨트롤러 제공
        ChangeNotifierProvider(create: (_) => StatsController()..initialize()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          // 테마 모드 설정에 따라 테마 변경
          final themeMode = settingsController.darkThemeEnabled
              ? ThemeMode.dark
              : ThemeMode.light;

          // 접근성 설정
          final isAccessibilityMode = false; // 기본값으로 설정 (필요 시 나중에 구현)

          return MaterialApp(
            title: 'Cosmic Typer',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            home: MainScreen(),
            // 접근성 설정
            builder: (context, child) {
              if (isAccessibilityMode) {
                // 더 큰 텍스트 스케일
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.2),
                  child: child!,
                );
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}
