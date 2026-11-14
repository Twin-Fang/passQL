import 'package:flutter/cupertino.dart';

import '../../../core/exam_answer/exam_grading_rule.dart';
import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../design/design.dart';
import 'exam_answer_concept_links.dart';
import 'exam_answer_status_styles.dart';

/// 가답안 행 1개: 번호 > 정답 > 상태 > 합의율 막대 > 내 답 정오, 누르면 보기별 득표·메모·개념 펼침
class ExamAnswerKeyRow extends StatelessWidget {
  const ExamAnswerKeyRow({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    this.myAnswer,
  });

  final ExamAnswerItemResponse item;
  final bool isExpanded;
  final VoidCallback onToggle;

  /// 채점한 내 답 (1~4, 0 모름, 채점 전이면 null)
  final int? myAnswer;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final status = item.answerStatus;
    final agreementPercent = (item.agreementRate.clamp(0, 1) * 100).round();
    final answerText = _answerTextOf(item);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlSemanticButton(
          label:
              '${item.questionNo}번 가답안 $answerText, ${status.label}, 합의율 $agreementPercent%',
          isSelected: isExpanded,
          onTap: onToggle,
          child: PassqlPressable(
            onTap: onToggle,
            isTapExposedToScreenReader: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PassqlSpacing.md,
                vertical: PassqlSpacing.sm,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: PassqlSize.examAnswerNumberColumn,
                    child: Text(
                      '${item.questionNo}',
                      style: PassqlTypography.subheadlineSemibold.copyWith(
                        fontFeatures: PassqlTypography.tabular,
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ),
                  // 정답 숫자 (상태 의미색)
                  SizedBox(
                    width: PassqlSize.examAnswerOmrBubble,
                    child: Text(
                      answerText,
                      style: PassqlTypography.title3.copyWith(
                        fontFeatures: PassqlTypography.tabular,
                        color: status.textColorOf(colors),
                      ),
                    ),
                  ),
                  PassqlBadge(
                    text: status.label,
                    kind: status.badgeKind,
                    icon: status.badgeIcon,
                  ),
                  const Spacer(),
                  // 합의율 막대 + %
                  SizedBox(
                    width: PassqlSize.examAnswerAgreementBarWidth,
                    child: PassqlProgressBar(
                      value: item.agreementRate,
                      fillColor: status.fillColorOf(colors),
                    ),
                  ),
                  const SizedBox(width: PassqlSpacing.xs),
                  SizedBox(
                    width: PassqlSize.examAnswerOmrBubble,
                    child: Text(
                      item.voteCount == 0 ? '-' : '$agreementPercent%',
                      textAlign: TextAlign.end,
                      style: PassqlTypography.footnote.copyWith(
                        fontFeatures: PassqlTypography.tabular,
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ),
                  if (myAnswer != null) ...[
                    const SizedBox(width: PassqlSpacing.xs),
                    _MyAnswerMark(item: item, myAnswer: myAnswer!),
                  ],
                  const SizedBox(width: PassqlSpacing.xxs),
                  AnimatedRotation(
                    turns: isExpanded ? _expandedChevronTurns : 0,
                    duration: PassqlMotion.durationOf(
                      context,
                      PassqlMotion.fast,
                    ),
                    curve: PassqlMotion.curve,
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      size: PassqlIconSize.xs,
                      color: colors.tertiaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
          curve: PassqlMotion.curve,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? _ExpandedDetail(item: item)
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  // 펼침 화살표 회전 (반 바퀴)
  static const double _expandedChevronTurns = 0.5;

  /// 정답 표기: `3`, 복수 정답 `2, 3`, 없으면 `-`
  static String _answerTextOf(ExamAnswerItemResponse item) {
    final answer = item.answer;
    if (answer == null) return '-';
    final answers = item.acceptedAnswers.toList()..sort();
    return answers.join(', ');
  }
}

/// 내 답 정오: 맞음 초록 체크, 틀림 빨강 엑스, 갈림·미확정은 내 답 숫자만
class _MyAnswerMark extends StatelessWidget {
  const _MyAnswerMark({required this.item, required this.myAnswer});

  final ExamAnswerItemResponse item;
  final int myAnswer;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isAnswered = myAnswer != ExamGradingRule.unknownAnswer;
    final isMatched = isAnswered && item.acceptedAnswers.contains(myAnswer);
    if (isAnswered && !item.answerStatus.isSettled) {
      return Text(
        '$myAnswer',
        style: PassqlTypography.footnoteSemibold.copyWith(
          color: colors.secondaryLabel,
        ),
      );
    }
    return Icon(
      isMatched
          ? CupertinoIcons.checkmark_circle_fill
          : CupertinoIcons.xmark_circle_fill,
      size: PassqlIconSize.md,
      color: isMatched ? colors.correct : colors.wrong,
    );
  }
}

/// 펼친 내용: 보기별 득표 4줄 > 메모 > 출제 개념·태그 > 개념 학습·문제 풀기
class _ExpandedDetail extends StatelessWidget {
  const _ExpandedDetail({required this.item});

  final ExamAnswerItemResponse item;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final note = item.note;
    final totalVotes = [
      for (var choice = 1; choice <= ExamGradingRule.choiceCount; choice++)
        item.votesOf(choice),
    ].fold<int>(0, (sum, count) => sum + count);
    final conceptTitle = item.conceptTitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md + PassqlSize.examAnswerNumberColumn,
        0,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var choice = 1; choice <= ExamGradingRule.choiceCount; choice++)
            _TallyLine(
              choice: choice,
              count: item.votesOf(choice),
              totalVotes: totalVotes,
              isAnswer: item.acceptedAnswers.contains(choice),
              fillColor: item.answerStatus.fillColorOf(colors),
            ),
          Text(
            '응답 ${item.voteCount}명',
            style: PassqlTypography.caption.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          if (note != null && note.trim().isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.sm),
            PassqlCallout(
              kind: PassqlCalloutKind.warning,
              icon: CupertinoIcons.exclamationmark_bubble_fill,
              label: '메모',
              child: Text(
                note.trim(),
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.label,
                ),
              ),
            ),
          ],
          if (conceptTitle != null && conceptTitle.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              conceptTitle,
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.label,
              ),
            ),
          ],
          if (item.conceptTags.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xxs),
            Wrap(
              spacing: PassqlSpacing.xxs,
              runSpacing: PassqlSpacing.xxs,
              children: [
                for (final tag in item.conceptTags)
                  PassqlBadge(text: tag, kind: PassqlBadgeKind.neutral),
              ],
            ),
          ],
          const SizedBox(height: PassqlSpacing.sm),
          ExamAnswerConceptLinks(topicCode: item.topicCode),
        ],
      ),
    );
  }
}

/// 보기 1개 득표 줄: 번호 > 막대(정답이면 상태색, 아니면 회색) > 명·%
class _TallyLine extends StatelessWidget {
  const _TallyLine({
    required this.choice,
    required this.count,
    required this.totalVotes,
    required this.isAnswer,
    required this.fillColor,
  });

  final int choice;
  final int count;
  final int totalVotes;
  final bool isAnswer;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final rate = totalVotes == 0 ? 0.0 : count / totalVotes;
    return Padding(
      padding: const EdgeInsets.only(bottom: PassqlSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: PassqlSize.examAnswerNumberColumn,
            child: Text(
              '$choice번',
              style: PassqlTypography.footnoteSemibold.copyWith(
                color: isAnswer ? colors.label : colors.secondaryLabel,
              ),
            ),
          ),
          Expanded(
            child: PassqlProgressBar(
              value: rate,
              fillColor: isAnswer ? fillColor : colors.iconSecondary,
              semanticValue: '$count명',
            ),
          ),
          const SizedBox(width: PassqlSpacing.xs),
          SizedBox(
            width: PassqlSize.examAnswerTallyLabelWidth,
            child: Text(
              '${(rate * 100).round()}% | $count',
              textAlign: TextAlign.end,
              style: PassqlTypography.caption.copyWith(
                fontFeatures: PassqlTypography.tabular,
                color: colors.secondaryLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
