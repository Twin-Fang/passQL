import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'pro_benefits.dart';

// 체크·대시 칸 읽기 문구 (화면 낭독기)
const String _includedSemanticLabel = '포함';
const String _notIncludedSemanticLabel = '제공 안 함';

/// 무료·프로 비교표 (스펙 4-3): 항목 7개(개념 학습은 숨김), 프로 열은 강조색
class ProPlanComparisonTable extends StatelessWidget {
  const ProPlanComparisonTable({super.key, required this.dailyFreeLimit});

  /// 서버가 알려 준 무료 하루 문제 수 (0 이하면 기본값)
  final int dailyFreeLimit;

  // 열 너비 비율: 항목, 무료, 프로
  static const int _labelFlex = 5;
  static const int _freeFlex = 3;
  static const int _proFlex = 4;
  // 표 행 위아래 여백
  static const double _rowVerticalPadding = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
        border: Border.all(color: colors.separator, width: PassqlSize.hairline),
      ),
      child: Column(
        children: [
          _buildRow(
            context,
            label: const SizedBox.shrink(),
            free: Text(
              PassqlPlanChip.freeLabel,
              textAlign: TextAlign.center,
              style: PassqlTypography.captionSemibold.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            pro: Text(
              PassqlPlanChip.proLabel,
              textAlign: TextAlign.center,
              style: PassqlTypography.captionSemibold.copyWith(
                color: colors.accentText,
              ),
            ),
          ),
          // 행은 혜택 원본 하나에서 읽는다 (탑승권·시트와 같은 목록, #749)
          for (final row in proBenefits(dailyFreeLimit: dailyFreeLimit)) ...[
            Divider(
              height: PassqlSize.hairline,
              thickness: PassqlSize.hairline,
              color: colors.separator,
            ),
            _buildRow(
              context,
              label: Text(
                row.label,
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.label,
                ),
              ),
              free: _buildValue(context, row.free, isPro: false),
              pro: _buildValue(context, row.pro, isPro: true),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required Widget label,
    required Widget free,
    required Widget pro,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.sm,
        vertical: _rowVerticalPadding,
      ),
      child: Row(
        children: [
          Expanded(flex: _labelFlex, child: label),
          Expanded(
            flex: _freeFlex,
            child: Center(child: free),
          ),
          Expanded(
            flex: _proFlex,
            child: Center(child: pro),
          ),
        ],
      ),
    );
  }

  /// 표 칸: 글자 / 프로 null 은 체크 / 무료 null 은 불가(—)
  Widget _buildValue(
    BuildContext context,
    String? value, {
    required bool isPro,
  }) {
    final colors = context.passqlColors;
    if (value == null && isPro) {
      return Icon(
        CupertinoIcons.checkmark_alt,
        size: PassqlIconSize.md,
        color: colors.accent,
        semanticLabel: _includedSemanticLabel,
      );
    }
    return Text(
      value ?? '—',
      semanticsLabel: value == null ? _notIncludedSemanticLabel : null,
      textAlign: TextAlign.center,
      style:
          (isPro
                  ? PassqlTypography.footnoteSemibold
                  : PassqlTypography.footnote)
              .copyWith(color: isPro ? colors.accent : colors.secondaryLabel),
    );
  }
}
