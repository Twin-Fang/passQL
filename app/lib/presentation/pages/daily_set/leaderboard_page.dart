import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../design/design.dart';
import '../../providers/daily_set_providers.dart';
import 'daily_set_result_page.dart' show LeaderboardRow;

/// 오늘의 전체 순위. 내 기록은 맨 위에 따로 보여준다.
class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final board = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: PassqlNavBar(title: '오늘의 순위', leading: PassqlNavLeading.back),
      body: SafeArea(
        // 로딩 자리 스켈레톤 > 순위 목록 페이드 교체
        child: PassqlFadeSwitcher(
          child: board.when(
            loading: () => const SingleChildScrollView(
              key: ValueKey('loading'),
              padding: EdgeInsets.fromLTRB(
                PassqlSpacing.md,
                PassqlSpacing.xs,
                PassqlSpacing.md,
                PassqlSpacing.xl,
              ),
              child: PassqlListSkeleton(rowCount: 8),
            ),
            error: (error, _) => KeyedSubtree(
              key: const ValueKey('error'),
              child: PassqlStatusView.error(
                message: error.asAppException.message,
                onRetry: () => ref.invalidate(leaderboardProvider),
              ),
            ),
            data: (data) => ListView(
              key: const ValueKey('data'),
              padding: const EdgeInsets.fromLTRB(
                PassqlSpacing.md,
                PassqlSpacing.xs,
                PassqlSpacing.md,
                PassqlSpacing.xl,
              ),
              children: [
                if (data.date != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: PassqlSpacing.md,
                      bottom: PassqlSpacing.sm,
                    ),
                    child: Text(
                      data.date!,
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ),
                if (data.myEntry != null) ...[
                  PassqlGroupedSection(
                    header: '내 순위',
                    children: [
                      LeaderboardRow(
                        entry: data.myEntry!,
                        isHighlighted: true,
                        inset: PassqlSpacing.md,
                      ),
                    ],
                  ),
                  const SizedBox(height: PassqlSpacing.xl),
                ],
                if (data.entries.isEmpty)
                  PassqlStatusView.empty(
                    icon: CupertinoIcons.rosette,
                    title: '아직 완료한 사람이 없어요',
                  )
                else
                  // 제목이 없으면 참가자가 나뿐일 때 "내 순위"와 같은 행이 두 번 나온 것처럼 보인다.
                  PassqlGroupedSection(
                    header: '전체 순위 · ${data.entries.length}명',
                    children: [
                      for (final entry in data.entries)
                        LeaderboardRow(
                          entry: entry,
                          inset: PassqlSpacing.md,
                          // 내 기록은 목록에서도 눈에 띄게 한다.
                          isHighlighted:
                              data.myEntry != null &&
                              data.myEntry!.rank == entry.rank &&
                              data.myEntry!.nickname == entry.nickname,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
