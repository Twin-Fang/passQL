import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/exam_trend_providers.dart';
import '../../widgets/exam_trend/exam_trend_sections.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';

/// 본문 목록 여백 (잠금 본문과 같은 자리)
const _contentPadding = EdgeInsets.fromLTRB(
  PassqlSpacing.md,
  PassqlSpacing.xs,
  PassqlSpacing.md,
  PassqlSpacing.xl,
);

/// 출제 경향 화면 (#523): 요약 > 과목 비중 > 늘어난 유형 > 자주 나오는 개념 > 공부 팁
/// 유형·개념 행 탭 > 그 토픽의 최신 경향 문제 풀기 (문제 없으면 탭 없음)
/// 무료(결제 켜짐): 제목만 선명, 본문 전체 블러 (출제 경향 요청 없음, Provider 가 null)
class ExamTrendPage extends ConsumerWidget {
  const ExamTrendPage({super.key});

  static const String pageTitle = '출제 경향';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(examTrendReportProvider);
    return Scaffold(
      appBar: PassqlNavBar(title: pageTitle, leading: PassqlNavLeading.back),
      body: SafeArea(
        child: PassqlFadeSwitcher(
          child: switch (reportAsync) {
            AsyncData(value: null) => ListView(
              key: const ValueKey('locked'),
              padding: _contentPadding,
              children: const [
                ProLockedSection(
                  preview: ExamTrendLockedSample(),
                  caption: LockedPreviewCaptions.examTrend,
                ),
              ],
            ),
            AsyncData(:final value?) => _ExamTrendContent(
              key: const ValueKey('data'),
              report: value,
              onSolveTopic: (topicCode, topicName) => context.push(
                AppRoutes.questionChapterOf(
                  topicCode: topicCode,
                  topicName: topicName,
                  isLatestTrendOnly: true,
                ),
              ),
            ),
            AsyncError() => KeyedSubtree(
              key: const ValueKey('error'),
              child: PassqlStatusView.error(
                message: '출제 경향을 불러올 수 없어요',
                onRetry: () => ref.invalidate(examTrendReportProvider),
              ),
            ),
            _ => const Padding(
              key: ValueKey('loading'),
              padding: EdgeInsets.all(PassqlSpacing.md),
              child: PassqlListSkeleton(),
            ),
          },
        ),
      ),
    );
  }
}

class _ExamTrendContent extends StatelessWidget {
  const _ExamTrendContent({
    super.key,
    required this.report,
    required this.onSolveTopic,
  });

  final ExamTrendReportResponse report;
  final void Function(String topicCode, String topicName) onSolveTopic;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      ExamTrendSummaryCard(report: report),
      if (report.subjectShares.isNotEmpty)
        ExamTrendSubjectShareSection(subjectShares: report.subjectShares),
      if (report.risingPatterns.isNotEmpty)
        ExamTrendPatternSection(
          patterns: report.risingPatterns,
          onSolveTopic: onSolveTopic,
        ),
      if (report.frequentConcepts.isNotEmpty)
        ExamTrendConceptSection(
          concepts: report.frequentConcepts,
          onSolveTopic: onSolveTopic,
        ),
      if (report.studyTips.isNotEmpty)
        ExamTrendStudyTipSection(studyTips: report.studyTips),
    ];
    return ListView.separated(
      padding: _contentPadding,
      itemCount: sections.length,
      // 섹션이 위에서부터 차례로 떠오른다
      itemBuilder: (_, index) =>
          PassqlReveal(index: index, child: sections[index]),
      separatorBuilder: (_, _) => const SizedBox(height: PassqlSpacing.lg),
    );
  }
}
