import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';
import '../exam_trend/exam_trend_pattern_card.dart';

/// 홈 출제 경향 강조 카드: 머리(불꽃 + 제목 + 최신 경향 배지 + 전체), 요약, 근거 캡션, 가로 유형 카드
/// 배경은 강조 틴트 > 흰 카드 위주인 홈에서 눈에 띄게 함
class ExamTrendHomeSection extends StatelessWidget {
  const ExamTrendHomeSection({
    super.key,
    required this.report,
    required this.onSolveTopic,
    required this.onViewAll,
  });

  final ExamTrendReportResponse report;
  final void Function(String topicCode, String topicName) onSolveTopic;
  final VoidCallback onViewAll;

  /// 카드 제목 문구 원본
  static const String title = '이번 시험 출제 경향';

  /// '전체' 버튼 문구 원본
  static const String viewAllLabel = '전체';

  /// 가로 목록 높이: 유형 카드 높이와 같게
  static const double _patternListHeight = ExamTrendPatternCard.totalHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.accentTint,
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: PassqlSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
              child: _buildHeader(colors),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.summary,
                    style: PassqlTypography.headline.copyWith(
                      color: colors.label,
                    ),
                  ),
                  const SizedBox(height: PassqlSpacing.xxs),
                  Text(
                    '${report.basisDescription} · ${report.updatedDate} 갱신',
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
            // 유형 카드: 좌우 끝까지 흐르고 다음 카드가 오른쪽에 걸쳐 보임
            if (report.risingPatterns.isNotEmpty) ...[
              const SizedBox(height: PassqlSpacing.sm),
              SizedBox(
                height: _patternListHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PassqlSpacing.md,
                  ),
                  itemCount: report.risingPatterns.length,
                  itemBuilder: (_, index) => ExamTrendPatternCard(
                    pattern: report.risingPatterns[index],
                    onSolveTopic: onSolveTopic,
                  ),
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: PassqlSpacing.sm),
                ),
              ),
            ],
            const SizedBox(height: PassqlSpacing.md),
          ],
        ),
      ),
    );
  }

  /// 머리 줄: 불꽃 아이콘 + 제목 + 최신 경향 배지 + 오른쪽 '전체 >'
  Widget _buildHeader(PassqlColors colors) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.flame_fill,
          size: PassqlIconSize.xl,
          color: colors.accent,
        ),
        const SizedBox(width: PassqlSpacing.xs),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: colors.label,
            ),
          ),
        ),
        const SizedBox(width: PassqlSpacing.xs),
        const PassqlLatestTrendBadge(),
        const Spacer(),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, PassqlSize.minTouchTarget),
          onPressed: onViewAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                viewAllLabel,
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: colors.accent,
                ),
              ),
              Icon(
                CupertinoIcons.chevron_forward,
                size: PassqlIconSize.xs,
                color: colors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
