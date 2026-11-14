import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';
import '../../providers/choice_explanation_providers.dart';
import '../../providers/plan_providers.dart';
import '../question/markdown_lite_text.dart';
import 'ai_explanation_sections.dart';
import 'ai_explanation_verdict.dart';

/// 전체 해설 본문 (패널·단건 결과 공통): 상태별 기다림 > 구조화 섹션 / 마크다운 > 실패 안내·재시도·폴백
/// 무료(결제 켜짐, FULL_EXPLANATION 잠김): 판정 한 줄 > 기본 해설 > 흐린 상세 해설 (판정이 비어 오거나 실패하고 폴백도 없으면 제출 결과로 조립한 판정, #867·#999)
/// [onProUnlock]: 흐린 상세 해설을 누를 때 (null 이면 프로 안내 시트, 잠금화면은 앱을 열어 구매)
class AiExplanationContent extends ConsumerWidget {
  const AiExplanationContent({
    super.key,
    required this.entry,
    this.onProUnlock,
    this.lockedPreviewMaxHeight,
  });

  final AiExplanationEntry entry;
  final VoidCallback? onProUnlock;

  /// 흐린 상세 해설 최대 높이 (null 이면 전체, 잠금화면은 짧게 맛보기)
  final double? lockedPreviewMaxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = choiceExplanationProvider(entry.request);
    final explanationState = ref.watch(provider);
    final structuredExplanation = explanationState.explanation;
    final shouldShowProUi = ref.watch(shouldShowProUiProvider);
    final isFullExplanationLocked =
        explanationState.isFullExplanationLocked && shouldShowProUi;
    // 폴백 순서: 서버 마크다운(옛 해설) > 생성 근거
    final fallbackText = explanationState.hasMarkdownText
        ? explanationState.markdownText
        : entry.rationale;
    // 무료 몫: 조회 응답 > 제출 응답 (정답이면 고른 보기 근거가 곧 정답 근거)
    final basicExplanation =
        explanationState.basicExplanation ??
        entry.request.initialBasicExplanation ??
        (entry.isCorrect ? entry.rationale : null);
    final explanationOutline =
        explanationState.explanationOutline ??
        entry.request.initialExplanationOutline;
    final verdictOnlySections = AiExplanationSections(
      key: const ValueKey('verdictOnly'),
      explanation: verdictOnlyExplanationOf(entry),
      entry: entry,
      isFullExplanationLocked: true,
      basicExplanation: basicExplanation,
      explanationOutline: explanationOutline,
      onProUnlock: onProUnlock,
      lockedPreviewMaxHeight: lockedPreviewMaxHeight,
    );
    final Widget body = switch (explanationState.phase) {
      ChoiceExplanationPhase.loading => _LoadingBody(
        key: const ValueKey('loading'),
        interimText: explanationState.hasMarkdownText
            ? explanationState.markdownText
            : null,
      ),
      ChoiceExplanationPhase.ready when structuredExplanation != null =>
        AiExplanationSections(
          key: const ValueKey('structured'),
          explanation: structuredExplanation,
          entry: entry,
          isFullExplanationLocked: isFullExplanationLocked,
          basicExplanation: basicExplanation,
          explanationOutline: explanationOutline,
          onProUnlock: onProUnlock,
          lockedPreviewMaxHeight: lockedPreviewMaxHeight,
        ),
      // 판정까지 비어 온 무료 응답: 제출 결과로 조립한 판정 + 블러
      ChoiceExplanationPhase.ready when isFullExplanationLocked =>
        verdictOnlySections,
      ChoiceExplanationPhase.ready => MarkdownLiteText(
        key: const ValueKey('markdown'),
        explanationState.markdownText ?? '',
      ),
      // 무료 재제출 실패(근거 폴백 없음): 다시 시도 대신 판정 + 블러 (풀려도 무료 몫은 판정뿐)
      ChoiceExplanationPhase.failed
          when shouldShowVerdictOnlyFor(
            entry,
            shouldShowProUi: shouldShowProUi,
            fallbackText: fallbackText,
          ) =>
        verdictOnlySections,
      ChoiceExplanationPhase.failed => _FailureBody(
        key: const ValueKey('failed'),
        message: explanationState.failureMessage ?? '',
        fallbackText: fallbackText,
        onRetry: () => ref.read(provider.notifier).retry(),
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlFadeSwitcher(alignment: Alignment.topLeft, child: body),
        if (!explanationState.isLoading) const _AiDisclaimer(),
      ],
    );
  }
}

/// 기다리는 중: 옛 해설이 있으면 먼저 보여 주고, 없으면 글 줄 스켈레톤 한 블록
class _LoadingBody extends StatelessWidget {
  const _LoadingBody({super.key, this.interimText});

  final String? interimText;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.sparkles,
              size: PassqlIconSize.xs,
              color: colors.accent,
            ),
            const SizedBox(width: PassqlSpacing.xxs),
            Flexible(
              child: Text(
                interimText == null ? 'AI가 해설을 정리하고 있어요' : '더 자세한 해설을 정리하고 있어요',
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.sm),
        if (interimText != null)
          MarkdownLiteText(interimText!)
        else
          const PassqlTextSkeleton(),
      ],
    );
  }
}

/// 실패: 안내 + 다시 시도 + (있으면) 마크다운 폴백
class _FailureBody extends StatelessWidget {
  const _FailureBody({
    super.key,
    required this.message,
    required this.fallbackText,
    required this.onRetry,
  });

  final String message;
  final String? fallbackText;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final hasFallback = fallbackText?.trim().isNotEmpty ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(PassqlSpacing.sm),
          decoration: BoxDecoration(
            color: colors.fill,
            borderRadius: BorderRadius.circular(PassqlRadius.md),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                size: PassqlIconSize.md,
                color: colors.secondaryLabel,
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Expanded(
                child: Text(
                  message,
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.label,
                  ),
                ),
              ),
              PassqlButton(
                label: PassqlLoadFailureCopy.retryLabel,
                variant: PassqlButtonVariant.plain,
                size: PassqlButtonSize.small,
                isFullWidth: false,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
        if (hasFallback) ...[
          const SizedBox(height: PassqlSpacing.md),
          MarkdownLiteText(fallbackText!),
        ],
      ],
    );
  }
}

/// AI 생성 안내 (모델·버전은 서버 설정이 바뀌면 틀려지므로 고정 문구)
class _AiDisclaimer extends StatelessWidget {
  const _AiDisclaimer();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.only(top: PassqlSpacing.lg),
      child: Text(
        'AI가 만든 해설이에요. 참고용으로 봐 주세요.',
        style: PassqlTypography.caption.copyWith(color: colors.secondaryLabel),
      ),
    );
  }
}
