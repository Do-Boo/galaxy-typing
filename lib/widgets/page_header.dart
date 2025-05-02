// 페이지 헤더 위젯
// 작성: 2024-05-01
// 업데이트: 2024-05-15 (CosmicPulsingText 위젯 사용)
// 앱 페이지 상단에 표시되는 타이틀과 서브타이틀을 관리하는 공통 위젯

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'cosmic_pulsing_text.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool useLogoStyle;
  final bool centerAlign;
  final Widget? trailing;
  final double? bottomMargin;
  final double titleFontSize;
  final double subtitleFontSize;

  const PageHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.useLogoStyle = false,
    this.centerAlign = true,
    this.trailing,
    this.bottomMargin,
    this.titleFontSize = 28.0,
    this.subtitleFontSize = 14.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerContent = Column(
      crossAxisAlignment:
          centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 타이틀
        _buildTitle(context),

        // 서브타이틀 (제공된 경우)
        if (subtitle != null)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              subtitle!,
              style: AppTextStyles.subtitleStyle(context),
              textAlign: centerAlign ? TextAlign.center : TextAlign.start,
            ),
          ),
      ],
    );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: bottomMargin ?? 24),
      child: trailing != null
          ? Row(
              mainAxisAlignment: centerAlign
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!centerAlign) headerContent,
                if (centerAlign) Spacer(),
                if (centerAlign) headerContent,
                if (centerAlign) Spacer(),
                trailing!,
              ],
            )
          : Center(child: headerContent),
    );
  }

  // 타이틀 스타일에 따라 다르게 렌더링
  Widget _buildTitle(BuildContext context) {
    if (useLogoStyle) {
      return _buildLogoStyleTitle(context);
    } else {
      return Text(
        title,
        style: AppTextStyles.titleLarge(context).copyWith(
          fontSize: titleFontSize,
        ),
        textAlign: centerAlign ? TextAlign.center : TextAlign.start,
      );
    }
  }

  // 로고 스타일 타이틀 (PressStart2P 폰트 및 특수 효과)
  Widget _buildLogoStyleTitle(BuildContext context) {
    return CosmicPulsingText(
      text: title,
      fontSize: 24,
      centerAlign: centerAlign,
    );
  }
}
