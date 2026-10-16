import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/ai_providers.dart';
import 'markdown_lite_text.dart';

/// AI 해설 바텀시트. questionUuid와 요청 payload를 받아 AI 해설을 표시.
/// isErrorExplain=true: explain-error 엔드포인트
/// isErrorExplain=false: diff-explain 엔드포인트
class AiExplainSheet extends ConsumerWidget {
  final Map<String, dynamic> payload;
  final bool isErrorExplain;

  const AiExplainSheet({
    super.key,
    required this.payload,
    required this.isErrorExplain,
  });

  /// 본문이 없을 때(로딩·오류)도 시트가 납작해지지 않게 두는 최소 높이
  static const double _placeholderHeight = 200;

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> payload,
    required bool isErrorExplain,
  }) {
    // 손잡이·제목·닫기는 공용 시트가 그린다.
    return showPassqlSheet<void>(
      context,
      title: 'AI 해설',
      builder: (_) =>
          AiExplainSheet(payload: payload, isErrorExplain: isErrorExplain),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final request = AiExplanationRequest(
      isErrorExplanation: isErrorExplain,
      payload: payload,
    );
    final explanationAsync = ref.watch(aiExplanationProvider(request));
    final Widget content = explanationAsync.when(
      loading: () => const _AiExplanationSkeleton(key: ValueKey('loading')),
      error: (_, _) => ConstrainedBox(
        key: const ValueKey('error'),
        constraints: const BoxConstraints(minHeight: _placeholderHeight),
        child: PassqlStatusView.error(
          message: 'AI 해설을 불러올 수 없어요',
          onRetry: () => ref.invalidate(aiExplanationProvider(request)),
        ),
      ),
      data: (explanationText) => SingleChildScrollView(
        key: const ValueKey('data'),
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.xs,
          PassqlSpacing.md,
          PassqlSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PassqlPopIn(
              child: PassqlBadge(text: 'AI가 만든 해설', kind: PassqlBadgeKind.ai),
            ),
            const SizedBox(height: PassqlSpacing.sm),
            MarkdownLiteText(explanationText, isAnimated: true),
          ],
        ),
      ),
    );
    // 로딩 > 본문으로 바뀔 때 시트 높이가 툭 변하지 않게 크기와 내용을 함께 전환
    return AnimatedSize(
      duration: PassqlMotion.standard,
      curve: PassqlMotion.curve,
      alignment: Alignment.topCenter,
      child: ColoredBox(
        color: colors.cardElevated,
        child: PassqlFadeSwitcher(child: content),
      ),
    );
  }
}

/// AI 해설을 기다리는 자리: 반짝이 맥박 + 글 줄 스켈레톤
class _AiExplanationSkeleton extends StatelessWidget {
  const _AiExplanationSkeleton({super.key});

  static const double _lineHeight = 12;
  static const List<double> _lineWidthFactors = [1, 0.92, 0.83, 0.67];

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xs,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.sparkles,
                size: PassqlIconSize.md,
                color: colors.accent,
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Text(
                'AI가 해설을 쓰고 있어요',
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.md),
          for (final widthFactor in _lineWidthFactors) ...[
            FractionallySizedBox(
              widthFactor: widthFactor,
              child: const PassqlSkeletonBox(height: _lineHeight),
            ),
            const SizedBox(height: PassqlSpacing.xs),
          ],
        ],
      ),
    );
  }
}
