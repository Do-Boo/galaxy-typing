// 우주 디펜스 게임 입력 필드 위젯
// 작성: 2024-06-16
// 사용자 입력을 받는 텍스트 필드와 게임 제어 버튼을 포함하는 위젯

import 'package:flutter/material.dart';

/// 게임 입력 필드 위젯
class GameInputFieldWidget extends StatelessWidget {
  /// 텍스트 입력 컨트롤러
  final TextEditingController controller;

  /// 포커스 노드
  final FocusNode focusNode;

  /// 힌트 텍스트
  final String hintText;

  /// 입력 필드 활성화 여부
  final bool enabled;

  /// 게임이 일시정지된 상태인지 여부
  final bool isPaused;

  /// 게임이 진행 중인지 여부
  final bool isPlaying;

  /// 텍스트 제출 핸들러
  final ValueChanged<String>? onSubmitted;

  /// 일시정지/재개 버튼 클릭 핸들러
  final VoidCallback? onPlayPausePressed;

  /// 텍스트 클리어 버튼 클릭 핸들러
  final VoidCallback? onClearPressed;

  /// 생성자
  const GameInputFieldWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.enabled = true,
    this.isPaused = false,
    this.isPlaying = false,
    this.onSubmitted,
    this.onPlayPausePressed,
    this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 텍스트 입력 필드
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.keyboard),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClearPressed,
              ),
            ),
            textInputAction: TextInputAction.send,
          ),
        ),

        const SizedBox(width: 8),

        // 게임 제어 버튼 (일시정지 중 또는 게임 진행 중일 때만 표시)
        if (isPaused || isPlaying)
          IconButton(
            icon: isPaused
                ? const Icon(Icons.play_arrow, color: Colors.green)
                : const Icon(Icons.pause, color: Colors.amber),
            onPressed: onPlayPausePressed,
            tooltip: isPaused ? '계속하기' : '일시정지',
          ),
      ],
    );
  }
}
