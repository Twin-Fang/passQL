import 'package:flutter/widgets.dart';
import '../../../data/models/question/submit_result.dart';
import '../../design/design.dart';
import '../question/ai_explain_sheet.dart';
import '../report/report_button.dart';

/// 제출 후 하단 피드백 바.
///
/// 상단: 정답/오답 표시 + AI 해설 (조건부) + 신고
/// 하단: 다음 문제 / 결과 보기 버튼
class ChapterFeedbackBar extends StatefulWidget {
  final SubmitResult result;
  final String questionUuid;

  /// 사용자가 선택한 선택지 키 (AI diff-explain 요청에 사용).
  final String selectedChoiceKey;

  final bool isLastQuestion;
  final VoidCallback onNext;

  const ChapterFeedbackBar({
    super.key,
    required this.result,
    required this.questionUuid,
    required this.selectedChoiceKey,
    required this.isLastQuestion,
    required this.onNext,
  });

  @override
  State<ChapterFeedbackBar> createState() => _ChapterFeedbackBarState();
}

class _ChapterFeedbackBarState extends State<ChapterFeedbackBar> {
  SubmitResult get _result => widget.result;

  @override
  void initState() {
    super.initState();
    // 채점 결과가 처음 나타날 때 한 번만 손끝으로 알려 준다.
    if (_result.isCorrect) {
      PqHaptics.correct();
    } else {
      PqHaptics.wrong();
    }
  }

  /// EXECUTABLE 모드 여부 — correctSql 또는 correctResult 존재 시 EXECUTABLE로 판단.
  bool get _isExecutable =>
      _result.correctSql != null || _result.correctResult != null;

  /// AI 해설 버튼 표시 조건:
  /// - 오답: 항상 표시
  /// - 정답 + CONCEPT_ONLY: 표시
  /// - 정답 + EXECUTABLE: 표시하지 않음
  bool get _showAiButton => !_result.isCorrect || !_isExecutable;

  @override
  Widget build(BuildContext context) {
    return PqBottomActionBar(
      top: Row(
        children: [
          Flexible(
            child: PqResultMark(
              correct: _result.isCorrect,
              label: _result.isCorrect
                  ? '정답이에요'
                  : '오답이에요 · 정답 ${_result.correctKey ?? '-'}',
            ),
          ),
          const Spacer(),
          if (_showAiButton)
            PqButton(
              label: 'AI 해설',
              variant: PqButtonVariant.plain,
              size: PqButtonSize.small,
              expand: false,
              onPressed: () => AiExplainSheet.show(
                context,
                payload: {
                  'questionUuid': widget.questionUuid,
                  'selectedChoiceKey': widget.selectedChoiceKey,
                },
                isErrorExplain: false,
              ),
            ),
          // 신고는 어떤 제출인지 알아야 하므로 제출 UUID 가 있을 때만 보여준다.
          if (_result.submissionUuid != null)
            ReportButton(
              questionUuid: widget.questionUuid,
              submissionUuid: _result.submissionUuid!,
              choiceSetUuid: _result.choiceSetUuid,
            ),
        ],
      ),
      actions: [
        PqButton(
          label: widget.isLastQuestion ? '결과 보기' : '다음',
          onPressed: widget.onNext,
        ),
      ],
    );
  }
}
