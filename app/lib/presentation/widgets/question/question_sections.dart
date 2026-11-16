import 'package:flutter/cupertino.dart';
import '../../../core/utils/question_difficulty.dart';
import '../../../data/models/question/question_detail.dart';
import '../../../data/models/question/question_schema_table.dart';
import '../../../data/models/question/sse_event.dart';
import '../../providers/question_providers.dart';
import '../../design/design.dart';
import 'question_figure.dart';
import 'stem_text.dart';

// 챕터 풀이(ChapterPage)와 단건 풀이(QuestionDetailPage)가 함께 쓰는 문제 화면 조각.

/// 회색 메타 한 줄(난이도 단계 | 문제 유형 | 최신 경향) + (있으면) 소주제 제목.
/// 별점·칩 없이 보조 글자 한 줄 (DEC-0116, #1136, #1145)
class QuestionHeader extends StatelessWidget {
  final QuestionDetail question;
  const QuestionHeader({super.key, required this.question});

  /// 메타 한 줄: "보통 | 개념 문제 | 최신 경향" (난이도 없으면 생략, 최신 경향 반영 문제만 끝 항목, #523)
  static String metaLineOf(QuestionDetail question) => [
    ?toDifficultyLabel(question.difficulty),
    question.executionMode == 'EXECUTABLE' ? '실행 결과 문제' : '개념 문제',
    if (question.isLatestTrend) '최신 경향',
  ].join(' | ');

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final title = question.subtopicName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metaLineOf(question),
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          if (title != null && title.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xs),
            Text(
              title,
              style: PassqlTypography.title3.copyWith(color: colors.label),
            ),
          ],
        ],
      ),
    );
  }
}

/// 문제 지문 카드 (스키마 표도 카드 안 표 자리에, #903), 그림 있으면 지문 아래 (#1132)
/// 풀이·모의고사·잠금화면 공통
class QuestionStem extends StatelessWidget {
  final String stem;
  final List<QuestionSchemaTable> schemaTables;

  /// 지문 아래 그림 SVG (없으면 null)
  final String? figureSvg;
  const QuestionStem({
    super.key,
    required this.stem,
    this.schemaTables = const [],
    this.figureSvg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.xs,
      ),
      child: PassqlCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StemText(stem, schemaTables: schemaTables),
            if (figureSvg case final figure? when figure.isNotEmpty) ...[
              const SizedBox(height: PassqlSpacing.md),
              QuestionFigure(figureSvg: figure),
            ],
          ],
        ),
      ),
    );
  }
}

/// 선택지 생성 실패 안내.
class QuestionSseError extends StatelessWidget {
  final SseErrorEvent error;
  final VoidCallback? onRetry;

  const QuestionSseError({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.xs,
      ),
      child: PassqlCard(
        child: Row(
          children: [
            const Expanded(
              child: PassqlResultMark(isCorrect: false, label: '선택지를 만들지 못했어요'),
            ),
            if (onRetry != null)
              PassqlButton(
                label: PassqlLoadFailureCopy.retryLabel,
                onPressed: onRetry,
                variant: PassqlButtonVariant.plain,
                size: PassqlButtonSize.small,
                isFullWidth: false,
              ),
          ],
        ),
      ),
    );
  }
}

/// 제출 전 하단 바. 선택지를 고르고 선택지 세트가 있을 때만 활성화된다.
class QuestionSubmitBar extends StatelessWidget {
  final QuestionInteractionState interaction;
  final VoidCallback onSubmit;

  const QuestionSubmitBar({
    super.key,
    required this.interaction,
    required this.onSubmit,
  });

  bool get _canSubmit =>
      interaction.selectedChoiceKey != null &&
      interaction.activeChoiceSetId != null &&
      !interaction.isSubmitting;

  @override
  Widget build(BuildContext context) {
    return PassqlBottomActionBar(
      actions: [
        PassqlButton(
          label: '제출',
          onPressed: _canSubmit ? onSubmit : null,
          isLoading: interaction.isSubmitting,
        ),
      ],
    );
  }
}
