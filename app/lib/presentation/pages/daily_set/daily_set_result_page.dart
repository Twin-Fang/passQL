import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/daily_set/daily_set_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../flows/daily_set_flow.dart';
import '../../providers/daily_set_providers.dart';

/// 오늘의 세트 결과 화면.
///
/// 풀이를 막 끝냈으면 `extra` 로 [DailySetOutcome] 을 받아 문제별 결과까지 보여준다.
/// 홈에서 "이미 완료" 카드로 들어오면 `extra` 가 없으므로 서버의 오늘 기록을 보여준다.
class DailySetResultPage extends ConsumerWidget {
  const DailySetResultPage({super.key, this.extra});

  final Object? extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outcome = extra is DailySetOutcome ? extra as DailySetOutcome : null;

    if (outcome != null) {
      return _ResultBody(
        correctCount: outcome.correctCount,
        total: outcome.results.length,
        results: outcome.results.map((r) => r.isCorrect).toList(),
        saveError: outcome.saveError,
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
      loading: () => const _StatusScaffold(child: PqStatusView.loading()),
      error: (e, _) => _StatusScaffold(
        child: PqStatusView.error(
          message: e.asAppException.message,
          onRetry: () => ref.invalidate(dailySetTodayProvider),
        ),
      ),
      data: (data) {
        if (!data.alreadyCompleted) {
          return _StatusScaffold(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PqStatusView.empty(
                  icon: CupertinoIcons.calendar,
                  title: '아직 오늘의 세트를 풀지 않았어요',
                ),
                PqButton(
                  label: '풀어보기',
                  variant: PqButtonVariant.tinted,
                  size: PqButtonSize.small,
                  expand: false,
                  onPressed: () => context.go(AppRoutes.dailySet),
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
            results.every((r) => r != null);
        return _ResultBody(
          correctCount: data.correctCount ?? 0,
          total: data.questions.length,
          results: complete ? results.cast<bool>() : const [],
        );
      },
    );
  }
}

/// 로딩·오류·미완료처럼 결과 틀을 쓸 수 없는 상태의 공통 껍데기.
class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const PqNavBar(title: '오늘의 세트'),
    body: Center(child: child),
  );
}

class _ResultBody extends ConsumerWidget {
  const _ResultBody({
    required this.correctCount,
    required this.total,
    required this.results,
    this.saveError,
  });

  final int correctCount;
  final int total;

  /// 문제별 정오답. 풀이 직후에만 있다.
  final List<bool> results;

  /// 점수 등록 실패 사유.
  final String? saveError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.pq;
    final board = ref.watch(leaderboardProvider);
    final myRank = board.valueOrNull?.myEntry?.rank;

    return PqResultScaffold(
      title: '오늘의 세트',
      header: PqScoreHeader(
        score: correctCount,
        total: total,
        caption: '오늘의 세트',
      ),
      sections: [
        if (saveError != null)
          PqCard(
            child: PqResultMark(
              correct: false,
              label: '순위에 반영하지 못했어요. $saveError',
            ),
          ),
        if (results.isNotEmpty)
          PqGroupedSection(
            header: '문제별 결과',
            children: [
              for (var i = 0; i < results.length; i++)
                PqListRow(
                  title: '${i + 1}번',
                  trailing: PqResultMark(correct: results[i]),
                ),
            ],
          ),
        PqCard(
          title: '오늘의 순위',
          trailing: myRank == null
              ? null
              : Text(
                  '내 순위 $myRank위',
                  style: PqType.footnoteSemibold.copyWith(color: c.accent),
                ),
          child: board.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(PqSpace.sm),
              child: Center(child: CupertinoActivityIndicator()),
            ),
            error: (e, _) => Text(
              e.asAppException.message,
              style: PqType.subheadline.copyWith(color: c.secondaryLabel),
            ),
            data: (data) => Column(
              children: [
                if (data.entries.isEmpty)
                  Text(
                    '아직 순위가 없어요',
                    style: PqType.subheadline.copyWith(color: c.secondaryLabel),
                  ),
                for (final entry in data.entries.take(3))
                  LeaderboardRow(entry: entry),
              ],
            ),
          ),
        ),
      ],
      actions: [
        PqButton(
          label: '전체 순위',
          variant: PqButtonVariant.tinted,
          onPressed: () => context.push(AppRoutes.leaderboard),
        ),
        PqButton(label: '홈으로', onPressed: () => context.go(AppRoutes.home)),
      ],
    );
  }
}

/// 순위 한 줄. 결과 화면과 리더보드가 함께 쓴다.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    super.key,
    required this.entry,
    this.highlight = false,
    this.inset = PqSpace.xxs,
  });

  final LeaderboardEntry entry;
  final bool highlight;

  /// 좌우 여백. 카드 안에서는 좁게, grouped 목록에서는 행 규격(16)으로 쓴다.
  final double inset;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    // grouped 목록 행과 같은 높이·여백. 내 행은 배경만 accentTint 로 바꾼다.
    return ColoredBox(
      color: highlight ? c.accentTint : Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: PqSize.rowMin),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: PqSpace.sm,
            horizontal: inset,
          ),
          child: Row(
            children: [
              SizedBox(
                width: PqSpace.xxl,
                child: Text(
                  '${entry.rank}',
                  style: PqType.headline.copyWith(
                    color: entry.rank <= 3 ? c.accent : c.tertiaryLabel,
                    fontFeatures: PqType.tabular,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.nickname,
                  overflow: TextOverflow.ellipsis,
                  style: PqType.body.copyWith(color: c.label),
                ),
              ),
              Text(
                '${entry.correctCount}점',
                style: PqType.bodyMedium.copyWith(
                  color: c.accent,
                  fontFeatures: PqType.tabular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
