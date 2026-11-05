import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import '../question/markdown_lite_text.dart';
import 'concept_lesson_body.dart';
import 'concept_reading_parser.dart';

/// 맨 끝 한 장 요약 (#848): 꼭 기억할 것(coreMd) 글머리 줄마다 체크 표시 + 한 줄, 차례로 등장
/// 글머리가 아닌 핵심 글은 레슨 블록 그대로
class ConceptLessonRecap extends StatelessWidget {
  const ConceptLessonRecap({super.key, required this.coreMd});

  final String coreMd;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final keyPoints = ConceptReadingParser.parseCoreKeyPoints(coreMd);
    return PassqlSection(
      child: PassqlScrollReveal(
        child: Container(
          padding: const EdgeInsets.all(PassqlSpacing.md),
          decoration: BoxDecoration(
            color: colors.accentTint,
            borderRadius: BorderRadius.circular(PassqlRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.doc_text_fill,
                    size: PassqlIconSize.sm,
                    color: colors.accentText,
                  ),
                  const SizedBox(width: PassqlSpacing.xxs),
                  Text(
                    '한 장 요약',
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.accentText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PassqlSpacing.xs),
              Semantics(
                header: true,
                child: Text(
                  '이것만은 꼭 기억해요',
                  style: PassqlTypography.title3.copyWith(color: colors.label),
                ),
              ),
              const SizedBox(height: PassqlSpacing.sm),
              if (keyPoints.isEmpty)
                ConceptLessonBody(coreMd)
              else
                for (final (index, keyPoint) in keyPoints.indexed) ...[
                  if (index > 0) const SizedBox(height: PassqlSpacing.xs),
                  PassqlScrollReveal(
                    index: index,
                    child: _RecapLine(text: keyPoint),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 요약 한 줄: 체크 아이콘 + 글
class _RecapLine extends StatelessWidget {
  const _RecapLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 본문 첫 줄 높이에 맞춤
        Padding(
          padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
          child: Icon(
            CupertinoIcons.checkmark_alt_circle_fill,
            size: PassqlIconSize.md,
            color: colors.accent,
          ),
        ),
        const SizedBox(width: PassqlSpacing.sm),
        Expanded(
          child: MarkdownLiteText(text, style: MarkdownLiteStyle.article),
        ),
      ],
    );
  }
}
