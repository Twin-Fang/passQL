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
    final c = context.pq;
    final board = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: c.background,
      appBar: const PqNavBar(title: '오늘의 순위'),
      body: SafeArea(
        child: board.when(
          loading: () => const PqStatusView.loading(),
          error: (e, _) => PqStatusView.error(
            message: e.asAppException.message,
            onRetry: () => ref.invalidate(leaderboardProvider),
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.fromLTRB(
              PqSpace.md,
              PqSpace.xs,
              PqSpace.md,
              PqSpace.xl,
            ),
            children: [
              if (data.date != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: PqSpace.md,
                    bottom: PqSpace.sm,
                  ),
                  child: Text(
                    data.date!,
                    style: PqType.footnote.copyWith(color: c.tertiaryLabel),
                  ),
                ),
              if (data.myEntry != null) ...[
                PqGroupedSection(
                  header: '내 순위',
                  children: [
                    LeaderboardRow(
                      entry: data.myEntry!,
                      highlight: true,
                      inset: PqSpace.md,
                    ),
                  ],
                ),
                const SizedBox(height: PqSpace.xl),
              ],
              if (data.entries.isEmpty)
                PqStatusView.empty(
                  icon: CupertinoIcons.rosette,
                  title: '아직 완료한 사람이 없어요',
                )
              else
                // 제목이 없으면 참가자가 나뿐일 때 "내 순위"와 같은 행이 두 번 나온 것처럼 보인다.
                PqGroupedSection(
                  header: '전체 순위 · ${data.entries.length}명',
                  children: [
                    for (final entry in data.entries)
                      LeaderboardRow(
                        entry: entry,
                        inset: PqSpace.md,
                        // 내 기록은 목록에서도 눈에 띄게 한다.
                        highlight:
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
    );
  }
}
