# 갤럭시 타자연습 (Galaxy Typing)

크로스 플랫폼 우주 테마의 타자 연습 애플리케이션입니다. Flutter를 이용하여 웹, 안드로이드, iOS, macOS에서 실행 가능합니다.

## 주요 기능

- **다양한 게임 모드**: 기본 연습, 시간 도전, 우주 디펜스 게임
- **통계 추적**: 입력 속도, 정확도, 진행 상황 등을 추적
- **개인화 설정**: 난이도 조절, 테마 변경, 사용자 정의 단어 세트 등
- **우주 테마 인터페이스**: 몰입감 있는 우주 테마의 디자인과 애니메이션
- **사운드 효과**: 타이핑 사운드, 배경 음악으로 더 풍부한 경험 제공
- **접근성 지원**: 고대비 모드, 텍스트 크기 조절 등 다양한 사용자를 위한 설정

## 개발 환경 설정

### 필수 요구사항
- Flutter SDK (최신 버전)
- Dart SDK
- Android Studio / Xcode (각 플랫폼별 빌드를 위함)

### 시작하기

1. 저장소 클론
   ```bash
   git clone https://github.com/Do-Boo/galaxy-typing.git
   cd galaxy-typing
   ```

2. 의존성 설치
   ```bash
   flutter pub get
   ```

3. 앱 실행
   ```bash
   flutter run
   ```

## 프로젝트 구조

```
lib/
├── controllers/       # 상태 관리 컨트롤러
├── models/            # 데이터 모델
├── services/          # 백엔드 서비스 (설정, 통계 등)
├── utils/             # 유틸리티 클래스 및 상수
├── views/             # 화면 UI
├── widgets/           # 재사용 가능한 위젯
└── main.dart          # 앱 진입점
```

## 빌드 및 배포

### Android 빌드
```bash
flutter build apk --release
```

### iOS 빌드
```bash
flutter build ios --release
```

### macOS 빌드
```bash
flutter build macos --release
```

### 웹 빌드
```bash
flutter build web --release
```

## 기여하기

1. 이 저장소를 포크하세요
2. 새 브랜치를 만드세요 (`git checkout -b feature/amazing-feature`)
3. 변경사항을 커밋하세요 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 푸시하세요 (`git push origin feature/amazing-feature`)
5. Pull Request를 제출하세요

## 라이선스

MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.
