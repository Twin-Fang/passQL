import 'package:flutter/widgets.dart';

import '../../../data/models/meta/sqld_exam_guide.dart';
import '../../design/design.dart';

/// 인사이트 카드 3장 (#1077): 응시자 증가 배수, 직전 연도 대비 합격률 증감, 상위 자격(SQLP) 비교
/// 숫자는 서버 계산값만 씀. 인사이트 없으면(연도 2건 미만) 앞 2장 생략
class ExamGuideInsightCards extends StatelessWidget {
  const ExamGuideInsightCards({
    super.key,
    required this.insights,
    required this.latestComparison,
  });

  final SqldExamInsights? insights;
  // 가장 최근 연도 비교 자격 (없으면 null)
  final SqldCertificationComparison? latestComparison;

  @override
  Widget build(BuildContext context) {
    final currentInsights = insights;
    final comparison = latestComparison;
    final cards = <Widget>[
      if (currentInsights != null) ...[
        _InsightCard(
          headline: '${currentInsights.examineeGrowthMultiple}배',
          description:
              '${currentInsights.growthBaseYear}년보다 ${currentInsights.latestYear}년 응시자가 이만큼 늘었어요',
        ),
        _InsightCard(
          headline: _formatChangePoints(currentInsights.passRateChangePoints),
          description:
              '${currentInsights.latestYear - 1}년 대비 ${currentInsights.latestYear}년 합격률 변화예요',
        ),
      ],
      if (comparison != null)
        _InsightCard(
          headline: '${comparison.passRatePercent}%',
          description:
              '${comparison.year}년 ${comparison.certificationName} 합격률이에요. SQLD부터 시작하는 이유죠',
        ),
    ];
    return Column(
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.xs),
          cards[index],
        ],
      ],
    );
  }

  // -15.61 > "15.61%p 하락", 3.2 > "3.2%p 상승"
  static String _formatChangePoints(double changePoints) {
    final direction = changePoints < 0 ? '하락' : '상승';
    return '${changePoints.abs()}%p $direction';
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.headline, required this.description});

  final String headline;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: PassqlTypography.title2.copyWith(color: colors.accentText),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            description,
            style: PassqlTypography.subheadline.copyWith(color: colors.label),
          ),
        ],
      ),
    );
  }
}
