import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';
import '../../providers/choice_explanation_providers.dart';
import 'ai_explanation_inline_text.dart';
import 'ai_explanation_verdict.dart';

/// 제출 직후 해설 미리보기: 머리(AI 해설 · 전체 보기) > 내 보기 판정 한 줄 > 정답 근거 1줄
/// 카드 전체가 '해설 전체 보기' 버튼. 기다리는 중이면 글 줄 스켈레톤 한 블록, 실패면 다시 시도
class AiExplanationPreviewCard extends ConsumerWidget {
  const AiExplanationPreviewCard({
    super.key,
    required this.entry,
    required this.onOpenFullExplanation,
  });

  final AiExplanationEntry entry;
  final VoidCallback onOpenFullExplanation;

  /// 정답 근거 요약 줄 수
  static const int _reasonPreviewLineCount = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final provider = choiceExplanationProvider(entry.request);
    final explanationState = ref.watch(provider);
    final previewStyle = PassqlTypography.footnote.copyWith(
      color: colors.secondaryLabel,
      height: PassqlTypography.explanationBody.height,
    );
    final Widget body = switch (explanationState.phase) {
      ChoiceExplanationPhase.loading => PassqlTextSkeleton(
        key: const ValueKey('loading'),
        lineCount: _reasonPreviewLineCount,
        textStyle: previewStyle,
      ),
      ChoiceExplanationPhase.ready => _ReadyPreview(
        key: const ValueKey('ready'),
        entry: entry,
        state: explanationState,
        previewStyle: previewStyle,
      ),
      ChoiceExplanationPhase.failed => Row(
        key: const ValueKey('failed'),
        children: [
          Expanded(
            child: Text(
              explanationState.failureMessage ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: previewStyle,
            ),
          ),
          PassqlButton(
            label: '다시 시도',
            variant: PassqlButtonVariant.plain,
            size: PassqlButtonSize.small,
            isFullWidth: false,
            onPressed: () => ref.read(provider.notifier).retry(),
          ),
        ],
      ),
    };
    // 라벨을 따로 주지 않음 > 머리('AI 해설', '전체 보기')·미리보기 글자와 안쪽 다시 시도 버튼을 그대로 읽음
    return PassqlPressable(
      onTap: onOpenFullExplanation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PassqlSpacing.sm),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
          border: Border.all(
            color: colors.separator,
            width: PassqlSize.hairline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreviewHeader(isLoading: explanationState.isLoading),
            const SizedBox(height: PassqlSpacing.xs),
            AnimatedSize(
              duration: PassqlMotion.isReduced(context)
                  ? Duration.zero
                  : PassqlMotion.standard,
              curve: PassqlMotion.curve,
              alignment: Alignment.topCenter,
              // 최소 높이 고정: 해설 길이와 무관하게 하단 피드백 바 높이 일정 (#551)
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: _previewBodyMinHeightOf(context, previewStyle),
                ),
                child: PassqlFadeSwitcher(
                  alignment: Alignment.topLeft,
                  child: body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 미리보기 본문 최소 높이: 판정 1줄 + 간격 + 근거 N줄 (글자 크기 설정 반영)
double _previewBodyMinHeightOf(BuildContext context, TextStyle previewStyle) {
  final textScaler = MediaQuery.textScalerOf(context);
  double lineHeightOf(TextStyle style) =>
      textScaler.scale(style.fontSize ?? 0) * (style.height ?? 1);
  return lineHeightOf(PassqlTypography.subheadlineSemibold) +
      PassqlSpacing.hairlineGap +
      lineHeightOf(previewStyle) *
          AiExplanationPreviewCard._reasonPreviewLineCount;
}

/// 머리: 반짝이 + 'AI 해설' + 오른쪽 '전체 보기 >'
class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      children: [
        Icon(
          CupertinoIcons.sparkles,
          size: PassqlIconSize.xs,
          color: colors.accent,
        ),
        const SizedBox(width: PassqlSpacing.xxs),
        Expanded(
          child: Text(
            isLoading ? 'AI 해설 정리 중' : 'AI 해설',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: colors.accentText,
            ),
          ),
        ),
        Text(
          '전체 보기',
          style: PassqlTypography.footnote.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        Icon(
          CupertinoIcons.chevron_right,
          size: PassqlIconSize.xxs,
          color: colors.tertiaryLabel,
        ),
      ],
    );
  }
}

/// 준비됨: 구조화면 판정 한 줄 + 정답 근거 2줄, 마크다운만 있으면 첫 줄들 요약
class _ReadyPreview extends StatelessWidget {
  const _ReadyPreview({
    super.key,
    required this.entry,
    required this.state,
    required this.previewStyle,
  });

  final AiExplanationEntry entry;
  final ChoiceExplanationState state;
  final TextStyle previewStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final explanation = state.explanation;
    if (explanation == null) {
      return AiExplanationInlineText(
        _plainPreviewOf(state.markdownText ?? ''),
        style: previewStyle,
        maxLines: AiExplanationPreviewCard._reasonPreviewLineCount,
      );
    }
    final verdictColor = explanation.isSelectedCorrect
        ? colors.correctText
        : colors.wrongText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiExplanationInlineText(
          composeAiExplanationVerdict(explanation, entry),
          style: PassqlTypography.subheadlineSemibold.copyWith(
            color: verdictColor,
          ),
          maxLines: 1,
        ),
        if (explanation.correctReason.trim().isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.hairlineGap),
          AiExplanationInlineText(
            explanation.correctReason,
            style: previewStyle,
            maxLines: AiExplanationPreviewCard._reasonPreviewLineCount,
          ),
        ],
      ],
    );
  }

  /// 마크다운 > 한 문단 요약 (목록 기호·빈 줄 제거, 굵게·코드는 남김)
  static String _plainPreviewOf(String markdownText) => markdownText
      .split('\n')
      .map((line) => line.replaceFirst(RegExp(r'^\s*[*-]\s+'), '').trim())
      .where((line) => line.isNotEmpty)
      .join(' ');
}
