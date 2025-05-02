// 뒤로가기 버튼 위젯
// 작성: 2024-05-01
// 화면 상단에 배치되는 뒤로가기 버튼

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CosmicBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final EdgeInsets padding;
  final double iconSize;
  final bool useTransparentBackground;

  const CosmicBackButton({
    Key? key,
    this.onPressed,
    this.label,
    this.padding = const EdgeInsets.all(8.0),
    this.iconSize = 20.0,
    this.useTransparentBackground = true,
  }) : super(key: key);

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
          onTap: onPressed ?? () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
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
                  SizedBox(width: 4),
                  Text(
                    label!,
                    style: TextStyle(
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
