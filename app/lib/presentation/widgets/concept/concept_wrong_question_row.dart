import 'package:flutter/cupertino.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import '../question/markdown_lite_text.dart';

/// 틀린 문제 한 줄: 번호 배지 + 지문 한 줄 + 쉐브론. 누르면 그 자리에서 내 답·정답·풀이·다시 읽기가 펼쳐짐.
/// 다시 읽고 돌아오면 배지가 보라 체크, 아래에 "N. 제목 읽음"
class ConceptWrongQuestionRow extends StatelessWidget {
  const ConceptWrongQuestionRow({
    super.key,
    required this.order,
    required this.question,
    required this.result,
    required this.selectedKey,
    required this.rereadLabel,
    required this.isReread,
    required this.isExpanded,
    required this.onToggle,
    required this.onReread,
  });

  // 번호 배지 지름 (펼친 내용의 왼쪽 들여쓰기 기준)
  static const double _badgeSize = 22;

  final int order;
  final ConceptCheckQuestionResponse question;
  final ConceptCheckAnswerResponse result;
  final String? selectedKey;
  final String? rereadLabel;
  final bool isReread;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onReread;

  String? _bodyOf(String? choiceKey) => question.choices
      .where((choice) => choice.choiceKey == choiceKey)
      .firstOrNull
      ?.body;

  @override
  Widget build(BuildContext context) {
    final duration = PassqlMotion.durationOf(context, PassqlMotion.standard);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlPressable(
          semanticLabel:
              '$order번 ${question.stem}, ${isExpanded ? '풀이 접기' : '풀이 펼치기'}',
          onTap: onToggle,
          child: _buildSummaryLine(context, duration),
        ),
        AnimatedSize(
          duration: duration,
          curve: PassqlMotion.curve,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? _buildExpandedDetail(context)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  /// 접힌 줄: 번호(다시 읽었으면 체크) 배지 > 지문(펼치면 전체) > 읽음 표시 > 쉐브론
  Widget _buildSummaryLine(BuildContext context, Duration duration) {
    final colors = context.passqlColors;
    final rereadLabelText = rereadLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoundBadge(
            size: _badgeSize,
            background: isReread ? colors.accentTint : colors.wrongTint,
            child: isReread
                ? Icon(
                    CupertinoIcons.checkmark,
                    size: PassqlIconSize.xxs,
                    color: colors.accentText,
                  )
                : Text(
                    '$order',
                    style: PassqlTypography.captionSemibold.copyWith(
                      color: colors.wrongText,
                      fontFeatures: PassqlTypography.tabular,
                    ),
                  ),
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.stem,
                  maxLines: isExpanded ? null : 1,
                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                  style:
                      (isExpanded
                              ? PassqlTypography.subheadlineSemibold
                              : PassqlTypography.subheadline)
                          .copyWith(color: colors.label),
                ),
                if (isReread && rereadLabelText != null)
                  Text(
                    '$rereadLabelText 읽음',
                    style: PassqlTypography.caption.copyWith(
                      color: colors.accentText,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: PassqlSpacing.xs),
          // 쉐브론: 접힘은 아래(펼쳐진다 예고), 펼침은 위
          AnimatedRotation(
            turns: isExpanded ? -0.25 : 0.25,
            duration: duration,
            curve: PassqlMotion.curve,
            child: Icon(
              CupertinoIcons.chevron_forward,
              size: PassqlIconSize.xs,
              color: colors.tertiaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  /// 펼친 내용: 지문 SQL > 내 답 > 정답 > 풀이 > 다시 읽기
  Widget _buildExpandedDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: _badgeSize + PassqlSpacing.sm,
        bottom: PassqlSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.stemSql != null) ...[
            PassqlCodeBlock(code: question.stemSql!),
            const SizedBox(height: PassqlSpacing.sm),
          ],
          if (selectedKey != null)
            _AnswerLine(
              label: '내 답 $selectedKey',
              body: _bodyOf(selectedKey) ?? '',
              isCorrect: false,
            ),
          const SizedBox(height: PassqlSpacing.xs),
          _AnswerLine(
            label: '정답 ${result.correctKey}',
            body: _bodyOf(result.correctKey) ?? '',
            isCorrect: true,
          ),
          const SizedBox(height: PassqlSpacing.sm),
          MarkdownLiteText(
            result.explanation,
            style: MarkdownLiteStyle.article,
          ),
          if (result.rereadAnchor.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xs),
            _buildRereadButton(context),
          ],
        ],
      ),
    );
  }

  /// 다시 읽기 글자 버튼: 책 아이콘 + "N. 제목 다시 읽기" + 쉐브론
  Widget _buildRereadButton(BuildContext context) {
    final colors = context.passqlColors;
    final rereadLabelText = rereadLabel;
    return PassqlPressable(
      hasMinimumTouchTarget: true,
      onTap: onReread,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.book,
            size: PassqlIconSize.xs,
            color: colors.accentText,
          ),
          const SizedBox(width: PassqlSpacing.xxs),
          Flexible(
            child: Text(
              rereadLabelText == null ? '이 부분 다시 읽기' : '$rereadLabelText 다시 읽기',
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.accentText,
              ),
            ),
          ),
          Icon(
            CupertinoIcons.chevron_forward,
            size: PassqlIconSize.xxs,
            color: colors.accentText,
          ),
        ],
      ),
    );
  }
}

/// 내 답(빨강 ×) · 정답(초록 ✓) 한 줄: 작은 라벨 + 보기 글
class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.body,
    required this.isCorrect,
  });

  final String label;
  final String body;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final foreground = isCorrect ? colors.correctText : colors.wrongText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RoundBadge(
          size: ConceptWrongQuestionRow._badgeSize,
          background: isCorrect ? colors.correctTint : colors.wrongTint,
          child: Icon(
            isCorrect ? CupertinoIcons.checkmark : CupertinoIcons.xmark,
            size: PassqlIconSize.xxs,
            color: foreground,
          ),
        ),
        const SizedBox(width: PassqlSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: PassqlTypography.caption.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              Text(
                body,
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.label,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 작은 원 배지 (번호·×·✓)
class _RoundBadge extends StatelessWidget {
  const _RoundBadge({
    required this.size,
    required this.background,
    required this.child,
  });

  final double size;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: background, shape: BoxShape.circle),
    child: child,
  );
}
