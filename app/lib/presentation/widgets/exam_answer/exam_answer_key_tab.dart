import 'package:flutter/cupertino.dart';

import '../../../core/exam_answer/exam_answer_grader.dart';
import '../../../core/exam_answer/exam_grading_rule.dart';
import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../design/design.dart';
import 'exam_answer_key_row.dart';

/// 가답안 표 보기 2개: 전체, 갈림·미확정만
enum _KeyFilter { all, unsettled }

/// 가답안 탭: 보기 고르기(전체, 갈림) > 과목별 문항 목록 (상태는 행 안 의미색 글자)
class ExamAnswerKeyTab extends StatefulWidget {
  const ExamAnswerKeyTab({
    super.key,
    required this.items,
    required this.gradingRule,
    this.myAnswers,
    this.shouldShowVotes = true,
  });

  final List<ExamAnswerItemResponse> items;

  /// 과목 묶음 기준 (회차 채점 규칙)
  final ExamGradingRule gradingRule;

  /// 채점한 내 답안 50자 (채점 전이면 null > 행에 정오 표시 없음)
  final String? myAnswers;

  /// 득표·합의율 표시 (지난 회차 정답 확정은 false, #1151)
  final bool shouldShowVotes;

  @override
  State<ExamAnswerKeyTab> createState() => _ExamAnswerKeyTabState();
}

class _ExamAnswerKeyTabState extends State<ExamAnswerKeyTab> {
  _KeyFilter _filter = _KeyFilter.all;
  final Set<int> _expandedQuestionNos = {};

  void _toggle(int questionNo) => setState(() {
    if (!_expandedQuestionNos.remove(questionNo)) {
      _expandedQuestionNos.add(questionNo);
    }
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: PassqlSpacing.md),
        if (visibleItems.isEmpty)
          PassqlStatusView.empty(
            icon: CupertinoIcons.checkmark_seal,
            title: '갈린 문항이 없어요',
          )
        else
          for (final subject in widget.gradingRule.subjects)
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
                        shouldShowVotes: widget.shouldShowVotes,
                        myAnswer: myAnswers == null
                            ? null
                            : ExamAnswerGrader.answerAt(
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
