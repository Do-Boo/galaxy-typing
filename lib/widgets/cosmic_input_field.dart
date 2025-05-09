// 입력 필드 위젯
// 작성: 2024-05-01
// 앱 전체에서 사용되는 일관된 입력 필드 스타일 위젯

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_theme.dart';

class CosmicInputField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool autofocus;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? errorText;
  final String? helperText;
  final EdgeInsets? contentPadding;

  const CosmicInputField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.errorText,
    this.helperText,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    // 웹 플랫폼에서 키보드 관련 이슈를 해결하기 위한 추가 설정
    final TextStyle inputStyle = AppTextStyles.bodyLarge(context).copyWith(
      // 웹 모바일 환경에서는 작은 폰트 크기가 줌 이슈를 일으킬 수 있으므로 최소 16px로 설정
      fontSize: kIsWeb ? 16.0 : AppTextStyles.bodyLarge(context).fontSize,
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      autofocus: autofocus,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: inputStyle,
      cursorColor: AppColors.primary,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(2),
      // 웹 환경에서 스페이스바 문제 해결을 위한 추가 설정
      enableInteractiveSelection: true,
      enableSuggestions: true,
      // 웹 환경에서 자동 교정 비활성화
      autocorrect: !kIsWeb,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        helperText: helperText,
        helperStyle: AppTextStyles.bodySmall(context),
        errorStyle: AppTextStyles.bodySmall(context).copyWith(
          color: AppColors.error,
        ),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
        filled: true,
        fillColor: AppColors.backgroundLighter.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.borderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: AppColors.textSecondary,
                size: 20,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(
                  suffixIcon,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onSuffixIconPressed,
                splashRadius: 20,
              )
            : null,
      ),
    );
  }
}
