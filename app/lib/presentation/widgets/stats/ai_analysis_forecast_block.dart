import 'package:flutter/cupertino.dart';

import '../../../data/models/progress/ai_stats_analysis.dart';
import '../../design/design.dart';

/// 예상 점수 묶음 (#862): 머리(예상 점수 + 판정 배지) > 큰 점수(0부터 차오름) > 과목별 막대 2줄 > 판정 설명
/// 과락 위험 과목 막대·설명은 주의 색, 동작 줄이기면 차오름 없이 바로 표시
class AiAnalysisForecastBlock extends StatelessWidget {
  const AiAnalysisForecastBlock({super.key, required this.forecast});

  final AiExamForecast forecast;

  // 만점 표기 (SQLD 100점)
  static const int _maximumScore = 100;

  /// 판정 > 배지 (의미, 아이콘). 모르는 판정은 회색
  static (PassqlBadgeKind kind, IconData? icon) badgeOf(
    AiForecastVerdict verdict,
  ) => switch (verdict) {
    AiForecastVerdict.passLikely => (PassqlBadgeKind.success, null),
    AiForecastVerdict.borderline => (
      PassqlBadgeKind.warning,
      CupertinoIcons.flag_fill,
    ),
    AiForecastVerdict.belowPass => (PassqlBadgeKind.important, null),
    AiForecastVerdict.subjectFailRisk => (
      PassqlBadgeKind.important,
      CupertinoIcons.exclamationmark_triangle_fill,
    ),
    AiForecastVerdict.unknown => (PassqlBadgeKind.neutral, null),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final badge = badgeOf(forecast.verdict);
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
        child: AiAnalysisInsetBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 머리: 예상 점수 + 판정 배지
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
                    PassqlBadge(
                      text: forecast.verdictLabel,
                      kind: badge.$1,
                      icon: badge.$2,
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

  // 과목 이름 칸 폭 (두 줄 막대 시작점을 맞춤)
  static const double _subjectNameWidth = 44;

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
        const SizedBox(width: PassqlSpacing.xs),
        Text(
          '$expectedCount/$questionCount',
          style: PassqlTypography.footnoteSemibold.copyWith(
            color: isFailRisk ? colors.warningText : colors.label,
            fontFeatures: PassqlTypography.tabular,
          ),
        ),
      ],
    );
  }
}

/// 예상 점수 근거 부족 안내: 같은 바탕 상자 + 모래시계 아이콘 + 서버 문구
class AiAnalysisForecastHint extends StatelessWidget {
  const AiAnalysisForecastHint({super.key, required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return AiAnalysisInsetBox(
      child: Row(
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
      ),
    );
  }
}

/// 카드 안 묶음 상자: 화면 바탕색 + 둥근 모서리 (예상 점수·데이터 부족 안내 공용)
class AiAnalysisInsetBox extends StatelessWidget {
  const AiAnalysisInsetBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.passqlColors.background,
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PassqlSpacing.sm),
        child: child,
      ),
    );
  }
}
