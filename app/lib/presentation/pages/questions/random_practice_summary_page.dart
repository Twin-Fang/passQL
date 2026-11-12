import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../../providers/chapter_providers.dart';
import '../../../core/lock_screen/lock_screen_intro_rule.dart';
import '../../providers/plan_providers.dart';
import '../../widgets/lock_screen/lock_screen_intro_sheet.dart';
import '../../widgets/notification/study_result_seen_recorder.dart';
import '../../widgets/practice/open_random_practice.dart';
import '../../widgets/result/solved_question_list_section.dart';

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
    // 오늘 3문제 이상 제출했으면 잠금화면 소개 1회 (#990)
    return StudyResultSeenRecorder(
      child: LockScreenIntroOnResult(
        hasStudiedEnoughToday: (ref) =>
            (ref.read(knownPlanProvider)?.todayRandomSolvedCount ??
                solvedCount) >=
            LockScreenIntroRule.minimumTodaySolvedCount,
        child: PassqlResultScaffold(
          title: _title,
          onClose: () => leaveSolvingFlow(context),
          // 맞힌 수·정답률은 점수 고리가 보여 줌 (같은 값 문장 반복 없음)
          header: PassqlScoreHeader(score: correctCount, total: solvedCount),
          sections: [
            SolvedQuestionListSection(
              solvedQuestions: [
                for (final result in summary.results)
                  (
                    questionUuid: result.questionUuid,
                    isCorrect: result.isCorrect,
                  ),
              ],
            ),
          ],
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
      ),
    );
  }
}
