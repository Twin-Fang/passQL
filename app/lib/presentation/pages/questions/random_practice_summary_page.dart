import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../../providers/chapter_providers.dart';
import '../../widgets/notification/study_result_seen_recorder.dart';
import '../../widgets/practice/open_random_practice.dart';

/// 랜덤 풀기 그만두기 요약: 맞힌 수 > 틀린 문제 다시 보기 > 계속 풀기·홈으로 (#963)
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
        sections: [_WrongQuestionsSection(results: summary.results)],
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

/// 틀린 문제 다시 보기 목록: 행 탭 > 문제 상세 (모두 맞혔으면 한 줄 안내)
class _WrongQuestionsSection extends StatelessWidget {
  const _WrongQuestionsSection({required this.results});

  final List<ChapterResult> results;

  @override
  Widget build(BuildContext context) {
    final wrongRows = <Widget>[
      for (var index = 0; index < results.length; index++)
        if (!results[index].isCorrect)
          PassqlListRow(
            leading: const PassqlResultMark(isCorrect: false),
            title: '${index + 1}번째 문제',
            hasChevron: true,
            onTap: () => context.push(
              AppRoutes.questionDetail(results[index].questionUuid),
            ),
          ),
    ];
    return PassqlGroupedSection(
      header: '틀린 문제 다시 보기',
      children: wrongRows.isNotEmpty
          ? wrongRows
          : const [
              PassqlListRow(
                leading: PassqlResultMark(isCorrect: true),
                title: '틀린 문제가 없어요',
              ),
            ],
    );
  }
}
