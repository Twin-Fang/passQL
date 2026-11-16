import 'package:flutter/cupertino.dart';

import '../../../core/exam_answer/exam_answer_display_rule.dart';
import '../../../core/exam_answer/exam_grading_rule.dart';
import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../design/design.dart';
import 'exam_answer_concept_links.dart';
import 'exam_answer_status_styles.dart';

/// 가답안 행 1개: 번호 > 개념 한 줄·상태(의미색 글자)·합의율(응답 적으면 응답 수)·내 답 > 정답 > 펼침 화살표, 누르면 보기별 득표·메모·태그·학습 링크
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
    final voteSummary = _voteSummaryOf(item);
    final answerText = _answerTextOf(item);
    final conceptTitle = item.conceptTitle?.trim() ?? '';
    final myAnswerPart = _myAnswerPartOf(colors);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlSemanticButton(
          label:
              '${item.questionNo}번 가답안 $answerText, ${status.label}${voteSummary == null ? '' : ', $voteSummary'}${myAnswerPart == null ? '' : ', ${myAnswerPart.text}'}',
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
                  // 개념 한 줄 > 상태(의미색 글자) | 합의율 | 내 답
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (conceptTitle.isNotEmpty)
                          Text(
                            conceptTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PassqlTypography.subheadline.copyWith(
                              color: colors.label,
                            ),
                          ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: status.label,
                                style: PassqlTypography.footnoteSemibold
                                    .copyWith(
                                      color: status.textColorOf(colors),
                                    ),
                              ),
                              if (voteSummary != null)
                                TextSpan(text: ' | $voteSummary'),
                              if (myAnswerPart != null) ...[
                                const TextSpan(text: ' | '),
                                TextSpan(
                                  text: myAnswerPart.text,
                                  style: TextStyle(color: myAnswerPart.color),
                                ),
                              ],
                            ],
                          ),
                          style: PassqlTypography.footnote.copyWith(
                            fontFeatures: PassqlTypography.tabular,
                            color: colors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: PassqlSpacing.sm),
                  // 정답 숫자
                  Text(
                    answerText,
                    style: PassqlTypography.title3.copyWith(
                      fontFeatures: PassqlTypography.tabular,
                      color: colors.label,
                    ),
                  ),
                  const SizedBox(width: PassqlSpacing.sm),
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

  /// 내 답 글자: 틀림 `내 답 N번`(오답색), 모름·갈림·미확정은 회색. 맞음·채점 전은 null
  ({String text, Color color})? _myAnswerPartOf(PassqlColors colors) {
    final answer = myAnswer;
    if (answer == null) return null;
    if (answer == ExamGradingRule.unknownAnswer) {
      return (text: '내 답 모름', color: colors.secondaryLabel);
    }
    if (!item.answerStatus.isSettled) {
      return (text: '내 답 $answer번', color: colors.secondaryLabel);
    }
    // 맞힌 행은 표시 없음 (틀린 행만 눈에 띄게)
    return item.acceptedAnswers.contains(answer)
        ? null
        : (text: '내 답 $answer번', color: colors.wrongText);
  }

  /// 득표 한 줄: 응답 5명 이상 `합의 80%`, 미만 `응답 2명`, 응답 없으면 null
  static String? _voteSummaryOf(ExamAnswerItemResponse item) {
    if (item.voteCount <= 0) return null;
    if (!ExamAnswerDisplayRule.canShowAgreementRate(item.voteCount)) {
      return '응답 ${item.voteCount}명';
    }
    return '합의 ${(item.agreementRate.clamp(0, 1) * 100).round()}%';
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

/// 펼친 내용: 보기별 득표 4줄(응답 없으면 안내 한 줄) > 메모(회색 한 줄) > 태그 > 개념 학습·문제 풀기 링크
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
    final hasVotes = totalVotes > 0;
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
          // 응답 0명이면 빈 막대 대신 회색 한 줄만 (#1136)
          if (hasVotes)
            for (
              var choice = 1;
              choice <= ExamGradingRule.choiceCount;
              choice++
            )
              _TallyLine(
                choice: choice,
                count: item.votesOf(choice),
                totalVotes: totalVotes,
                isAnswer: item.acceptedAnswers.contains(choice),
                fillColor: item.answerStatus.fillColorOf(colors),
              ),
          Text(
            hasVotes ? '응답 ${item.voteCount}명' : '아직 응답이 없어요',
            style: PassqlTypography.caption.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          // 운영 메모: 상자·아이콘 없이 보조 글자 (카드 안 카드 금지, DEC-0321)
          if (note != null && note.trim().isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xs),
            Text(
              note.trim(),
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
          if (item.conceptTags.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              item.conceptTags.join(', '),
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
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
