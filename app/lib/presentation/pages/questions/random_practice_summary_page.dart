import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../../providers/chapter_providers.dart';
import '../../providers/question_providers.dart';
import '../../widgets/notification/study_result_seen_recorder.dart';
import '../../widgets/practice/open_random_practice.dart';
import '../../widgets/question/stem_text.dart';

/// 랜덤 풀기 그만두기 요약: 맞힌 수 > 이번에 푼 문제(틀린 문제 먼저, 토픽·지문) > 계속 풀기·홈으로 (#963, #980)
/// 이동 인자 [summary] 로 렌더링 (없으면 결과 없음 화면). 전면 광고 없음
class RandomPracticeSummaryPage extends ConsumerWidget {
  const RandomPracticeSummaryPage({super.key, this.summary});

  final ChapterSummary? summary;

  static const String _title = '이번에 푼 문제';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = this.summary;
    if (summary == null) {
      return PassqlStatusScaffold(
        title: _title,
        leading: PassqlNavLeading.close,
        onLeadingTap: () => leaveSolvingFlow(context),
        body: PassqlStatusView.empty(
          icon: CupertinoIcons.exclamationmark_circle,
          title: '결과를 불러올 수 없어요',
        ),
      );
    }

    final solvedCount = summary.results.length;
    final correctCount = summary.results
        .where((result) => result.isCorrect)
        .length;

    // 결과를 본 기록 > 탭 화면 복귀 때 알림 권한 사전 안내 시점
    return StudyResultSeenRecorder(
      child: PassqlResultScaffold(
        title: _title,
        onClose: () => leaveSolvingFlow(context),
        header: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PassqlScoreHeader(score: correctCount, total: solvedCount),
            const SizedBox(height: PassqlSpacing.md),
            Text(
              '$solvedCount문제 중 $correctCount개 맞혔어요',
              textAlign: TextAlign.center,
              style: PassqlTypography.title2.copyWith(
                color: context.passqlColors.label,
              ),
            ),
          ],
        ),
        sections: [_SolvedQuestionsSection(results: summary.results)],
        actions: [
          PassqlButton(
            label: '홈으로',
            variant: PassqlButtonVariant.tinted,
            onPressed: () => context.go(AppRoutes.home),
          ),
          // 홈 줄과 같은 한도 판정을 거쳐 요약 자리를 새 랜덤 풀이로 교체
          PassqlButton(
            label: '계속 풀기',
            onPressed: () => openRandomPractice(
              context,
              ref,
              shouldReplaceCurrentRoute: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// 이번에 푼 문제 목록 (#980): 틀린 문제 먼저, 줄마다 정답·오답 표시 + 토픽 + 지문 한 줄, 탭 > 문제 상세
class _SolvedQuestionsSection extends StatelessWidget {
  const _SolvedQuestionsSection({required this.results});

  final List<ChapterResult> results;

  @override
  Widget build(BuildContext context) {
    final orderedResults = [
      ...results.where((result) => !result.isCorrect),
      ...results.where((result) => result.isCorrect),
    ];
    final wrongCount = results.where((result) => !result.isCorrect).length;
    return PassqlGroupedSection(
      header: wrongCount > 0 ? '틀린 문제 $wrongCount개부터 다시 봐요' : '이번에 푼 문제',
      children: [
        for (final result in orderedResults) _SolvedQuestionRow(result: result),
      ],
    );
  }
}

/// 푼 문제 한 줄: 정답·오답 표시 + 토픽 이름 + 지문 첫 줄 (불러오는 동안·실패면 `문제`)
class _SolvedQuestionRow extends ConsumerWidget {
  const _SolvedQuestionRow({required this.result});

  final ChapterResult result;

  // 지문 미리보기 최대 길이 (한 줄에 들어갈 만큼)
  static const int _stemPreviewLength = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref
        .watch(questionDetailProvider(result.questionUuid))
        .valueOrNull;
    final stem = detail == null
        ? null
        : stripCodeFences(detail.stem).replaceAll(RegExp(r'\s+'), ' ').trim();
    return PassqlListRow(
      leading: PassqlResultMark(isCorrect: result.isCorrect),
      title: detail?.topicName ?? '문제',
      subtitle: stem == null
          ? null
          : (stem.length > _stemPreviewLength
                ? '${stem.substring(0, _stemPreviewLength)}…'
                : stem),
      titleMaxLines: 1,
      hasChevron: true,
      onTap: () => context.push(AppRoutes.questionDetail(result.questionUuid)),
    );
  }
}
