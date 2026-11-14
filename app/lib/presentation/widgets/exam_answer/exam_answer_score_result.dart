import 'package:flutter/cupertino.dart';

import '../../../core/exam_answer/exam_answer_score_report.dart';
import '../../../core/exam_answer/exam_grading_rule.dart';
import '../../design/design.dart';
import 'exam_answer_score_bar.dart';
import 'exam_answer_status_styles.dart';

/// 가채점 결과: 판정 > 총점(차오름) > 갈림 범위·상위 % > 과목 막대 2개 + 총점 막대(과락선·합격선)
class ExamAnswerScoreResult extends StatelessWidget {
  const ExamAnswerScoreResult({
    super.key,
    required this.report,
    required this.gradingRule,
  });

  final ExamAnswerScoreReport report;

  /// 만점·합격선·과목 과락선 (회차 채점 규칙)
  final ExamGradingRule gradingRule;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final passStatus = report.passStatus;
    final percentile = report.percentile;
    final range = report.scoreRange;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 판정 + 총점
        Semantics(
          container: true,
          label: '${passStatus.label}, ${report.totalScore}점',
          excludeSemantics: true,
          child: Column(
            children: [
              PassqlPopIn(
                child: Icon(
                  passStatus.icon,
                  size: PassqlIconSize.resultMarkLarge,
                  color: passStatus.fillColorOf(colors),
                ),
              ),
              const SizedBox(height: PassqlSpacing.xs),
              Text(
                passStatus.label,
                textAlign: TextAlign.center,
                style: PassqlTypography.title3.copyWith(
                  color: passStatus.textColorOf(colors),
                ),
              ),
              const SizedBox(height: PassqlSpacing.xxs),
              PassqlCountUp(
                value: report.totalScore,
                builder: (context, displayedScore) => Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$displayedScore',
                        style: PassqlTypography.scoreNumber.copyWith(
                          color: colors.label,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${gradingRule.maxScore}점',
                        style: PassqlTypography.headline.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PassqlSpacing.sm),
        // 범위·상위 %·오프라인 안내
        Wrap(
          alignment: WrapAlignment.center,
          spacing: PassqlSpacing.xs,
          runSpacing: PassqlSpacing.xxs,
          children: [
            if (report.hasUnsettledQuestion)
              PassqlBadge(
                text: '갈림 문항에 따라 ${range.min}~${range.max}점',
                kind: PassqlBadgeKind.warning,
                icon: CupertinoIcons.arrow_left_right,
              ),
            if (percentile != null)
              PassqlBadge(
                text: '참여자 중 상위 $percentile%',
                kind: PassqlBadgeKind.topic,
                icon: CupertinoIcons.chart_bar_fill,
              ),
            if (report.isLocalEstimate)
              const PassqlBadge(
                text: '오프라인 계산 (상위 % 없음)',
                kind: PassqlBadgeKind.neutral,
                icon: CupertinoIcons.wifi_slash,
              ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.xl),
        // 과목 막대 (과락선)
        for (final subjectRule in gradingRule.subjects) ...[
          ExamAnswerScoreBar(
            label: '${subjectRule.subjectNo}과목 ${subjectRule.name}',
            score: _scoreOf(subjectRule.subjectNo),
            maxScore: subjectRule.maxScore,
            cutScore: subjectRule.failBelowScore,
            cutLabel: '과락 ${subjectRule.failBelowScore}점',
          ),
          const SizedBox(height: PassqlSpacing.md),
        ],
        // 총점 막대 (합격선 + 갈림 범위)
        ExamAnswerScoreBar(
          label: '총점',
          score: report.totalScore,
          maxScore: gradingRule.maxScore,
          cutScore: gradingRule.passScore,
          cutLabel: '합격 ${gradingRule.passScore}점',
          rangeMinScore: range.min,
          rangeMaxScore: range.max,
        ),
      ],
    );
  }

  int _scoreOf(int subjectNo) {
    for (final subject in report.subjects) {
      if (subject.subjectNo == subjectNo) return subject.score;
    }
    return 0;
  }
}
