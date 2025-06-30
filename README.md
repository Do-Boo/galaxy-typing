# Galaxy Typing 🚀

> 우주를 여행하며 타자 마스터가 되어보세요!

Galaxy Typing은 우주 테마의 혁신적인 타자 연습 앱으로, 4가지 게임 모드와 아름다운 우주 테마로 재미있게 타자 실력을 향상시킬 수 있습니다.

## 🌟 주요 특징

### 🎯 4가지 게임 모드
- **기본 연습**: 단어별 타자 연습으로 기초 실력 향상
- **시간 도전**: 제한 시간 내 최대한 많은 단어 입력
- **우주 디펜스**: 슈팅 게임 형태의 타자 게임
- **긴 텍스트 연습**: 문장 단위의 실용적인 타자 연습

### 🎨 우주 테마 디자인
- **색상 팔레트**: 
  - Primary: #00D4FF (사이언 블루)
  - Secondary: #9C4DFF (코스믹 퍼플)
  - Accent: #FF4081 (네온 핑크)
  - Background: #0A0E21 (딥 스페이스)
- **폰트**: PressStart2P (로고), Rajdhani (UI)
- **애니메이션**: 별빛 효과, 부드러운 전환

### 📊 상세한 통계 시스템
- WPM (Words Per Minute) 측정
- 정확도 분석
- 진행 상황 추적
- 성과 기록 관리

### 🎵 몰입감 있는 오디오
- 우주 테마 배경음악
- 타이핑 효과음
- 게임 모드별 전용 음악

## 🌐 배포 버전

### 📱 모바일 앱
- **iOS**: App Store 배포 (TestFlight 테스트 완료)
- **Android**: Google Play Store 준비 중
- **Bundle ID**: com.doboocop.galaxytyping.fresh2025

### 🖥️ 웹 버전
- **랜딩 페이지**: [Galaxy Typing 공식 사이트](https://galaxy-typing.vercel.app)
- **웹 게임**: 브라우저에서 바로 플레이 가능
- **반응형 디자인**: 데스크톱, 태블릿, 모바일 최적화

### 💻 데스크톱 앱
- **Windows**: Flutter 데스크톱 앱
- **macOS**: Flutter 데스크톱 앱
- **Linux**: Flutter 데스크톱 앱

## 🚀 기술 스택

### Flutter 앱
- **Framework**: Flutter 3.32.4
- **Language**: Dart
- **State Management**: Provider
- **Audio**: just_audio
- **Preferences**: shared_preferences
- **Animations**: flutter_animate

### 웹 랜딩 페이지
- **Frontend**: HTML5, CSS3, JavaScript
- **Fonts**: Google Fonts (Press Start 2P, Rajdhani)
- **Animations**: CSS Animations, Intersection Observer
- **Responsive**: Mobile-first design

### 배포 환경
- **Web Hosting**: Vercel
- **Mobile**: App Store, Google Play Store
- **Version Control**: Git, GitHub

## 📁 프로젝트 구조

```
keyboard/
├── galaxy_typing/                 # Flutter 앱
│   ├── lib/
│   │   ├── controllers/          # 상태 관리
│   │   ├── models/              # 데이터 모델
│   │   ├── services/            # 비즈니스 로직
│   │   ├── utils/               # 유틸리티
│   │   ├── views/               # 화면
│   │   └── widgets/             # 재사용 컴포넌트
│   ├── assets/                  # 리소스 파일
│   │   ├── sounds/             # 오디오 파일
│   │   ├── images/             # 이미지 파일
│   │   └── data/               # JSON 데이터
│   └── screenshots/            # 앱 스크린샷
├── galaxy_typing_landing.html    # 랜딩 페이지
├── image_resizer.html           # 이미지 리사이저 도구
└── docs/                       # 문서
    └── project_plan.md         # 프로젝트 계획
```

## 🎮 게임 모드 상세

### 🎯 기본 연습 (Basic Practice)
- 한글/영어 단어 연습
- 난이도별 단어 제공
- 실시간 WPM 측정
- 정확도 피드백

### ⏱️ 시간 도전 (Time Challenge)
- 60초 제한 시간
- 최대한 많은 단어 입력
- 속도 기록 갱신
- 집중력 향상

### 🚀 우주 디펜스 (Space Defense)
- 슈팅 게임 + 타자 연습
- 적 우주선 격파
- 보스 전투 시스템
- 파워업 아이템

### 📝 긴 텍스트 연습 (Long Text Practice)
- 문장 단위 연습
- 실제 타이핑 환경 시뮬레이션
- 문맥 이해 향상
- 실용적 스킬 개발

## 📊 성능 지표

### 앱 성능
- **빌드 크기**: 73.2MB (iOS)
- **빌드 시간**: 19.5초
- **플랫폼**: iOS 13.0+, Android API 21+
- **언어**: 한국어, 영어

### 웹 성능
- **로딩 속도**: < 3초
- **Lighthouse 점수**: 90+
- **반응형**: 모든 디바이스 지원
- **접근성**: WCAG 2.1 AA 준수

## 🔧 개발 환경 설정

### Flutter 앱 실행
```bash
cd galaxy_typing
flutter pub get
flutter run
```

### 웹 페이지 실행
```bash
# 로컬 서버 실행
python -m http.server 8000
# 또는
npx serve .
```

### Vercel 배포
```bash
# Vercel CLI 설치
npm i -g vercel

# 배포
vercel --prod
```

## 📱 앱 스토어 정보

### App Store Connect
- **앱 이름**: Galaxy Typing
- **부제목**: 우주 테마의 타자 연습 게임
- **카테고리**: 교육, 게임
- **연령 등급**: 4+
- **키워드**: 타자연습, 타이핑, 키보드, 교육, 학습, 우주, 게임

### 마케팅 정보
- **프로모션 텍스트**: "우주를 여행하며 타자 마스터가 되어보세요! 4가지 게임 모드로 재미있게 타자 실력을 향상시키는 혁신적인 앱입니다."
- **설명**: 상세한 기능 설명과 게임 모드 소개
- **스크린샷**: 8개 화면 (메인, 기본연습, 시간도전, 우주디펜스, 통계, 설정, 웹버전, 데스크톱버전)

## 🚀 배포 이력

### 2025.06.30
- **Phase 35**: Vercel 배포 준비
- 랜딩 페이지 GitHub 업로드
- 이미지 리사이저 도구 추가
- README.md 종합 업데이트

### 2025.06.29
- **Phase 34**: 실제 스크린샷 적용
- iPhone 16 Pro Max 스크린샷 8개 추가
- 랜딩 페이지 갤러리 업데이트
- 스크린샷 슬라이더 구현

### 2025.06.26
- **Phase 33**: TestFlight 배포 성공
- iOS 빌드 최적화
- Bundle ID 설정 완료
- 앱 아이콘 생성 및 적용

## 🎯 향후 계획

### 단기 목표 (1개월)
- [ ] Google Play Store 출시
- [ ] 웹 버전 기능 확장
- [ ] 사용자 피드백 수집
- [ ] 성능 최적화

### 중기 목표 (3개월)
- [ ] 멀티플레이어 모드
- [ ] 더 많은 언어 지원
- [ ] AI 기반 맞춤형 연습
- [ ] 소셜 기능 추가

### 장기 목표 (6개월)
- [ ] 교육 기관 파트너십
- [ ] 프리미엄 기능 추가
- [ ] 전 세계 사용자 확대
- [ ] 브랜드 확장

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 연락처

- **개발자**: Do-Boo
- **이메일**: contact@doboocop.com
- **GitHub**: [@Do-Boo](https://github.com/Do-Boo)
- **웹사이트**: [Galaxy Typing](https://galaxy-typing.vercel.app)

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

---

<div align="center">

**🚀 Galaxy Typing과 함께 타자 실력을 우주 레벨로! 🚀**

[![Download on App Store](https://img.shields.io/badge/Download-App%20Store-blue?style=for-the-badge&logo=apple)](https://apps.apple.com)
[![Get it on Google Play](https://img.shields.io/badge/Get%20it%20on-Google%20Play-green?style=for-the-badge&logo=google-play)](https://play.google.com)
[![Play on Web](https://img.shields.io/badge/Play%20on-Web-purple?style=for-the-badge&logo=web)](https://galaxy-typing.vercel.app)

</div> 