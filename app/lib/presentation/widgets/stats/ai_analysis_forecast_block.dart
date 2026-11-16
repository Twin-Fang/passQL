import 'package:flutter/cupertino.dart';

import '../../../data/models/progress/ai_stats_analysis.dart';
import '../../design/design.dart';

/// 예상 점수 묶음 (#862): 머리(예상 점수 + 판정 의미색 글자) > 큰 점수(0부터 차오름) > 과목별 막대 2줄 > 판정 설명
/// 상자·칩 없이 구간 안 글자로만 (DEC-0116, #1136). 과락 위험 과목 막대·설명은 주의 색, 동작 줄이기면 바로 표시
class AiAnalysisForecastBlock extends StatelessWidget {
  const AiAnalysisForecastBlock({super.key, required this.forecast});

  final AiExamForecast forecast;

  // 만점 표기 (SQLD 100점)
  static const int _maximumScore = 100;

  /// 판정 > 글자 의미색 (합격권 초록, 합격선 근처 주황, 합격선 아래·과락 위험 빨강, 모르는 판정 회색)
  static Color verdictColorOf(AiForecastVerdict verdict, PassqlColors colors) =>
      switch (verdict) {
        AiForecastVerdict.passLikely => colors.correctText,
        AiForecastVerdict.borderline => colors.warningText,
        AiForecastVerdict.belowPass ||
        AiForecastVerdict.subjectFailRisk => colors.wrongText,
        AiForecastVerdict.unknown => colors.secondaryLabel,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final hasFailRisk =
        forecast.isSubjectOneFailRisk || forecast.isSubjectTwoFailRisk;
    final fillDuration = PassqlMotion.durationOf(
      context,
      PassqlMotion.scoreFill,
    );
    return Semantics(
      container: true,
      label:
          '예상 점수 ${forecast.expectedScore}점, ${forecast.verdictLabel}. '
          '${forecast.summary}. ${forecast.detail}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 머리: 예상 점수 + 판정 글자
            Row(
              children: [
                Expanded(
                  child: Text(
                    '예상 점수',
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ),
                if (forecast.verdictLabel.isNotEmpty)
                  Text(
                    forecast.verdictLabel,
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: verdictColorOf(forecast.verdict, colors),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            // 큰 점수: 0 > 예상 점수로 차오름
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: forecast.expectedScore.toDouble()),
              duration: fillDuration,
              curve: PassqlMotion.curve,
              builder: (_, animatedScore, _) => Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${animatedScore.round()}',
                      style: PassqlTypography.title1.copyWith(
                        color: colors.label,
                        fontFeatures: PassqlTypography.tabular,
                      ),
                    ),
                    TextSpan(
                      text: '점 / $_maximumScore',
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            _SubjectScoreRow(
              subjectName: '1과목',
              expectedCount: forecast.subjectOneExpectedCount,
              questionCount: forecast.subjectOneQuestionCount,
              isFailRisk: forecast.isSubjectOneFailRisk,
              fillDuration: fillDuration,
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            _SubjectScoreRow(
              subjectName: '2과목',
              expectedCount: forecast.subjectTwoExpectedCount,
              questionCount: forecast.subjectTwoQuestionCount,
              isFailRisk: forecast.isSubjectTwoFailRisk,
              fillDuration: fillDuration,
            ),
            // 판정 설명 (과락이면 주의 색 + 경고 아이콘)
            if (forecast.detail.isNotEmpty) ...[
              const SizedBox(height: PassqlSpacing.xs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    hasFailRisk
                        ? CupertinoIcons.exclamationmark_triangle_fill
                        : CupertinoIcons.flag,
                    size: PassqlIconSize.sm,
                    color: hasFailRisk
                        ? colors.warningText
                        : colors.iconSecondary,
                  ),
                  const SizedBox(width: PassqlSpacing.xxs),
                  Expanded(
                    child: Text(
                      forecast.detail,
                      style: PassqlTypography.footnote.copyWith(
                        color: hasFailRisk
                            ? colors.warningText
                            : colors.secondaryLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 과목 한 줄: 과목 이름 > 막대(0부터 차오름) > 예상/문항 수
class _SubjectScoreRow extends StatelessWidget {
  const _SubjectScoreRow({
    required this.subjectName,
    required this.expectedCount,
    required this.questionCount,
    required this.isFailRisk,
    required this.fillDuration,
  });

  final String subjectName;
  final int expectedCount;
  final int questionCount;
  final bool isFailRisk;
  final Duration fillDuration;

  // 과목 이름 칸·숫자 칸 폭 (두 줄 막대 시작·끝점을 맞춤, 숫자는 "26/40" 한 줄)
  static const double _subjectNameWidth = 44;
  static const double _countWidth = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final ratio = questionCount == 0 ? 0.0 : expectedCount / questionCount;
    return Row(
      children: [
        SizedBox(
          width: _subjectNameWidth,
          child: Text(
            subjectName,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: fillDuration,
            curve: PassqlMotion.curve,
            builder: (_, animatedRatio, _) => PassqlProgressBar(
              value: animatedRatio,
              fillColor: isFailRisk ? colors.warning : null,
            ),
          ),
        ),
        SizedBox(
          width: _countWidth,
          child: Text(
            '$expectedCount/$questionCount',
            textAlign: TextAlign.end,
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: isFailRisk ? colors.warningText : colors.label,
              fontFeatures: PassqlTypography.tabular,
            ),
          ),
        ),
      ],
    );
  }
}

/// 예상 점수 근거 부족 안내: 모래시계 아이콘 + 서버 문구 (상자 없이 보조 글자 한 줄)
class AiAnalysisForecastHint extends StatelessWidget {
  const AiAnalysisForecastHint({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          CupertinoIcons.hourglass,
          size: PassqlIconSize.sm,
          color: colors.iconSecondary,
        ),
        const SizedBox(width: PassqlSpacing.xs),
        Expanded(
          child: Text(
            hint,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ),
      ],
    );
  }
}
