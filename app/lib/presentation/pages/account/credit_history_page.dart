import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/app_clock.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/member/credit_history_response.dart';
import '../../design/design.dart';
import '../../providers/credit_history_providers.dart';
import '../../widgets/account/credit_history_entry.dart';

/// 크레딧 내역 (#974, 프로필 오늘 크레딧 `내역`에서 진입): 날짜별 묶음을 오늘부터 아래로
/// 불러오는 중 스켈레톤 > 실패(다시 시도)·빈 목록 안내·날짜별 묶음
class CreditHistoryPage extends ConsumerWidget {
  const CreditHistoryPage({super.key});

  static const EdgeInsets _listPadding = EdgeInsets.fromLTRB(
    PassqlSpacing.md,
    PassqlSpacing.xs,
    PassqlSpacing.md,
    PassqlSpacing.xl,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(creditHistoryProvider);
    return Scaffold(
      appBar: const PassqlNavBar(
        title: '크레딧 내역',
        leading: PassqlNavLeading.back,
      ),
      body: SafeArea(
        child: PassqlFadeSwitcher(
          child: history.when(
            loading: () => const SingleChildScrollView(
              key: ValueKey('loading'),
              padding: _listPadding,
              child: PassqlListSkeleton(),
            ),
            error: (error, _) => KeyedSubtree(
              key: const ValueKey('error'),
              child: PassqlStatusView.error(
                message: error.asAppException.message,
                onRetry: () => ref.invalidate(creditHistoryProvider),
              ),
            ),
            data: (days) => days.isEmpty
                ? KeyedSubtree(
                    key: const ValueKey('empty'),
                    child: PassqlStatusView.empty(
                      icon: CupertinoIcons.clock,
                      title: '아직 크레딧 내역이 없어요',
                    ),
                  )
                : _CreditHistoryDayList(
                    key: const ValueKey('data'),
                    days: days,
                    padding: _listPadding,
                  ),
          ),
        ),
      ),
    );
  }
}

/// 날짜별 묶음 목록: 서버 순서(오늘 먼저) 그대로, 마지막 묶음 아래에 조회 기간 안내
class _CreditHistoryDayList extends StatelessWidget {
  const _CreditHistoryDayList({
    super.key,
    required this.days,
    required this.padding,
  });

  final List<CreditHistoryDayResponse> days;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final today = AppClock.now();
    return ListView.separated(
      padding: padding,
      itemCount: days.length,
      separatorBuilder: (_, _) => const SizedBox(height: PassqlSpacing.xl),
      itemBuilder: (context, index) => _CreditHistoryDaySection(
        day: days[index],
        today: today,
        footer: index == days.length - 1
            ? '최근 $creditHistoryDayCount일 내역이에요'
            : null,
      ),
    );
  }
}

/// 하루 묶음: 머리(날짜 · 크레딧 아이콘 + 남은 수) > 받은 줄(+N 강조색)·쓴 줄(-N 보조색)
class _CreditHistoryDaySection extends StatelessWidget {
  const _CreditHistoryDaySection({
    required this.day,
    required this.today,
    this.footer,
  });

  final CreditHistoryDayResponse day;
  final DateTime today;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final entries = buildCreditHistoryEntries(
      day,
      isToday: isSameCalendarDay(day.date, today),
    );
    final amountStyle = PassqlTypography.bodyMedium.copyWith(
      fontFeatures: PassqlTypography.tabular,
    );
    return PassqlGroupedSection(
      header: formatRecentDayTitle(day.date, today: today),
      headerTrailing: _RemainingCredits(count: day.remainingCredits),
      footer: footer,
      children: [
        for (final entry in entries)
          // 이름과 수량을 한 번에 읽힘
          MergeSemantics(
            child: PassqlListRow(
              title: entry.label,
              trailing: Text(
                entry.isSpent ? '${entry.amount}' : '+${entry.amount}',
                style: amountStyle.copyWith(
                  color: entry.isSpent
                      ? colors.secondaryLabel
                      : colors.accentText,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 그날 남은 크레딧: 크레딧 아이콘 + 숫자 (스크린리더는 `남은 크레딧 N개`)
class _RemainingCredits extends StatelessWidget {
  const _RemainingCredits({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '남은 크레딧 $count개',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PassqlCreditIcon(),
          const SizedBox(width: PassqlSpacing.xxs),
          Text(
            '$count',
            style: PassqlTypography.footnoteSemibold.copyWith(
              color: context.passqlColors.label,
            ),
          ),
        ],
      ),
    );
  }
}
