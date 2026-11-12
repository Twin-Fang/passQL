import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/app_clock.dart';
import '../../../core/utils/external_url_launcher.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/exam_schedule_providers.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/exam_schedule/exam_schedule_content.dart';
import '../../widgets/exam_schedule/sqld_exam_facts.dart';

/// SQLD 시험 일정 화면 (#991): 홈 D-day 배지·푸시(EXAM_SCHEDULE)에서 진입
/// 불러오는 중 > 실패(다시 시도)·일정 없음 안내·본문(ExamScheduleContent)
class ExamSchedulePage extends ConsumerWidget {
  const ExamSchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(sqldExamScheduleOverviewProvider);
    return Scaffold(
      appBar: const PassqlNavBar(
        title: 'SQLD 시험 일정',
        leading: PassqlNavLeading.back,
      ),
      body: SafeArea(
        child: PassqlFadeSwitcher(
          child: overviewAsync.when(
            loading: () => const KeyedSubtree(
              key: ValueKey('loading'),
              child: PassqlStatusView.loading(),
            ),
            error: (error, _) => KeyedSubtree(
              key: const ValueKey('error'),
              child: PassqlStatusView.error(
                message: error.asAppException.message,
                onRetry: () => ref.invalidate(sqldExamScheduleOverviewProvider),
              ),
            ),
            data: (overview) =>
                overview.schedules.isEmpty && overview.nextSchedule == null
                ? KeyedSubtree(
                    key: const ValueKey('empty'),
                    child: PassqlStatusView.empty(
                      icon: CupertinoIcons.calendar,
                      title: '아직 올라온 시험 일정이 없어요',
                      message: '공식 사이트에서 일정을 확인해 주세요',
                      actionLabel: '공식 사이트 열기',
                      onAction: () => _openExternal(
                        context,
                        overview.officialScheduleUrl ??
                            SqldExamFacts.fallbackOfficialScheduleUrl,
                      ),
                    ),
                  )
                : ExamScheduleContent(
                    key: const ValueKey('data'),
                    overview: overview,
                    today: AppClock.now(),
                    onApplyPressed: () => _openExternal(
                      context,
                      overview.officialScheduleUrl ??
                          SqldExamFacts.fallbackOfficialScheduleUrl,
                    ),
                    onMockExamPressed: () =>
                        unawaited(context.push(AppRoutes.mockExams)),
                    onOfficialGuidePressed: () =>
                        _openExternal(context, SqldExamFacts.officialGuideUrl),
                  ),
          ),
        ),
      ),
    );
  }

  /// 공식 사이트 외부 브라우저로 열기 (못 열면 안내)
  static Future<void> _openExternal(BuildContext context, String url) async {
    final isOpened = await launchExternalUrl(url);
    if (!isOpened && context.mounted) {
      showAppToast(context, '링크를 열지 못했어요');
    }
  }
}
