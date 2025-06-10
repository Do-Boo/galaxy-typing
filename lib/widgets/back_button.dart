// 뒤로가기 버튼 위젯
// 작성: 2024-05-01
// 업데이트: 2024-06-16 (버튼 클릭 소리 추가)
// 화면 상단에 배치되는 뒤로가기 버튼

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../utils/app_theme.dart';

class CosmicBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final EdgeInsets padding;
  final double iconSize;
  final bool useTransparentBackground;
  final bool enableSound; // 소리 활성화 여부 (기본값: true)

  const CosmicBackButton({
    super.key,
    this.onPressed,
    this.label,
    this.padding = const EdgeInsets.all(8.0),
    this.iconSize = 20.0,
    this.useTransparentBackground = true,
    this.enableSound = true, // 기본적으로 소리 활성화
  });

  // 오디오 서비스 인스턴스
  static final AudioService _audioService = AudioService();

  // 버튼 클릭 핸들러 (소리 포함)
  void _handleButtonPress(BuildContext context) {
    // 소리 재생 (비동기로 실행하여 UI 블로킹 방지)
    if (enableSound) {
      _audioService.playSound(SoundType.buttonClick).catchError((error) {
        // 소리 재생 실패 시 무시 (UI에는 영향 없음)
        if (kDebugMode) {
          print('뒤로가기 버튼 클릭 소리 재생 실패: $error');
        }
      });
    }

    // 원래 콜백 실행 또는 기본 뒤로가기 동작
    if (onPressed != null) {
      onPressed!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Material(
        color: useTransparentBackground
            ? Colors.transparent
            : AppColors.backgroundLighter.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _handleButtonPress(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.borderColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: iconSize,
                ),
                if (label != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    label!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
