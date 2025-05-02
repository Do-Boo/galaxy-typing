// 타이핑 텍스트 표시 위젯
// 작성: 2024-05-01
// 타자 연습 시 사용자가 입력해야 할 텍스트와 입력한 텍스트를 표시하는 위젯

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class TypingTextDisplay extends StatelessWidget {
  final String targetText;
  final String typedText;
  final bool showCursor;
  final double fontSize;
  final bool highlightCurrentWord;
  final int wordSpacing;
  final int lineSpacing;
  final bool showErrorHighlight;
  final bool useDifferentFontForCurrent;

  const TypingTextDisplay({
    super.key,
    required this.targetText,
    required this.typedText,
    this.showCursor = true,
    this.fontSize = 18.0,
    this.highlightCurrentWord = true,
    this.wordSpacing = 8,
    this.lineSpacing = 12,
    this.showErrorHighlight = true,
    this.useDifferentFontForCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final typedLength = typedText.length;
    final cursorPosition =
        typedLength < targetText.length ? typedLength : targetText.length;

    // 텍스트를 문자별로 분리하여 스타일링
    List<Widget> textWidgets = [];

    for (int i = 0; i < targetText.length; i++) {
      Color textColor;
      FontWeight fontWeight = FontWeight.normal;

      // 이미 입력된 문자 (올바르게 입력됨)
      if (i < typedLength && targetText[i] == typedText[i]) {
        textColor = AppColors.success;
        fontWeight = FontWeight.normal;
      }
      // 이미 입력된 문자 (잘못 입력됨)
      else if (i < typedLength) {
        textColor = AppColors.error;
        fontWeight = FontWeight.bold;
      }
      // 현재 커서 위치
      else if (i == typedLength && showCursor) {
        textColor = AppColors.primary;
        fontWeight = FontWeight.bold;
      }
      // 아직 입력되지 않은 문자
      else {
        textColor = AppColors.textSecondary;
      }

      // 공백 문자 처리
      if (targetText[i] == ' ') {
        textWidgets.add(SizedBox(width: wordSpacing.toDouble()));
        continue;
      }

      // 줄바꿈 처리
      if (targetText[i] == '\n') {
        textWidgets.add(SizedBox(
          height: lineSpacing.toDouble(),
          width: double.infinity,
        ));
        continue;
      }

      // 텍스트 위젯 생성
      final charWidget = Text(
        targetText[i],
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontFamily: (i == typedLength && useDifferentFontForCurrent)
              ? 'PressStart2P'
              : 'Rajdhani',
          fontWeight: fontWeight,
          letterSpacing: 1.0,
        ),
      );

      // 커서 효과 적용
      // if (i == typedLength && showCursor) {
      textWidgets.add(
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: (i == typedLength && showCursor)
                    ? AppColors.primary
                    : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 2),
          child: charWidget,
        ),
      );
      // } else {
      //   textWidgets.add(charWidget);
      // }
    }

    // 모든 글자를 포함하는 행 위젯 구성
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLighter.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1.0,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2, // 글자 사이 간격
        children: textWidgets,
      ),
    );
  }
}
