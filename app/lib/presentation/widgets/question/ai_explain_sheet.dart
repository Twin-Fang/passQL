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
    final explanationAsync = ref.watch(
      aiExplanationProvider(
        AiExplanationRequest(
          isErrorExplanation: isErrorExplain,
          payload: payload,
        ),
      ),
    );
    return explanationAsync.when(
      loading: () => const SizedBox(
        height: _placeholderHeight,
        child: Center(
          child: PassqlLoadingIndicator(size: PassqlLoadingSize.section),
        ),
      ),
      error: (_, _) => SizedBox(
        height: _placeholderHeight,
        child: Center(
          child: Text(
            'AI 해설을 불러올 수 없어요',
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ),
      ),
      data: (explanationText) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.xs,
          PassqlSpacing.md,
          PassqlSpacing.md,
        ),
        child: MarkdownLiteText(explanationText),
      ),
    );
  }
}
