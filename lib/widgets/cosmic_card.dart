// 공통 카드 위젯
// 작성: 2024-05-01
// 앱 전체에서 사용되는 일관된 카드 스타일 위젯

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CosmicCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? titleIcon;
  final Widget? trailing;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isHoverable;
  final bool useDarkVariant;

  const CosmicCard({
    Key? key,
    required this.child,
    this.title,
    this.titleIcon,
    this.trailing,
    this.footer,
    this.padding,
    this.onTap,
    this.isHoverable = false,
    this.useDarkVariant = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 카드 헤더 (제목이 있는 경우)
        if (title != null) _buildHeader(context),

        // 카드 내용
        Padding(
          padding: padding ?? EdgeInsets.all(16),
          child: child,
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: useDarkVariant
            ? AppColors.background.withOpacity(0.8)
            : AppColors.backgroundLighter.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.backgroundDarker.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: isHoverable
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          highlightColor: isHoverable
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
          hoverColor: isHoverable
              ? AppColors.primary.withOpacity(0.05)
              : Colors.transparent,
          child: cardContent,
        ),
      ),
    );
  }

  // 카드 헤더 위젯
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 아이콘 (있는 경우)
          if (titleIcon != null) ...[
            Icon(
              titleIcon,
              size: 18,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
          ],

          // 제목
          Expanded(
            child: Text(
              title!,
              style: AppTextStyles.titleSmall(context),
            ),
          ),

          // 추가 액션 (있는 경우)
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
