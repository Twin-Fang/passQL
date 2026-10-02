import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_colors.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/text_styles.dart';
import '../../../data/models/daily_set/daily_set_models.dart';
import '../../../router/app_routes.dart';
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

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text('오늘의 세트', style: AppTextStyles.label_16),
      ),
      body: SafeArea(
        child: outcome != null
            ? _ResultBody(
                correctCount: outcome.correctCount,
                total: outcome.results.length,
                results: outcome.results.map((r) => r.isCorrect).toList(),
                saveError: outcome.saveError,
              )
            : _RecordBody(today: ref.watch(dailySetTodayProvider)),
      ),
    );
  }
}

/// 서버 기록으로 결과를 보여준다(풀이 직후가 아닐 때).
class _RecordBody extends ConsumerWidget {
  const _RecordBody({required this.today});

  final AsyncValue<DailySetTodayResponse> today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return today.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _Message(
        text: e.asAppException.message,
        actionLabel: '다시 시도',
        onAction: () => ref.invalidate(dailySetTodayProvider),
      ),
      data: (data) {
        if (!data.alreadyCompleted) {
          return _Message(
            text: '아직 오늘의 세트를 풀지 않았어요',
            actionLabel: '풀어보기',
            onAction: () => context.go(AppRoutes.dailySet),
          );
        }
        return _ResultBody(
          correctCount: data.correctCount ?? 0,
          total: data.questions.length,
          results: const [],
        );
      },
    );
  }
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
    final board = ref.watch(leaderboardProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Center(
          child: Column(
            children: [
              Text(
                '오늘의 데일리 세트 완료',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  text: '$correctCount',
                  style: AppTextStyles.semibold_44.copyWith(
                    color: AppColors.brandIndigo,
                  ),
                  children: [
                    TextSpan(
                      text: ' / $total',
                      style: AppTextStyles.heading_24.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '정답',
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (saveError != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.red100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '순위에 반영하지 못했어요. $saveError',
              style: AppTextStyles.tag_12.copyWith(color: AppColors.red),
            ),
          ),
        ],
        if (results.isNotEmpty) ...[
          const SizedBox(height: 20),
          _Card(
            title: '문제별 결과',
            child: Column(
              children: [
                for (var i = 0; i < results.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${i + 1}',
                            style: AppTextStyles.tag_12.copyWith(
                              color: AppColors.textCaption,
                            ),
                          ),
                        ),
                        FaIcon(
                          results[i]
                              ? FontAwesomeIcons.circleCheck
                              : FontAwesomeIcons.circleXmark,
                          size: 16,
                          color: results[i]
                              ? AppColors.successText
                              : AppColors.red,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          results[i] ? '정답' : '오답',
                          style: AppTextStyles.paragraph_14.copyWith(
                            color: results[i]
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _Card(
          title: '오늘의 순위',
          trailing: board.valueOrNull?.myEntry == null
              ? null
              : Text(
                  '내 순위 ${board.valueOrNull!.myEntry!.rank}위',
                  style: AppTextStyles.tag_12.copyWith(
                    color: AppColors.brandIndigo,
                  ),
                ),
          child: board.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => Text(
              e.asAppException.message,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            data: (data) => Column(
              children: [
                if (data.entries.isEmpty)
                  Text(
                    '아직 순위가 없어요',
                    style: AppTextStyles.paragraph_14.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                for (final entry in data.entries.take(3))
                  LeaderboardRow(entry: entry),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.push(AppRoutes.leaderboard),
                    child: const Text('전체 순위 보기'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('홈으로 가기'),
          ),
        ),
      ],
    );
  }
}

/// 순위 한 줄. 결과 화면과 리더보드가 함께 쓴다.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({super.key, required this.entry, this.highlight = false});

  final LeaderboardEntry entry;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: highlight
          ? BoxDecoration(
              color: AppColors.brandIndigo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${entry.rank}',
              style: AppTextStyles.paragraph_14.copyWith(
                color: entry.rank <= 3
                    ? AppColors.brandIndigo
                    : AppColors.textCaption,
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.nickname,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${entry.correctCount}점',
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.brandIndigo,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.label_16.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.actionLabel, required this.onAction});

  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.brandIndigo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
