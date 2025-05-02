# 코스믹 타이퍼 에셋 (Assets)

이 디렉토리에는 코스믹 타이퍼 앱에서 사용하는 모든 외부 리소스 파일들이 포함되어 있습니다.

## 디렉토리 구조

- `fonts/` - 앱에서 사용하는 폰트 파일들
- `images/` - 아이콘, 배경 및 게임 요소 이미지들
- `sounds/` - 효과음 및 배경 음악 파일들

## 에셋 파일 위치에 대한 참고사항

실제 오디오 파일을 추가할 때는 다음 경로에 파일을 배치해야 합니다:

```
assets/sounds/
  ├── button_click.mp3     # 버튼 클릭 효과음
  ├── challenge_theme.mp3  # 시간 도전 모드 배경 음악
  ├── countdown.mp3        # 카운트다운 효과음 
  ├── enemy_destroyed.mp3  # 적 파괴 효과음
  ├── error.mp3            # 오타 입력 시 효과음
  ├── game_over.mp3        # 게임 오버 효과음
  ├── game_start.mp3       # 게임 시작 효과음
  ├── key_press.mp3        # 키 입력 효과음
  ├── main_theme.mp3       # 메인 화면 배경 음악
  ├── pause.mp3            # 일시 정지 효과음
  ├── player_hit.mp3       # 플레이어 피격 효과음
  ├── practice_theme.mp3   # 기본 연습 모드 배경 음악
  ├── space_defense_theme.mp3 # 우주 디펜스 모드 배경 음악
  ├── tick.mp3             # 시계 틱 효과음
  ├── wave_up.mp3          # 웨이브 증가 효과음
  └── word_complete.mp3    # 단어 완성 효과음
```

현재 파일들은 개발 중 애플리케이션 실행을 위한 플레이스홀더입니다. 실제 배포 전에 적절한 오디오 파일로 대체해야 합니다. 