// 우주 테마 펄싱 텍스트 위젯
// 작성: 2024-05-15
// PressStart2P 폰트를 사용하는 펄싱 효과 텍스트 위젯

import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_theme.dart';

class CosmicPulsingText extends StatefulWidget {
  final String text;
  final double fontSize;
  final bool centerAlign;
  final Color? baseColor;
  final Color? glowColor;
  final bool enablePulsing;

  const CosmicPulsingText({
    Key? key,
    required this.text,
    this.fontSize = 24.0,
    this.centerAlign = true,
    this.baseColor,
    this.glowColor,
    this.enablePulsing = true,
  }) : super(key: key);

  @override
  _CosmicPulsingTextState createState() => _CosmicPulsingTextState();
}

class _CosmicPulsingTextState extends State<CosmicPulsingText> {
  late Timer _timer;
  double _glowIntensity = 0.7;
  bool _increasing = true;

  @override
  void initState() {
    super.initState();

    // 펄싱 효과를 위한 타이머 설정
    if (widget.enablePulsing) {
      _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
        setState(() {
          // 발광 효과 강도 변경
          if (_increasing) {
            _glowIntensity += 0.02;
            if (_glowIntensity >= 1.0) {
              _glowIntensity = 1.0;
              _increasing = false;
            }
          } else {
            _glowIntensity -= 0.02;
            if (_glowIntensity <= 0.4) {
              _glowIntensity = 0.4;
              _increasing = true;
            }
          }
        });
      });
    }
  }

  @override
  void dispose() {
    if (widget.enablePulsing) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.baseColor ?? AppColors.textPrimary;
    final glowColor = widget.glowColor ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.only(bottom: 2),
      child: Stack(
        children: [
          // 기본 텍스트
          Text(
            widget.text,
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: widget.fontSize,
              letterSpacing: -0.5,
              color: textColor,
              height: 1.2,
            ),
            textAlign: widget.centerAlign ? TextAlign.center : TextAlign.start,
          ),

          // 발광 효과 텍스트
          Positioned.fill(
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: widget.fontSize,
                letterSpacing: -0.5,
                color: glowColor,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: glowColor.withOpacity(_glowIntensity),
                    blurRadius: 10,
                  ),
                ],
              ),
              textAlign:
                  widget.centerAlign ? TextAlign.center : TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
