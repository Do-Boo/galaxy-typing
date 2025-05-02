// 통계 카드 위젯
// 작성: 2024-05-01
// 사용자 통계 정보를 격자 형태로 표시하는 위젯

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'cosmic_card.dart';

class StatItem {
  final String value;
  final String label;
  final IconData? icon;
  final Color? valueColor;

  StatItem({
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
  });
}

class StatisticsCard extends StatelessWidget {
  final String? title;
  final IconData? titleIcon;
  final Widget? headerAction;
  final List<StatItem> items;
  final int columns;
  final bool verticalLayout;
  final double iconSize;
  final TextStyle? valueStyle;

  const StatisticsCard({
    Key? key,
    this.title,
    this.titleIcon,
    this.headerAction,
    required this.items,
    this.columns = 3,
    this.verticalLayout = false,
    this.iconSize = 20.0,
    this.valueStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CosmicCard(
      title: title,
      titleIcon: titleIcon,
      trailing: headerAction,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: verticalLayout
            ? _buildVerticalLayout(context)
            : _buildGridLayout(context),
      ),
    );
  }

  // 수직 레이아웃 (세로로 항목 배치)
  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          items.map((item) => _buildVerticalStatItem(context, item)).toList(),
    );
  }

  // 수직 스타일의 통계 항목
  Widget _buildVerticalStatItem(BuildContext context, StatItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundLighter.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                item.icon,
                color: item.valueColor ?? AppColors.textSecondary,
                size: iconSize,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: AppTextStyles.bodySmall(context),
                ),
                SizedBox(height: 4),
                Text(
                  item.value,
                  style: valueStyle ??
                      AppTextStyles.titleMedium(context).copyWith(
                        color: item.valueColor ?? AppColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 그리드 레이아웃 (기존 레이아웃)
  Widget _buildGridLayout(BuildContext context) {
    // 아이템을 rows로 나누어 담기
    final List<List<StatItem>> rows = [];
    final int itemsPerRow = items.length < columns ? items.length : columns;

    for (int i = 0; i < items.length; i += itemsPerRow) {
      final end =
          (i + itemsPerRow <= items.length) ? i + itemsPerRow : items.length;
      rows.add(items.sublist(i, end));
    }

    return Column(
      children: rows.map((rowItems) {
        return Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowItems.map((item) {
              return Expanded(
                child: _buildGridStatItem(context, item),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // 그리드 스타일의 통계 항목
  Widget _buildGridStatItem(BuildContext context, StatItem item) {
    return Column(
      children: [
        Icon(
          item.icon,
          color: item.valueColor ?? AppColors.textSecondary,
          size: iconSize,
        ),
        SizedBox(height: 8),
        Text(
          item.value,
          style: valueStyle ??
              AppTextStyles.titleMedium(context).copyWith(
                color: item.valueColor ?? AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
        Text(
          item.label,
          style: AppTextStyles.bodySmall(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
