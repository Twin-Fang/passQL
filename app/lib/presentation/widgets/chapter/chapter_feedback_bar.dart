import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/question/submit_result.dart';
import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';
import '../ai_explanation/ai_explanation_preview_card.dart';
import '../report/report_button.dart';

/// 제출 후 하단 피드백 바.
///
/// 상단: 정답/오답 표시 + 신고 > AI 해설 미리보기(해설이 있을 때)
/// 하단: 다음 문제 / 결과 보기 버튼
class ChapterFeedbackBar extends StatefulWidget {
  final SubmitResult result;
  final String questionUuid;

  /// 정답 보기의 화면 순서 라벨 (없으면 correctKey 표시, #512)
  final String? correctDisplayLabel;

  /// 이 제출의 해설함 항목 (선택지 세트를 모르면 null > 미리보기 없음)
  final AiExplanationEntry? explanationEntry;

  /// 미리보기 '해설 전체 보기'
  final VoidCallback? onOpenExplanation;

  final bool isLastQuestion;
  final VoidCallback onNext;

  const ChapterFeedbackBar({
    super.key,
    required this.result,
    required this.questionUuid,
    this.correctDisplayLabel,
    this.explanationEntry,
    this.onOpenExplanation,
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
    PassqlHaptics.playAnswerResult(isCorrect: _result.isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final explanationEntry = widget.explanationEntry;
    return PassqlBottomActionBar(
      top: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // 결과 문구가 남는 폭을 먼저 차지하고 신고 버튼은 자기 폭만 쓴다.
              Expanded(
                child: PassqlResultMark(
                  isCorrect: _result.isCorrect,
                  label: _result.isCorrect
                      ? '정답이에요'
                      : '오답이에요 · 정답 ${widget.correctDisplayLabel ?? _result.correctKey ?? '-'}',
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
          // 해설 시트가 열려 있으면 같은 내용이라 숨김 (닫히면 다시 표시)
          if (explanationEntry != null)
            Consumer(
              builder: (context, ref, _) {
                final isPanelOpen = ref.watch(
                  aiExplanationSessionProvider.select(
                    (session) => session.isPanelOpen,
                  ),
                );
                if (isPanelOpen) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: PassqlSpacing.xs),
                  child: AiExplanationPreviewCard(
                    entry: explanationEntry,
                    onOpenFullExplanation: widget.onOpenExplanation ?? () {},
                  ),
                );
              },
            ),
        ],
      ),
      actions: [
        PassqlButton(
          label: widget.isLastQuestion ? '결과 보기' : '다음',
          onPressed: widget.onNext,
        ),
      ],
    );
  }
}
