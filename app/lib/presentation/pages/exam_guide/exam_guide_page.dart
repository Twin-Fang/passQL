import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../design/design.dart';
import '../../providers/exam_guide_providers.dart';
import '../../widgets/exam_guide/exam_guide_intro_section.dart';
import '../../widgets/exam_guide/exam_guide_stats_section.dart';

/// SQLD 알아보기 탭 2개: 시험 소개 (#1076), 역대 통계 (#1077)
enum ExamGuideTab { intro, statistics }

/// SQLD 알아보기 화면 (#1076, #1077): 시험 일정 화면·홈 첫 방문 안내에서 진입
/// 세그먼트 [시험 소개 | 역대 통계] > 불러오는 중·실패(다시 시도)·본문
class ExamGuidePage extends ConsumerStatefulWidget {
  const ExamGuidePage({super.key, this.initialTab = ExamGuideTab.intro});

  final ExamGuideTab initialTab;

  @override
  ConsumerState<ExamGuidePage> createState() => _ExamGuidePageState();
}

class _ExamGuidePageState extends ConsumerState<ExamGuidePage> {
  late ExamGuideTab selectedTab = widget.initialTab;

  static const EdgeInsets _contentPadding = EdgeInsets.fromLTRB(
    PassqlSpacing.md,
    PassqlSpacing.md,
    PassqlSpacing.md,
    PassqlSpacing.xl,
  );

  @override
  Widget build(BuildContext context) {
    final guideAsync = ref.watch(sqldExamGuideProvider);
    return Scaffold(
      appBar: const PassqlNavBar(
        title: 'SQLD 알아보기',
        leading: PassqlNavLeading.back,
      ),
      body: SafeArea(
        child: PassqlFadeSwitcher(
          child: guideAsync.when(
            loading: () => const KeyedSubtree(
              key: ValueKey('loading'),
              child: PassqlStatusView.loading(),
            ),
            error: (error, _) => KeyedSubtree(
              key: const ValueKey('error'),
              child: PassqlStatusView.error(
                message: error.asAppException.message,
                onRetry: () => ref.invalidate(sqldExamGuideProvider),
              ),
            ),
            data: (guide) => ListView(
              key: const ValueKey('content'),
              padding: _contentPadding,
              children: [
                PassqlSegmentedControl<ExamGuideTab>(
                  segments: const [
                    PassqlSegment(value: ExamGuideTab.intro, label: '시험 소개'),
                    PassqlSegment(
                      value: ExamGuideTab.statistics,
                      label: '역대 통계',
                    ),
                  ],
                  selectedValue: selectedTab,
                  onSelected: (tab) => setState(() => selectedTab = tab),
                ),
                const SizedBox(height: PassqlSpacing.lg),
                PassqlFadeSwitcher(
                  child: switch (selectedTab) {
                    ExamGuideTab.intro => ExamGuideIntroSection(
                      key: const ValueKey(ExamGuideTab.intro),
                      guide: guide,
                    ),
                    ExamGuideTab.statistics => ExamGuideStatsSection(
                      key: const ValueKey(ExamGuideTab.statistics),
                      guide: guide,
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
