import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/text_styles.dart';
import '../../providers/daily_set_providers.dart';
import 'daily_set_result_page.dart' show LeaderboardRow;

/// 오늘의 전체 순위. 내 기록은 맨 위에 따로 보여준다.
class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(leaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('오늘의 순위', style: AppTextStyles.label_16),
      ),
      body: SafeArea(
        child: board.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  e.asAppException.message,
                  style: AppTextStyles.paragraph_14.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => ref.invalidate(leaderboardProvider),
                  child: Text(
                    '다시 시도',
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: AppColors.brandIndigo,
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (data.date != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    data.date!,
                    style: AppTextStyles.tag_12.copyWith(
                      color: AppColors.textCaption,
                    ),
                  ),
                ),
              if (data.myEntry != null) ...[
                Text(
                  '내 순위',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                LeaderboardRow(entry: data.myEntry!, highlight: true),
                const SizedBox(height: 16),
              ],
              if (data.entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      '아직 완료한 사람이 없어요',
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                for (final entry in data.entries)
                  LeaderboardRow(
                    entry: entry,
                    // 내 기록은 목록에서도 눈에 띄게 한다.
                    highlight: data.myEntry != null &&
                        data.myEntry!.rank == entry.rank &&
                        data.myEntry!.nickname == entry.nickname,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
