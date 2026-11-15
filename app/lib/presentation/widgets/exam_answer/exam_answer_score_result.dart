import 'package:flutter/cupertino.dart';

import '../../../core/exam_answer/exam_answer_score_report.dart';
import '../../../core/exam_answer/exam_grading_rule.dart';
import '../../design/design.dart';
import 'exam_answer_score_bar.dart';
import 'exam_answer_status_styles.dart';

/// 가채점 결과: 판정 한 줄(의미색 글자) > 총점(차오름) > 목록 묶음(과목 점수 2행, 점수 범위, 상위 %) + 기준 각주
class ExamAnswerScoreResult extends StatelessWidget {
  const ExamAnswerScoreResult({
    super.key,
    required this.report,
    required this.gradingRule,
    required this.unsettledQuestionCount,
  });

  final ExamAnswerScoreReport report;

  /// 만점·합격선·과목 과락선 (회차 채점 규칙)
  final ExamGradingRule gradingRule;

  /// 갈림·미확정 문항 수 (가답안 상태 기준, 점수 범위 행 설명)
  final int unsettledQuestionCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final passStatus = report.passStatus;
    final percentile = report.percentile;
    final range = report.scoreRange;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 판정 + 총점 (장식 아이콘 없이 글자만)
        Semantics(
          container: true,
          label: '${passStatus.label}, ${report.totalScore}점',
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passStatus.label,
                  style: PassqlTypography.headline.copyWith(
                    color: passStatus.textColorOf(colors),
                  ),
                ),
                PassqlCountUp(
                  value: report.totalScore,
                  builder: (context, displayedScore) => Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$displayedScore',
                          style: PassqlTypography.scoreNumber.copyWith(
                            fontFeatures: PassqlTypography.tabular,
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
        ),
        const SizedBox(height: PassqlSpacing.lg),
        PassqlGroupedSection(
          footer: _footerOf(report, gradingRule),
          children: [
            for (final subjectRule in gradingRule.subjects)
              _SubjectScoreRow(
                subjectRule: subjectRule,
                score: _scoreOf(subjectRule.subjectNo),
              ),
            if (report.hasUnsettledQuestion)
              PassqlListRow(
                title: '점수 범위',
                subtitle: unsettledQuestionCount > 0
                    ? '갈림, 미확정 $unsettledQuestionCount문항이 정해지면 바뀌어요'
                    : null,
                trailing: Text('${range.min}~${range.max}점'),
              ),
            if (percentile != null)
              PassqlListRow(
                title: '참여자 중 순위',
                trailing: Text('상위 $percentile%'),
              ),
          ],
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

  /// 묶음 각주: 과목별 과락 기준 + 합격 기준 (+ 오프라인 계산이면 상위 % 없음)
  static String _footerOf(
    ExamAnswerScoreReport report,
    ExamGradingRule gradingRule,
  ) {
    final cutText = gradingRule.subjects
        .map((subject) => '${subject.subjectNo}과목 ${subject.failBelowScore}점')
        .join(', ');
    final offlineText = report.isLocalEstimate
        ? ' 서버에 닿지 못해 기기에서 계산했어요. 상위 %는 없어요.'
        : '';
    return '$cutText 미만이면 과락, 총점 ${gradingRule.passScore}점 이상이면 합격이에요.$offlineText';
  }
}

/// 과목 점수 행: 이름 > 점수(과락이면 빨강) > 얇은 막대(과락 눈금)
class _SubjectScoreRow extends StatelessWidget {
  const _SubjectScoreRow({required this.subjectRule, required this.score});

  final ExamSubjectRule subjectRule;
  final int score;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isBelowCut = score < subjectRule.failBelowScore;
    final title = '${subjectRule.subjectNo}과목 ${subjectRule.name}';
    return Semantics(
      container: true,
      label:
          '$title $score점, 만점 ${subjectRule.maxScore}점, 과락 기준 ${subjectRule.failBelowScore}점${isBelowCut ? ', 과락' : ''}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.md,
          vertical: PassqlSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: PassqlTypography.body.copyWith(color: colors.label),
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                Text(
                  '$score',
                  style: PassqlTypography.headline.copyWith(
                    fontFeatures: PassqlTypography.tabular,
                    color: isBelowCut ? colors.wrongText : colors.label,
                  ),
                ),
                Text(
                  ' / ${subjectRule.maxScore}',
                  style: PassqlTypography.body.copyWith(
                    fontFeatures: PassqlTypography.tabular,
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.xs),
            ExamAnswerScoreBar(
              score: score,
              maxScore: subjectRule.maxScore,
              cutScore: subjectRule.failBelowScore,
            ),
          ],
        ),
      ),
    );
  }
}
