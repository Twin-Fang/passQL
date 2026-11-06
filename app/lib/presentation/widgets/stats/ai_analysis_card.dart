import 'package:flutter/cupertino.dart';

import '../../../core/utils/profile_pass_values.dart';
import '../../../data/models/progress/ai_comment_response.dart';
import '../../../data/models/progress/ai_stats_analysis.dart';
import '../../design/design.dart';
import '../pro/locked_preview_samples.dart';
import '../pro/pro_locked_section.dart';
import '../question/markdown_lite_text.dart';
import 'ai_analysis_action_buttons.dart';
import 'ai_analysis_finding_row.dart';
import 'ai_analysis_forecast_block.dart';
import 'ai_analysis_readiness_block.dart';

/// AI 영역 분석 구간 (#749 구간형): 반짝이 머리(+ 판정 기간) + 본문 + 아래 작은 분석 시각
/// 본문: 구조화 분석(#861) 있으면 진단·예상 점수·약한 토픽·다음 할 일, 없으면 글 코멘트(단어 순차 등장). aiComment 가 null 이면 숨김
class AiAnalysisCard extends StatelessWidget {
  final AiCommentResponse? aiComment;

  const AiAnalysisCard({super.key, required this.aiComment});

  @override
  Widget build(BuildContext context) {
    final comment = aiComment?.comment;
    if (comment == null) return const SizedBox.shrink();
    final analysis = aiComment?.analysis;
    final analyzedLabel = aiAnalyzedLabel(aiComment?.generatedAt);
    final periodLabel = analysis?.periodLabel ?? '';

    return PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 판정 기간: 통계 토픽 표(최근 7일)와 숫자가 달라 보이는 이유를 머리에서 밝힘 (#862)
          PassqlAiHeader(
            title: 'AI 분석',
            trailing: periodLabel.isEmpty
                ? null
                : Text(
                    periodLabel,
                    style: PassqlTypography.caption.copyWith(
                      color: context.passqlColors.secondaryLabel,
                    ),
                  ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          if (analysis != null)
            _AiStatsAnalysisBody(analysis: analysis)
          else
            // AI 코멘트의 `토픽명` 같은 마크다운 기호를 강조 표시로 바꿔 보여 준다.
            MarkdownLiteText(comment, isAnimated: true),
          if (analyzedLabel != null) ...[
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              analyzedLabel,
              style: PassqlTypography.caption.copyWith(
                color: context.passqlColors.secondaryLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 구조화 분석 본문: 한 줄 진단 > 데이터 부족 안내 > 예상 점수(또는 남은 문제 안내) > 약한 토픽 최대 2
/// > 반복 오답·추세·강점·다음 목표 한 줄씩 > 바로 풀기 버튼. 묶음마다 순서대로 등장
class _AiStatsAnalysisBody extends StatelessWidget {
  const _AiStatsAnalysisBody({required this.analysis});

  final AiStatsAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final readiness = analysis.readiness;
    final forecast = analysis.forecast;
    final forecastHint = analysis.forecastHint;
    final strength = analysis.strength;
    final noteLines = [
      if (analysis.repeatedWrong case final repeatedWrong?)
        _AiAnalysisNoteLine(
          icon: CupertinoIcons.arrow_2_circlepath,
          text: repeatedWrong.text,
        ),
      if (analysis.trend case final trend?)
        _AiAnalysisNoteLine(icon: CupertinoIcons.chart_bar, text: trend),
      if (strength != null)
        _AiAnalysisNoteLine(
          icon: CupertinoIcons.star,
          text: '강점 · ${strength.topicName} ${strength.correctRatePercent}%',
        ),
      if (analysis.nextGoal case final nextGoal?)
        _AiAnalysisNoteLine(icon: CupertinoIcons.scope, text: nextGoal),
    ];
    final blocks = [
      // 한 줄 진단 (D-day·과락 위험 등, 서버 문구 그대로)
      if (analysis.headline.isNotEmpty)
        Text(
          analysis.headline,
          style: PassqlTypography.headline.copyWith(color: colors.label),
        ),
      if (readiness != null) AiAnalysisReadinessBlock(readiness: readiness),
      if (forecast != null)
        AiAnalysisForecastBlock(forecast: forecast)
      else if (forecastHint != null && forecastHint.isNotEmpty)
        AiAnalysisForecastHint(hint: forecastHint),
      for (final finding in analysis.findings)
        AiAnalysisFindingRow(finding: finding),
      if (noteLines.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < noteLines.length; index++) ...[
              if (index > 0) const SizedBox(height: PassqlSpacing.xxs),
              noteLines[index],
            ],
          ],
        ),
      AiAnalysisActionButtons(actions: analysis.actions),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: passqlRevealInOrder([
        for (var index = 0; index < blocks.length; index++) ...[
          if (index > 0 && blocks[index] is! AiAnalysisActionButtons)
            const SizedBox(height: PassqlSpacing.md),
          blocks[index],
        ],
      ]),
    );
  }
}

/// 보조 한 줄: 아이콘 + 보조 글자 (반복 오답·추세·강점·다음 목표)
class _AiAnalysisNoteLine extends StatelessWidget {
  const _AiAnalysisNoteLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: PassqlIconSize.sm, color: colors.iconSecondary),
        const SizedBox(width: PassqlSpacing.xxs),
        Expanded(
          child: Text(
            text,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ),
      ],
    );
  }
}

/// 무료(결제 켜짐) AI 분석 자리: 같은 머리 + 잠금 미리보기 (AI 코멘트 프로 전용, #860)
class AiAnalysisLockedSection extends StatelessWidget {
  const AiAnalysisLockedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PassqlAiHeader(title: 'AI 분석'),
          SizedBox(height: PassqlSpacing.sm),
          ProLockedSection(
            preview: AiAnalysisLockedSample(),
            caption: LockedPreviewCaptions.aiAnalysis,
          ),
        ],
      ),
    );
  }
}

/// AI 분석 실패 자리 (#862): 같은 머리 + 안내 한 줄 + 다시 시도 (조용히 사라지면 프로 기능이 없는 줄 앎)
class AiAnalysisErrorSection extends StatelessWidget {
  const AiAnalysisErrorSection({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PassqlAiHeader(title: 'AI 분석'),
          const SizedBox(height: PassqlSpacing.sm),
          Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: PassqlIconSize.sm,
                color: colors.iconSecondary,
              ),
              const SizedBox(width: PassqlSpacing.xxs),
              Expanded(
                child: Text(
                  '분석을 불러오지 못했어요',
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ),
              PassqlButton(
                label: '다시 시도',
                onPressed: onRetry,
                variant: PassqlButtonVariant.tinted,
                size: PassqlButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
