import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/study_guide_progress.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/concept_providers.dart';
import '../../providers/lock_screen_providers.dart';
import '../../providers/study_guide_providers.dart';
import '../../widgets/study_guide/study_guide_stage_row.dart';

/// 학습 가이드 (#1078): 소개 > 매일(개념·오늘의 세트·잠금화면) > 단계 4개(진행·지금 할 단계) > 언제나(오답노트·즐겨찾기) > 팁
/// 단계 진행은 회차 목록(실전 응시) + 기기 학습 모드 완료 기준 (studyGuideProgressProvider)
class StudyGuidePage extends ConsumerWidget {
  const StudyGuidePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final progressAsync = ref.watch(studyGuideProgressProvider);
    return Scaffold(
      appBar: PassqlNavBar(title: '학습 가이드', leading: PassqlNavLeading.back),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xs,
            PassqlSpacing.md,
            PassqlSpacing.xl,
          ),
          children: [
            Text(
              '합격까지 이 순서로 공부해요',
              style: PassqlTypography.title2.copyWith(color: colors.label),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            Text(
              '매일 조금씩 개념과 문제를 풀고, 기출과 모의고사를 단계별로 넓혀 가요. 지금 할 단계를 표시해 드려요.',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.lg),
            const _DailyHabitSection(),
            const SizedBox(height: PassqlSpacing.xl),
            progressAsync.when(
              loading: () => const PassqlListSkeleton(rowCount: 4),
              error: (error, _) => PassqlStatusView.error(
                message: error.asAppException.message,
                onRetry: () => ref.invalidate(studyGuideProgressProvider),
              ),
              data: (stageProgresses) =>
                  _StageSection(stageProgresses: stageProgresses),
            ),
            const SizedBox(height: PassqlSpacing.xl),
            const _AlwaysSection(),
            const SizedBox(height: PassqlSpacing.lg),
            const PassqlCallout(
              kind: PassqlCalloutKind.accent,
              icon: CupertinoIcons.lightbulb_fill,
              label: '공부 팁',
              child: Text(
                '기출은 학습 모드로 먼저 익히고, 실전 모드로 90분 안에 푸는 연습을 해요. 틀린 문제는 오답노트에 자동으로 모여요.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 매일: 개념 학습(공개 시), 오늘의 세트, 잠금화면 문제(Android·서버 스위치)
class _DailyHabitSection extends ConsumerWidget {
  const _DailyHabitSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    return PassqlGroupedSection(
      header: '매일 꾸준히',
      children: [
        if (ref.watch(isConceptLearningAvailableProvider))
          PassqlListRow(
            title: '개념 학습',
            subtitle: '단원 순서대로 핵심 개념 익히기',
            leading: PassqlIconTile(
              icon: CupertinoIcons.book_fill,
              color: colors.accent,
            ),
            hasChevron: true,
            onTap: () => context.go(AppRoutes.concepts),
          ),
        PassqlListRow(
          title: '오늘의 세트',
          subtitle: '하루 몇 문제로 감 유지하기',
          leading: PassqlIconTile(
            icon: CupertinoIcons.calendar_today,
            color: colors.correct,
          ),
          hasChevron: true,
          onTap: () => context.push(AppRoutes.dailySet),
        ),
        if (ref.watch(isLockScreenAvailableProvider))
          PassqlListRow(
            title: '잠금화면 문제',
            subtitle: '휴대폰을 켤 때마다 한 문제',
            leading: PassqlIconTile(
              icon: CupertinoIcons.lock_fill,
              color: colors.warning,
            ),
            hasChevron: true,
            onTap: () => context.push(AppRoutes.lockScreenPreview),
          ),
      ],
    );
  }
}

/// 단계 4개: 최신 기출 > 이전 기출 > 모의고사 > FINAL·오답률 TOP 30
class _StageSection extends StatelessWidget {
  const _StageSection({required this.stageProgresses});

  final List<StudyGuideStageProgress> stageProgresses;

  @override
  Widget build(BuildContext context) {
    final currentStage = findCurrentStudyGuideStage(stageProgresses);
    StudyGuideStageProgress progressOf(StudyGuideStage stage) =>
        stageProgresses.firstWhere((progress) => progress.stage == stage);
    return PassqlGroupedSection(
      header: '단계별 순서',
      children: [
        StudyGuideStageRow(
          icon: CupertinoIcons.doc_text_fill,
          title: '1단계 최신 기출 복원',
          description: '$latestSyllabusFirstExamRound회 이후 개정 범위',
          progress: progressOf(StudyGuideStage.latestPastExams),
          isCurrentStage: currentStage == StudyGuideStage.latestPastExams,
          notReadyText: '기출 회차를 준비하고 있어요',
          onTap: () => context.push(AppRoutes.mockExamsPastTab),
        ),
        StudyGuideStageRow(
          icon: CupertinoIcons.archivebox_fill,
          title: '2단계 이전 기출로 넓히기',
          description: '${latestSyllabusFirstExamRound - 1}회 이전 기출',
          progress: progressOf(StudyGuideStage.olderPastExams),
          isCurrentStage: currentStage == StudyGuideStage.olderPastExams,
          notReadyText: '이전 회차를 준비하고 있어요',
          onTap: () => context.push(AppRoutes.mockExamsPastTab),
        ),
        StudyGuideStageRow(
          icon: CupertinoIcons.timer_fill,
          title: '3단계 모의고사',
          description: '새 보기로 신유형 대비',
          progress: progressOf(StudyGuideStage.mockExams),
          isCurrentStage: currentStage == StudyGuideStage.mockExams,
          notReadyText: '곧 첫 회차가 열려요',
          onTap: () => context.push(AppRoutes.mockExams),
        ),
        StudyGuideStageRow(
          icon: CupertinoIcons.flag_fill,
          title: '4단계 시험 직전 FINAL',
          description: '고난도 마지막 점검',
          progress: progressOf(StudyGuideStage.finalCheck),
          isCurrentStage: currentStage == StudyGuideStage.finalCheck,
          notReadyText: '시험 3일 전에 열려요',
          onTap: () => context.push(AppRoutes.mockExams),
        ),
        PassqlListRow(
          title: '오답률 TOP 30',
          subtitle: '많이 틀리는 문제로 마무리',
          leading: PassqlIconTile(
            icon: CupertinoIcons.xmark_seal_fill,
            color: context.passqlColors.wrong,
          ),
          hasChevron: true,
          onTap: () => context.push(AppRoutes.hardestQuestions),
        ),
      ],
    );
  }
}

/// 언제나: 오답노트(자동 적재), 즐겨찾기
class _AlwaysSection extends StatelessWidget {
  const _AlwaysSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlGroupedSection(
      header: '언제나',
      children: [
        PassqlListRow(
          title: '오답노트',
          subtitle: '틀린 문제가 자동으로 모여요',
          leading: PassqlIconTile(
            icon: CupertinoIcons.xmark_circle_fill,
            color: colors.wrong,
          ),
          hasChevron: true,
          onTap: () => context.push(AppRoutes.wrongNotes),
        ),
        PassqlListRow(
          title: '즐겨찾기',
          subtitle: '별을 누른 문제 다시 풀기',
          leading: PassqlIconTile(
            icon: CupertinoIcons.star_fill,
            color: colors.warning,
          ),
          hasChevron: true,
          onTap: () => context.push(AppRoutes.bookmarks),
        ),
      ],
    );
  }
}
