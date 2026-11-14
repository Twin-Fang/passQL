import 'package:flutter/cupertino.dart';

import '../../../core/exam_answer/exam_answer_score_report.dart';
import '../../../core/exam_answer/sqld_scoring_rule.dart';
import '../../design/design.dart';
import 'exam_answer_status_styles.dart';

/// 공유 이미지 카드 (이미지로 저장되는 면): 보라 머리(로고·회차) > 판정 > 점수(공개 선택) > 바닥 안내
class ExamAnswerShareCard extends StatelessWidget {
  const ExamAnswerShareCard({
    super.key,
    required this.roundTitle,
    required this.report,
    required this.isScorePublic,
  });

  final String roundTitle;
  final ExamAnswerScoreReport report;

  /// 점수·과목 점수·상위 % 를 싣는지 (끄면 판정만)
  final bool isScorePublic;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final passStatus = report.passStatus;
    final percentile = report.percentile;
    return SizedBox(
      width: PassqlSize.examAnswerShareCardWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
        child: ColoredBox(
          color: colors.card,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 머리: 보라 그라데이션 (탑승권과 같은 색)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.accent, colors.passGradientEnd],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(PassqlSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'passQL 가채점',
                        style: PassqlTypography.footnoteSemibold.copyWith(
                          color: colors.onAccent,
                        ),
                      ),
                      const SizedBox(height: PassqlSpacing.xxs),
                      Text(
                        roundTitle,
                        style: PassqlTypography.title2.copyWith(
                          color: colors.onAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(PassqlSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      passStatus.icon,
                      size: PassqlIconSize.statusPlaceholder,
                      color: passStatus.fillColorOf(colors),
                    ),
                    const SizedBox(height: PassqlSpacing.xs),
                    Text(
                      passStatus.label,
                      textAlign: TextAlign.center,
                      style: PassqlTypography.title3.copyWith(
                        color: passStatus.textColorOf(colors),
                      ),
                    ),
                    if (isScorePublic) ...[
                      const SizedBox(height: PassqlSpacing.xs),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${report.totalScore}',
                              style: PassqlTypography.scoreNumber.copyWith(
                                color: colors.label,
                              ),
                            ),
                            TextSpan(
                              text: ' / ${SqldScoringRule.maxScore}점',
                              style: PassqlTypography.headline.copyWith(
                                color: colors.secondaryLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: PassqlSpacing.sm),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: PassqlSpacing.xs,
                        runSpacing: PassqlSpacing.xxs,
                        children: [
                          for (final subject in report.subjects)
                            PassqlBadge(
                              text:
                                  '${subject.subjectNo}과목 ${subject.score}/${subject.maxScore}',
                              kind: subject.isFailCut
                                  ? PassqlBadgeKind.important
                                  : PassqlBadgeKind.neutral,
                            ),
                          if (percentile != null)
                            PassqlBadge(
                              text: '상위 ${percentile.round()}%',
                              kind: PassqlBadgeKind.topic,
                            ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: PassqlSpacing.xxs),
                      Text(
                        '점수는 비공개예요',
                        style: PassqlTypography.footnote.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 바닥: 함께 가채점하자는 한 줄
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PassqlSpacing.md,
                  vertical: PassqlSpacing.sm,
                ),
                color: colors.fill,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.pencil_outline,
                      size: PassqlIconSize.xs,
                      color: colors.accentText,
                    ),
                    const SizedBox(width: PassqlSpacing.xxs),
                    Expanded(
                      child: Text(
                        '나도 passQL에서 가채점하기',
                        style: PassqlTypography.footnoteSemibold.copyWith(
                          color: colors.accentText,
                        ),
                      ),
                    ),
                    const PassqlLogo(height: PassqlSize.footerLogoHeight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
