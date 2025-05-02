// 공통 버튼 위젯
// 작성: 2024-05-01
// 앱 전체에서 사용되는 공통 버튼 스타일 위젯

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

enum CosmicButtonType {
  primary,
  secondary,
  outline,
  text,
}

enum CosmicButtonSize {
  small,
  medium,
  large,
}

class CosmicButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final CosmicButtonType type;
  final CosmicButtonSize size;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final bool isLoading;

  const CosmicButton({
    Key? key,
    required this.label,
    this.icon,
    this.type = CosmicButtonType.primary,
    this.size = CosmicButtonSize.medium,
    this.onPressed,
    this.isFullWidth = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 버튼 색상 정의
    final Color bgColor = _getBackgroundColor();
    final Color textColor = _getTextColor();
    final Color borderColor = _getBorderColor();

    // 버튼 크기에 따른 패딩과 폰트 크기 계산
    final padding = _getPadding();
    final double fontSize = _getFontSize();
    final double iconSize = _getIconSize();

    // 기본 버튼 스타일
    final ButtonStyle buttonStyle = _getButtonStyle(bgColor, borderColor);

    // 버튼 내용 위젯
    final Widget buttonContent = _buildButtonContent(
      context,
      textColor,
      fontSize,
      iconSize,
    );

    // 버튼 위젯 렌더링
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: Padding(
            padding: padding,
            child: buttonContent,
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: Padding(
          padding: padding,
          child: buttonContent,
        ),
      );
    }
  }

  // 버튼 내용 구성
  Widget _buildButtonContent(
    BuildContext context,
    Color textColor,
    double fontSize,
    double iconSize,
  ) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: textColor,
            size: iconSize,
          ),
          SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontFamily: 'Rajdhani',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // 버튼 배경색 가져오기
  Color _getBackgroundColor() {
    switch (type) {
      case CosmicButtonType.primary:
        return AppColors.primary;
      case CosmicButtonType.secondary:
        return AppColors.secondary;
      case CosmicButtonType.outline:
      case CosmicButtonType.text:
        return Colors.transparent;
    }
  }

  // 버튼 텍스트 색상 가져오기
  Color _getTextColor() {
    switch (type) {
      case CosmicButtonType.primary:
      case CosmicButtonType.secondary:
        return Colors.white;
      case CosmicButtonType.outline:
        return AppColors.primary;
      case CosmicButtonType.text:
        return AppColors.textPrimary;
    }
  }

  // 버튼 테두리 색상 가져오기
  Color _getBorderColor() {
    switch (type) {
      case CosmicButtonType.outline:
        return AppColors.primary;
      case CosmicButtonType.primary:
      case CosmicButtonType.secondary:
      case CosmicButtonType.text:
        return Colors.transparent;
    }
  }

  // 버튼 패딩 가져오기
  EdgeInsets _getPadding() {
    switch (size) {
      case CosmicButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        );
      case CosmicButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        );
      case CosmicButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        );
    }
  }

  // 버튼 폰트 크기 가져오기
  double _getFontSize() {
    switch (size) {
      case CosmicButtonSize.small:
        return 14.0;
      case CosmicButtonSize.medium:
        return 16.0;
      case CosmicButtonSize.large:
        return 18.0;
    }
  }

  // 버튼 아이콘 크기 가져오기
  double _getIconSize() {
    switch (size) {
      case CosmicButtonSize.small:
        return 16.0;
      case CosmicButtonSize.medium:
        return 20.0;
      case CosmicButtonSize.large:
        return 24.0;
    }
  }

  // 버튼 스타일 계산
  ButtonStyle _getButtonStyle(Color bgColor, Color borderColor) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.backgroundLighter;
          }
          if (states.contains(MaterialState.hovered) &&
              type != CosmicButtonType.text) {
            return bgColor.withOpacity(0.8);
          }
          return bgColor;
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return AppColors.textSecondary;
          }
          return _getTextColor();
        },
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: borderColor,
            width: type == CosmicButtonType.outline ? 1.5 : 0,
          ),
        ),
      ),
      overlayColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return type == CosmicButtonType.text
                ? AppColors.backgroundLighter
                : AppColors.primary.withOpacity(0.1);
          }
          return Colors.transparent;
        },
      ),
      elevation: MaterialStateProperty.resolveWith<double>(
        (Set<MaterialState> states) {
          if (type == CosmicButtonType.text ||
              type == CosmicButtonType.outline) {
            return 0;
          }
          if (states.contains(MaterialState.pressed)) {
            return 0;
          }
          if (states.contains(MaterialState.hovered)) {
            return 2;
          }
          return 1;
        },
      ),
    );
  }
}
