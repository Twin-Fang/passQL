import 'package:flutter/cupertino.dart';

import '../../../core/exam_answer/sqld_answer_grader.dart';
import '../../../core/exam_answer/sqld_scoring_rule.dart';
import '../../../data/models/exam_answer/exam_answer_enums.dart';
import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../design/design.dart';
import 'exam_answer_key_row.dart';
import 'exam_answer_status_styles.dart';

/// 가답안 표 보기 2개: 전체, 갈림·미확정만
enum _KeyFilter { all, unsettled }

/// 가답안 탭: 보기 고르기(전체·갈림) > 상태 색 범례 > 과목별 문항 표
class ExamAnswerKeyTab extends StatefulWidget {
  const ExamAnswerKeyTab({super.key, required this.items, this.myAnswers});

  final List<ExamAnswerItem> items;

  /// 채점한 내 답안 50자 (채점 전이면 null > 행에 정오 표시 없음)
  final String? myAnswers;

  @override
  State<ExamAnswerKeyTab> createState() => _ExamAnswerKeyTabState();
}

class _ExamAnswerKeyTabState extends State<ExamAnswerKeyTab> {
  _KeyFilter _filter = _KeyFilter.all;
  final Set<int> _expandedQuestionNos = {};

  // 범례 순서 (공식·확정은 같은 초록이라 하나로)
  static const List<ExamAnswerItemStatus> _legendStatuses = [
    ExamAnswerItemStatus.confirmed,
    ExamAnswerItemStatus.leading,
    ExamAnswerItemStatus.disputed,
    ExamAnswerItemStatus.undecided,
  ];

  void _toggle(int questionNo) => setState(() {
    if (!_expandedQuestionNos.remove(questionNo)) {
      _expandedQuestionNos.add(questionNo);
    }
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final unsettledCount = widget.items
        .where((item) => !item.answerStatus.isSettled)
        .length;
    final visibleItems = _filter == _KeyFilter.all
        ? widget.items
        : widget.items.where((item) => !item.answerStatus.isSettled).toList();
    final myAnswers = widget.myAnswers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlSegmentedControl<_KeyFilter>(
          segments: [
            const PassqlSegment(value: _KeyFilter.all, label: '전체 50문항'),
            PassqlSegment(
              value: _KeyFilter.unsettled,
              label: '갈림, 미확정 $unsettledCount',
            ),
          ],
          selectedValue: _filter,
          onSelected: (filter) => setState(() => _filter = filter),
        ),
        const SizedBox(height: PassqlSpacing.sm),
        // 상태 색 범례
        Wrap(
          spacing: PassqlSpacing.md,
          runSpacing: PassqlSpacing.xxs,
          children: [
            for (final status in _legendStatuses)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.circle_fill,
                    size: PassqlIconSize.xxs,
                    color: status.fillColorOf(colors),
                  ),
                  const SizedBox(width: PassqlSpacing.xxs),
                  Text(
                    status == ExamAnswerItemStatus.confirmed
                        ? '공식, 확정'
                        : status.label,
                    style: PassqlTypography.caption.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.md),
        if (visibleItems.isEmpty)
          PassqlStatusView.empty(
            icon: CupertinoIcons.checkmark_seal,
            title: '갈린 문항이 없어요',
          )
        else
          for (final subject in SqldScoringRule.subjects)
            if (visibleItems.any(
              (item) => subject.containsQuestion(item.questionNo),
            )) ...[
              PassqlGroupedSection(
                header: '${subject.subjectNo}과목 ${subject.name}',
                separatorIndent: 0,
                children: [
                  for (final item in visibleItems)
                    if (subject.containsQuestion(item.questionNo))
                      ExamAnswerKeyRow(
                        item: item,
                        isExpanded: _expandedQuestionNos.contains(
                          item.questionNo,
                        ),
                        onToggle: () => _toggle(item.questionNo),
                        myAnswer: myAnswers == null
                            ? null
                            : SqldAnswerGrader.answerAt(
                                myAnswers,
                                item.questionNo,
                              ),
                      ),
                ],
              ),
              const SizedBox(height: PassqlSpacing.lg),
            ],
      ],
    );
  }
}
