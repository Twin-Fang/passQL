import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/question/question_schema_table.dart';
import '../../design/design.dart';
import '../../providers/sql_practice_providers.dart';
import '../pro/locked_preview_samples.dart';
import '../pro/pro_locked_section.dart';
import 'execute_result_card.dart';
import 'sql_practice_editor_sheet.dart';

/// 채점 뒤 직접 실행해보기 칸: 시작 SQL(정답·내 답·빈 칸) > 고치기 시트 > 실제 DB 실행 결과 (#727)
class SqlPracticeCard extends ConsumerWidget {
  const SqlPracticeCard({
    super.key,
    required this.questionUuid,
    required this.correctSql,
    this.mySql,
    this.schemaTables = const [],
    this.margin = const EdgeInsets.symmetric(
      horizontal: PassqlSpacing.md,
      vertical: PassqlSpacing.xxs,
    ),
  });

  final String questionUuid;
  final String? correctSql;

  /// 오답일 때 내가 고른 SQL (정답이면 null > '내 답에서' 칸 없음)
  final String? mySql;
  final List<QuestionSchemaTable> schemaTables;
  final EdgeInsetsGeometry margin;

  String _startSqlOf(SqlPracticeStart start) => switch (start) {
    SqlPracticeStart.correctAnswer => correctSql ?? '',
    SqlPracticeStart.myAnswer => mySql ?? '',
    SqlPracticeStart.blank => '',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final practice = ref.watch(sqlPracticeProvider(questionUuid));
    final notifier = ref.read(sqlPracticeProvider(questionUuid).notifier);
    final currentSql = practice.draftSql ?? _startSqlOf(practice.start);

    /// 고치기 시트 > 실행을 눌렀으면 고친 SQL 실행
    Future<void> openEditor() async {
      final shouldRun = await showSqlPracticeEditorSheet(
        context,
        initialSql: currentSql,
        schemaTables: schemaTables,
        onDraftChanged: notifier.updateDraft,
      );
      if (shouldRun != true) return;
      final latestPractice = ref.read(sqlPracticeProvider(questionUuid));
      await notifier.run(
        latestPractice.draftSql ?? _startSqlOf(latestPractice.start),
      );
    }

    return Padding(
      padding: margin,
      child: PassqlCard(
        title: '직접 실행해보기',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '정답 SQL 의 값을 바꿔 실제 DB 에서 실행해 보세요',
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.sm),
            // 시작 SQL 고르기
            PassqlSegmentedControl<SqlPracticeStart>(
              segments: [
                const PassqlSegment(
                  value: SqlPracticeStart.correctAnswer,
                  label: '정답에서',
                ),
                if (mySql != null)
                  const PassqlSegment(
                    value: SqlPracticeStart.myAnswer,
                    label: '내 답에서',
                  ),
                const PassqlSegment(
                  value: SqlPracticeStart.blank,
                  label: '빈 칸',
                ),
              ],
              selectedValue: practice.start,
              onSelected: notifier.changeStart,
            ),
            const SizedBox(height: PassqlSpacing.sm),
            // 지금 SQL 미리보기 (누르면 고치기)
            PassqlPressable(
              onTap: openEditor,
              semanticLabel: 'SQL 고치기',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(PassqlSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.fill,
                  borderRadius: BorderRadius.circular(PassqlRadius.md),
                ),
                child: currentSql.trim().isEmpty
                    ? Text(
                        '눌러서 SQL 을 써 보세요',
                        style: PassqlTypography.code.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      )
                    : PassqlCodeBlock(
                        code: currentSql,
                        isSelectable: false,
                        hasBackground: false,
                      ),
              ),
            ),
            const SizedBox(height: PassqlSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: PassqlButton(
                    label: '고치기',
                    icon: CupertinoIcons.pencil,
                    onPressed: openEditor,
                    variant: PassqlButtonVariant.tinted,
                    size: PassqlButtonSize.regular,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                Expanded(
                  child: PassqlButton(
                    label: '실행',
                    icon: CupertinoIcons.play_fill,
                    isLoading: practice.isExecuting,
                    onPressed: currentSql.trim().isEmpty
                        ? null
                        : () => notifier.run(currentSql),
                    size: PassqlButtonSize.regular,
                  ),
                ),
              ],
            ),
            _PracticeOutcome(practice: practice),
          ],
        ),
      ),
    );
  }
}

/// 실습 실행 결과 자리: 잠금 블러 > 결과 > 요청 실패, 없으면 비움
class _PracticeOutcome extends StatelessWidget {
  const _PracticeOutcome({required this.practice});

  final SqlPracticeState practice;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final executeResult = practice.executeResult;
    final executeFailure = practice.executeFailure;
    final Widget? outcome = practice.isExecutionLocked
        ? const ProLockedSection(
            preview: ExecutionResultLockedSample(),
            caption: LockedPreviewCaptions.executionResult,
          )
        : executeResult != null
        ? ExecuteResultCard(
            result: executeResult,
            subjectLabel: '내 SQL',
            shouldWrapInCard: false,
            margin: EdgeInsets.zero,
          )
        : executeFailure != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PassqlResultMark(isCorrect: false, label: '실행하지 못했어요'),
              const SizedBox(height: PassqlSpacing.xxs),
              Text(
                executeFailure.message,
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          )
        : null;
    if (outcome == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: PassqlSpacing.sm),
      child: outcome,
    );
  }
}
