import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exam_answer/exam_answer_score_report.dart';
import '../../../core/exam_answer/sqld_scoring_rule.dart';
import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../design/design.dart';
import '../../providers/exam_answer_providers.dart';
import 'exam_answer_concept_sheet.dart';
import 'exam_answer_omr_sheet.dart';
import 'exam_answer_round_summary.dart';
import 'exam_answer_score_result.dart';
import 'exam_answer_share_sheet.dart';

/// 내 가채점 탭: 불러오는 중 > OMR 입력(채점 버튼은 화면 하단 바) 또는 결과(공유·답안 수정·틀린 문항 복습)
class ExamAnswerMyScoreTab extends ConsumerWidget {
  const ExamAnswerMyScoreTab({
    super.key,
    required this.roundKey,
    required this.roundResponse,
  });

  final ExamAnswerRoundKey roundKey;
  final ExamAnswerRoundResponse roundResponse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheetState = ref.watch(examAnswerSheetProvider(roundKey));
    final notifier = ref.read(examAnswerSheetProvider(roundKey).notifier);
    final gradedSheet = sheetState.gradedSheet;
    if (!sheetState.isLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: PassqlSpacing.xxl),
        child: PassqlLoadingIndicator(size: PassqlLoadingSize.section),
      );
    }
    if (!sheetState.isEditing && gradedSheet != null) {
      return _ResultView(
        roundKey: roundKey,
        roundResponse: roundResponse,
        report: gradedSheet.report,
        onEdit: notifier.startEditing,
      );
    }
    return _OmrView(
      sheetState: sheetState,
      onAnswerSelected: notifier.selectAnswer,
      onShowPreviousResult: gradedSheet != null && !sheetState.isGradeOutdated
          ? notifier.showResult
          : null,
    );
  }
}

/// OMR 입력: 안내 > 입력 진행 막대 > OMR 표
class _OmrView extends StatelessWidget {
  const _OmrView({
    required this.sheetState,
    required this.onAnswerSelected,
    this.onShowPreviousResult,
  });

  final ExamAnswerSheetState sheetState;
  final void Function(int questionNo, int choice) onAnswerSelected;

  /// 고친 답이 없을 때 이전 결과로 돌아가기 (null 이면 버튼 없음)
  final VoidCallback? onShowPreviousResult;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final enteredCount = sheetState.enteredCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '시험지에 표시한 답을 옮겨 주세요',
          style: PassqlTypography.headline.copyWith(color: colors.label),
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        Text(
          '누를 때마다 이 기기에 저장돼요. 기억나지 않으면 모름을 눌러 주세요.',
          style: PassqlTypography.subheadline.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        const SizedBox(height: PassqlSpacing.md),
        Row(
          children: [
            Expanded(
              child: PassqlProgressBar(
                value: enteredCount / SqldScoringRule.questionCount,
                fillColor: sheetState.isComplete ? colors.correct : null,
              ),
            ),
            const SizedBox(width: PassqlSpacing.sm),
            Text(
              '$enteredCount / ${SqldScoringRule.questionCount}',
              style: PassqlTypography.footnoteSemibold.copyWith(
                fontFeatures: PassqlTypography.tabular,
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
        if (onShowPreviousResult != null) ...[
          const SizedBox(height: PassqlSpacing.sm),
          PassqlButton(
            label: '이전 채점 결과 보기',
            variant: PassqlButtonVariant.plain,
            size: PassqlButtonSize.small,
            onPressed: onShowPreviousResult,
          ),
        ],
        const SizedBox(height: PassqlSpacing.lg),
        ExamAnswerOmrSheet(
          answers: sheetState.answers,
          onAnswerSelected: onAnswerSelected,
        ),
      ],
    );
  }
}

/// 결과: 점수 > 공유·답안 수정 > 갈림 안내 > 틀린 문항 복습
class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.roundKey,
    required this.roundResponse,
    required this.report,
    required this.onEdit,
  });

  final ExamAnswerRoundKey roundKey;
  final ExamAnswerRoundResponse roundResponse;
  final ExamAnswerScoreReport report;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final itemByQuestionNo = {
      for (final item in roundResponse.items) item.questionNo: item,
    };
    final wrongMarks = report.wrongMarks;
    final unsettledCount = report.questionMarks
        .where((mark) => mark.isCorrect == null)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExamAnswerScoreResult(report: report),
        const SizedBox(height: PassqlSpacing.xl),
        Row(
          children: [
            Expanded(
              child: PassqlButton(
                label: '답안 수정',
                icon: CupertinoIcons.pencil,
                variant: PassqlButtonVariant.tinted,
                onPressed: onEdit,
              ),
            ),
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(
              child: PassqlButton(
                label: '결과 공유',
                icon: CupertinoIcons.share,
                onPressed: () => showExamAnswerShareSheet(
                  context,
                  certType: roundKey.certType,
                  roundNumber: roundKey.roundNumber,
                  roundTitle: ExamAnswerRoundSummary.titleOf(
                    roundResponse.round,
                  ),
                  report: report,
                ),
              ),
            ),
          ],
        ),
        if (unsettledCount > 0) ...[
          const SizedBox(height: PassqlSpacing.md),
          Text(
            '아직 갈리거나 정해지지 않은 $unsettledCount문항은 정답이 정해지면 점수가 바뀔 수 있어요.',
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
        const SizedBox(height: PassqlSpacing.xl),
        if (wrongMarks.isEmpty)
          PassqlStatusView.empty(
            icon: CupertinoIcons.star_fill,
            title: '정해진 문항은 모두 맞혔어요',
          )
        else
          PassqlGroupedSection(
            header: '틀린 문항 개념 복습 ${wrongMarks.length}',
            children: [
              for (final mark in wrongMarks)
                PassqlListRow(
                  title:
                      '${mark.questionNo}번 ${itemByQuestionNo[mark.questionNo]?.conceptTitle ?? ''}'
                          .trim(),
                  subtitle: _answerCompareOf(mark),
                  titleMaxLines: 2,
                  hasChevron: true,
                  onTap: itemByQuestionNo[mark.questionNo] == null
                      ? null
                      : () => showExamAnswerConceptSheet(
                          context,
                          item: itemByQuestionNo[mark.questionNo]!,
                          myAnswer: mark.myAnswer,
                        ),
                ),
            ],
          ),
      ],
    );
  }

  /// `내 답 2 | 가답안 3` (모름이면 `내 답 모름`)
  static String _answerCompareOf(ExamAnswerQuestionMark mark) {
    final myAnswerText = mark.myAnswer == SqldScoringRule.unknownAnswer
        ? '모름'
        : '${mark.myAnswer}번';
    final answer = mark.answer;
    return answer == null
        ? '내 답 $myAnswerText'
        : '내 답 $myAnswerText | 가답안 $answer번';
  }
}
