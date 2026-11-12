import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/review/store_review_prompt_rule.dart';
import '../../../core/review/store_review_prompter.dart';
import '../../../data/models/daily_set/daily_set_models.dart';
import '../../../router/app_routes.dart';
import '../../../router/result_route_arguments.dart';
import '../../../router/solving_flow_exit.dart';
import '../../design/design.dart';
import '../../providers/daily_set_providers.dart';
import '../../widgets/lock_screen/lock_screen_intro_sheet.dart';
import '../../widgets/ads/rewarded_interstitial_on_result.dart';
import '../../widgets/daily_set/daily_set_bonus_card.dart';
import '../../widgets/notification/study_result_seen_recorder.dart';
import '../../widgets/result/solved_question_result_table.dart';
import '../../widgets/review/store_review_prompt_on_result.dart';

/// 상단 바·점수 머리에 쓰는 화면 이름
const _dailySetTitle = '오늘의 세트';

/// 결과 표 위 SQL 문 (#999)
const _dailySetResultQuery = "SELECT 영역, 결과\nFROM 오늘의_세트\nWHERE 날짜 = '오늘';";

/// 맞힌 수 > 응원 한 줄: 다 맞힘 / 60% 이상(5문제 중 3~4개) / 그 외
String _cheerMessageOf({required int correctCount, required int total}) {
  if (total > 0 && correctCount >= total) return '$total문제 모두 맞혔어요!';
  if (total > 0 && correctCount * 5 >= total * 3) return '좋아요, 거의 다 왔어요';
  return '틀린 문제가 실력이 돼요';
}

/// 오늘의 세트 결과 화면.
///
/// 풀이를 막 끝냈으면 [outcome] 으로 문제별 결과까지 보여준다.
/// 홈에서 "이미 완료" 카드로 들어오면 [outcome] 이 없으므로 서버의 오늘 기록을 보여준다.
class DailySetResultPage extends ConsumerWidget {
  const DailySetResultPage({super.key, this.outcome});

  final DailySetOutcome? outcome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outcome = this.outcome;
    if (outcome != null) {
      // 풀이를 막 끝낸 진입에만 스토어 평가 요청(진입)·보상형 전면 광고 제안(떠날 때) (홈 '이미 완료' 카드 진입은 제외)
      // 광고 제안은 진입 때 뜨는 세트 보상 연출·평가 요청과 겹치지 않게 닫기·뒤로가기 때 (#963)
      // 결과를 본 기록 > 탭 화면 복귀 때 알림 권한 사전 안내 시점
      // 좋은 결과: 순위 반영 성공 + 정답률 60% 이상
      final total = outcome.results.length;
      // 세트를 막 끝냄 > 잠금화면 소개 1회 (#990)
      return StudyResultSeenRecorder(
        child: LockScreenIntroOnResult(
          hasStudiedEnoughToday: (_) => true,
          child: StoreReviewPromptOnResult(
            trigger: StoreReviewTrigger.dailySet,
            isGoodResult:
                outcome.saveError == null &&
                StoreReviewPromptRule.isGoodDailySetScore(
                  correctCount: outcome.correctCount,
                  questionCount: total,
                ),
            child: RewardedInterstitialOnLeave(
              onLeave: leaveSolvingFlow,
              builder: (_, leaveWithAdOffer) => _ResultBody(
                correctCount: outcome.correctCount,
                total: total,
                solvedQuestions: [
                  for (final result in outcome.results)
                    (
                      questionUuid: result.questionUuid,
                      isCorrect: result.isCorrect,
                    ),
                ],
                saveError: outcome.saveError,
                completedRank: outcome.completed?.rank,
                isJustCompleted: true,
                onClose: leaveWithAdOffer,
              ),
            ),
          ),
        ),
      );
    }
    return _RecordBody(today: ref.watch(dailySetTodayProvider));
  }
}

/// 서버 기록으로 결과를 보여준다(풀이 직후가 아닐 때).
class _RecordBody extends ConsumerWidget {
  const _RecordBody({required this.today});

  final AsyncValue<DailySetTodayResponse> today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return today.when(
      loading: () => PassqlStatusScaffold(
        title: _dailySetTitle,
        leading: PassqlNavLeading.close,
        onLeadingTap: () => leaveSolvingFlow(context),
        body: PassqlStatusView.loading(),
      ),
      error: (error, _) => PassqlStatusScaffold(
        title: _dailySetTitle,
        leading: PassqlNavLeading.close,
        onLeadingTap: () => leaveSolvingFlow(context),
        body: PassqlStatusView.error(
          message: error.asAppException.message,
          onRetry: () => ref.invalidate(dailySetTodayProvider),
        ),
      ),
      data: (data) {
        if (!data.alreadyCompleted) {
          return PassqlStatusScaffold(
            title: _dailySetTitle,
            leading: PassqlNavLeading.close,
            onLeadingTap: () => leaveSolvingFlow(context),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PassqlStatusView.empty(
                  icon: CupertinoIcons.calendar,
                  title: '아직 오늘의 세트를 풀지 않았어요',
                ),
                PassqlButton(
                  label: '풀어보기',
                  variant: PassqlButtonVariant.tinted,
                  size: PassqlButtonSize.small,
                  isFullWidth: false,
                  onPressed: () => context.pushReplacement(AppRoutes.dailySet),
                ),
              ],
            ),
          );
        }
        // 다시 열어도 완료 직후처럼 문제별 결과를 보여준다. 기록이 빠진 문제가 있으면
        // 정오를 지어내지 않도록 목록 자체를 숨긴다.
        final results = data.results;
        final complete =
            results != null &&
            results.isNotEmpty &&
            results.length == data.questions.length &&
            results.every((isCorrect) => isCorrect != null);
        return _ResultBody(
          correctCount: data.correctCount ?? 0,
          total: data.questions.length,
          solvedQuestions: complete
              ? [
                  for (var i = 0; i < data.questions.length; i++)
                    (
                      questionUuid: data.questions[i].questionUuid,
                      isCorrect: results[i]!,
                    ),
                ]
              : const [],
        );
      },
    );
  }
}

class _ResultBody extends ConsumerWidget {
  const _ResultBody({
    required this.correctCount,
    required this.total,
    required this.solvedQuestions,
    this.saveError,
    this.completedRank,
    this.isJustCompleted = false,
    this.onClose,
  });

  final int correctCount;
  final int total;

  /// 문제별 정오답 (기록이 빠진 문제가 있으면 빈 목록)
  final List<SolvedQuestion> solvedQuestions;

  /// 점수 등록 실패 사유.
  final String? saveError;

  /// 완료 응답의 내 순위 (풀이 직후에만, 순위표를 기다리지 않고 바로 표시)
  final int? completedRank;

  /// 풀이를 막 끝낸 진입 (기록에서 다시 열면 false > 보상 연출 생략)
  final bool isJustCompleted;

  /// 닫기 동작 (생략하면 바로 풀이 흐름 나가기, 방금 완료 진입은 광고 제안 뒤 나가기)
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final board = ref.watch(leaderboardProvider);
    // 내 순위: 완료 응답 우선 > 순위표의 내 줄
    final myRank = completedRank ?? board.valueOrNull?.myEntry?.rank;
    final wrongQuestions = solvedQuestions
        .where((solved) => !solved.isCorrect)
        .toList();
    final hasWrongQuestion = wrongQuestions.isNotEmpty;
    final close = onClose ?? () => leaveSolvingFlow(context);
    void openLeaderboard() => context.push(AppRoutes.leaderboard);

    return PassqlResultScaffold(
      title: _dailySetTitle,
      // 응원 한 줄 > 결과 표 (점수 고리 대신 SELECT 결과로, #999)
      header: PassqlKeepAllText(
        _cheerMessageOf(correctCount: correctCount, total: total),
        textAlign: TextAlign.center,
        style: PassqlTypography.title2.copyWith(color: colors.label),
      ),
      sections: [
        if (saveError != null)
          PassqlCard(
            child: PassqlResultMark(
              isCorrect: false,
              label: '순위에 반영하지 못했어요. $saveError',
            ),
          ),
        // 문제별 기록이 있으면 표, 빠졌으면 점수 고리만 (정오를 지어내지 않음)
        if (solvedQuestions.isNotEmpty)
          SolvedQuestionResultTable(
            query: _dailySetResultQuery,
            solvedQuestions: solvedQuestions,
          )
        else
          Center(child: PassqlScoreHeader(score: correctCount, total: total)),
        // 완료로 받은 무료 한도 보너스 (무료 회원만 보임, #808)
        if (saveError == null)
          DailySetBonusCard(
            assignedQuestionCount: total,
            shouldCelebrate: isJustCompleted,
          ),
        PassqlCard(
          title: '오늘의 순위',
          // 틀린 문제가 있으면 하단 버튼이 다시 풀기라 전체 순위는 카드 링크로
          trailing: hasWrongQuestion
              ? PassqlSectionLink(
                  label: myRank == null ? '전체' : '내 순위 $myRank위',
                  semanticLabel: '전체 순위 보기',
                  onTap: openLeaderboard,
                )
              : myRank == null
              ? null
              : Text(
                  '내 순위 $myRank위',
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.accentText,
                  ),
                ),
          child: board.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(PassqlSpacing.sm),
              child: Center(child: PassqlLoadingIndicator()),
            ),
            error: (error, _) => Text(
              error.asAppException.message,
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            data: (data) => Column(
              children: [
                if (data.entries.isEmpty)
                  Text(
                    '아직 순위가 없어요',
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                for (final entry in data.entries.take(3))
                  LeaderboardRow(entry: entry),
              ],
            ),
          ),
        ),
      ],
      // 주 버튼 전체 폭(긴 문구가 줄바꿈되지 않게) > 아래 보조 버튼
      // 틀린 문제 있음: 틀린 N문제 다시 풀기(첫 틀린 문제 상세) > 닫기, 다 맞힘: 닫기 > 전체 순위
      primaryAction: hasWrongQuestion
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PassqlButton(
                  label: '틀린 ${wrongQuestions.length}문제 다시 풀기',
                  onPressed: () => context.push(
                    AppRoutes.questionDetail(wrongQuestions.first.questionUuid),
                  ),
                ),
                const SizedBox(height: PassqlSpacing.xs),
                // 서버가 오늘의 세트 배정 문제를 하루 한도 수에서 빼고 셈 (FeatureAccessPolicy·DailyQuestionCounter)
                Text(
                  '다시 풀기는 크레딧을 쓰지 않아요',
                  textAlign: TextAlign.center,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            )
          : PassqlButton(label: '닫기', onPressed: close),
      actions: [
        hasWrongQuestion
            ? PassqlButton(
                label: '닫기',
                variant: PassqlButtonVariant.plain,
                onPressed: close,
              )
            : PassqlButton(
                label: '전체 순위',
                variant: PassqlButtonVariant.plain,
                onPressed: openLeaderboard,
              ),
      ],
    );
  }
}

/// 순위 한 줄. 결과 화면과 리더보드가 함께 쓴다.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.entry,
    this.isHighlighted = false,
    this.inset = PassqlSpacing.xxs,
  });

  final LeaderboardEntry entry;
  final bool isHighlighted;

  /// 좌우 여백. 카드 안에서는 좁게, grouped 목록에서는 행 규격(16)으로 쓴다.
  final double inset;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // grouped 목록 행과 같은 높이·여백. 내 행은 배경만 accentTint 로 바꾼다.
    return ColoredBox(
      color: isHighlighted ? colors.accentTint : Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: PassqlSize.rowMin),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: PassqlSpacing.sm,
            horizontal: inset,
          ),
          child: Row(
            children: [
              SizedBox(
                width: PassqlSpacing.xxl,
                child: Text(
                  '${entry.rank}',
                  style: PassqlTypography.headline.copyWith(
                    color: entry.rank <= 3
                        ? colors.accentText
                        : colors.secondaryLabel,
                    fontFeatures: PassqlTypography.tabular,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.nickname,
                  overflow: TextOverflow.ellipsis,
                  style: PassqlTypography.body.copyWith(color: colors.label),
                ),
              ),
              Text(
                '${entry.correctCount}점',
                style: PassqlTypography.bodyMedium.copyWith(
                  color: colors.accentText,
                  fontFeatures: PassqlTypography.tabular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
