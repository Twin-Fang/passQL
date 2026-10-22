import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 무료 하루 문제 수를 서버에서 못 받았을 때의 표시값
const int _fallbackDailyFreeLimit = 10;

// 체크·대시 칸 읽기 문구 (화면 낭독기)
const String _includedSemanticLabel = '포함';
const String _notIncludedSemanticLabel = '제공 안 함';

// 개념 학습 행은 2번 프로젝트가 나오기 전까지 숨김 (없는 기능을 팔지 않음)
const bool _isConceptLearningRowVisible = false;

/// 비교표 한 행: 무료 값이 null 이면 "—"(불가), 프로 값이 null 이면 체크
typedef _PlanRow = ({String label, String? free, String? pro});

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

  List<_PlanRow> get _rows {
    final limit = dailyFreeLimit > 0 ? dailyFreeLimit : _fallbackDailyFreeLimit;
    return [
      (label: '문제 풀이', free: '하루 $limit개', pro: '제한 없음'),
      (label: 'SQL 직접 실행', free: null, pro: null),
      (label: '해설', free: '한 줄', pro: '보기별 전체'),
      (label: '실전 모드·토픽', free: null, pro: null),
      (label: '출제 경향', free: null, pro: null),
      (label: '통계', free: '기본', pro: '약점 분석'),
      if (_isConceptLearningRowVisible)
        (label: '개념 학습', free: '앞 단원', pro: '전체'),
    ];
  }

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
                color: colors.accent,
              ),
            ),
          ),
          for (final row in _rows) ...[
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
