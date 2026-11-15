import 'package:flutter/cupertino.dart';

import '../../../data/models/progress/expected_pass_response.dart';
import '../../design/design.dart';

/// 응시 0회 안내 문구 (프로필 카드·회차 목록 한 줄 공통)
const String expectedPassEmptyMessage = '모의고사 1회를 풀면 예상 합격률이 보여요';

/// 숫자 > 표시 글 (정수면 소수점 없이: 60.0 > 60, 41.68 > 41.68)
String formatExpectedPassNumber(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

/// 예상 합격률 본문 (#1086): 큰 비율 > 근거 한 줄 > 공식 합격률 비교 > 과락 주의 과목
/// 응시 0회면 안내 한 줄
class ExpectedPassSummary extends StatelessWidget {
  const ExpectedPassSummary({super.key, required this.expectedPass});

  final ExpectedPassResponse expectedPass;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final expectedPassPercent = expectedPass.expectedPassPercent;
    if (expectedPassPercent == null) {
      return Text(
        expectedPassEmptyMessage,
        style: PassqlTypography.subheadline.copyWith(
          color: colors.secondaryLabel,
        ),
      );
    }
    final averageScore = expectedPass.averageScore ?? 0;
    final officialPassRatePercent = expectedPass.officialPassRatePercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 큰 비율 + 근거
        Text(
          '$expectedPassPercent%',
          style: PassqlTypography.largeTitle.copyWith(
            color: colors.accentText,
            fontFeatures: PassqlTypography.tabular,
          ),
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        Text(
          '최근 ${expectedPass.basisAttemptCount}회 중 '
          '${expectedPass.passedAttemptCount}회 합격 | '
          '평균 ${formatExpectedPassNumber(averageScore)}점',
          style: PassqlTypography.subheadline.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        // 공식 최근 연도 합격률 비교 (통계 없으면 생략)
        if (officialPassRatePercent != null) ...[
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            '${expectedPass.officialStatisticYear ?? ''}년 공식 합격률 '
            '${formatExpectedPassNumber(officialPassRatePercent)}% vs '
            '내 예상 $expectedPassPercent%',
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
        // 과락 주의 과목 (평균이 과락 기준 + 4점 이하)
        for (final subjectAverage in expectedPass.failRiskSubjects) ...[
          const SizedBox(height: PassqlSpacing.sm),
          PassqlCallout(
            kind: PassqlCalloutKind.warning,
            icon: CupertinoIcons.exclamationmark_triangle_fill,
            label: '과락 주의',
            child: Text(
              '${subjectAverage.subjectName} 평균 '
              '${formatExpectedPassNumber(subjectAverage.averageScore)}점 '
              '(${subjectAverage.failBelowScore}점 미만이면 과락)',
              style: PassqlTypography.subheadline.copyWith(color: colors.label),
            ),
          ),
        ],
      ],
    );
  }
}
