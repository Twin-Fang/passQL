import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/review/store_review_prompter.dart';
import '../../../data/models/mock_exam/mock_exam_result.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_providers.dart';
import '../../widgets/mock_exam/mock_exam_result_grid.dart';
import '../../widgets/mock_exam/mock_exam_score_hero.dart';
import '../../widgets/mock_exam/mock_exam_subject_breakdown.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';
import '../../widgets/pro/pro_offer_sheet.dart';
import '../../widgets/review/store_review_prompt_on_result.dart';
import '../../widgets/stats/ai_analysis_action_buttons.dart';

/// 모의고사 결과 (#866): 합격·불합격 > 과목·토픽(프로) > 다음에 할 일(프로) > 정오 번호판 > 문항 해설(프로)
/// 무료는 서버가 뺀 묶음(lockedSections) 자리에 잠금 미리보기, 정오 번호판은 공개
class MockExamResultPage extends ConsumerWidget {
  const MockExamResultPage({
    super.key,
    required this.attemptUuid,
    this.isJustSubmitted = false,
  });

  final String attemptUuid;

  /// 풀이 화면에서 막 제출한 진입인지 (회차 목록·점수 추이에서 다시 열면 false)
  final bool isJustSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(mockExamResultProvider(attemptUuid));
    return Scaffold(
      appBar: PassqlNavBar(
        title: resultAsync.valueOrNull?.title ?? '모의고사 결과',
        leading: PassqlNavLeading.close,
        onLeadingTap: () => _close(context),
      ),
      body: SafeArea(
        child: resultAsync.when(
          loading: () => const PassqlStatusView.loading(),
          error: (error, _) => PassqlStatusView.error(
            message: error.asAppException.message,
            onRetry: () => ref.invalidate(mockExamResultProvider(attemptUuid)),
          ),
          data: (examResult) {
            final resultBody = _ResultBody(
              attemptUuid: attemptUuid,
              examResult: examResult,
            );
            // 막 제출한 진입에만 스토어 평가 요청 시도 (좋은 결과 = 합격)
            if (!isJustSubmitted) return resultBody;
            return StoreReviewPromptOnResult(
              trigger: StoreReviewTrigger.mockExam,
              isGoodResult: examResult.isPassed,
              child: resultBody,
            );
          },
        ),
      ),
    );
  }

  /// 닫기: 쌓인 화면이 있으면 뒤로, 없으면(풀이에서 대신 열림) 회차 목록
  static void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.mockExams);
    }
  }
}

class _ResultBody extends ConsumerWidget {
  const _ResultBody({required this.attemptUuid, required this.examResult});

  final String attemptUuid;
  final MockExamResultResponse examResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final nextStep = examResult.nextStep;
    final sections = <Widget>[
      MockExamScoreHero(examResult: examResult),
      if (examResult.isSubjectDetailLocked)
        const ProLockedSection(
          preview: MockExamDetailLockedSample(),
          caption: LockedPreviewCaptions.mockExamDetail,
        )
      else if (examResult.subjects.isNotEmpty)
        MockExamSubjectBreakdown(examResult: examResult),
      if (nextStep != null)
        PassqlCard(
          title: nextStep.headline,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                nextStep.message,
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              AiAnalysisActionButtons(actions: nextStep.actions),
            ],
          ),
        ),
      PassqlCard(
        title: '문항별 정오',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MockExamResultGrid(
              questionMarks: examResult.questionMarks,
              onQuestionTap: (questionNumber) => examResult.isReviewLocked
                  ? showProOfferSheet(context, ref)
                  : context.push(
                      AppRoutes.mockExamReview(attemptUuid, questionNumber),
                    ),
            ),
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              examResult.isReviewLocked
                  ? '번호를 누르면 이용권 안내가 열려요'
                  : '번호를 누르면 정답과 보기 해설을 볼 수 있어요',
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
      if (examResult.isReviewLocked)
        const ProLockedSection(
          preview: MockExamReviewLockedSample(),
          caption: LockedPreviewCaptions.mockExamReview,
        ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.xl,
      ),
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.lg),
          PassqlReveal(index: index, child: sections[index]),
        ],
      ],
    );
  }
}
