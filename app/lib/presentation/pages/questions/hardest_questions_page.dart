import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/relative_time.dart';
import '../../../data/models/question/hardest_questions_response.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/hardest_question_providers.dart';
import '../../widgets/mock_exam/mock_exam_number_grid.dart';
import '../../widgets/question/question_preview_row.dart';

// 순위 숫자 칸 폭 (두 자리 숫자까지 같은 줄 맞춤)
const double _rankColumnWidth = 28;
// 순위 숫자를 강조색으로 쓰는 상위 순위 수
const int _highlightedRankCount = 3;

/// 오답률 TOP 30 화면 (#1080): 집계 기준 > 한 번에 풀기 버튼 > 순위 목록(오답률 막대, 토픽)
/// 문제 탭 오답률 TOP 행에서 진입, 목록은 전원 공개, 풀이 크레딧은 문제 상세 규칙
class HardestQuestionsPage extends ConsumerWidget {
  const HardestQuestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hardestAsync = ref.watch(hardestQuestionsProvider);
    return Scaffold(
      appBar: PassqlNavBar(
        title: '오답률 TOP $hardestQuestionLimit',
        leading: PassqlNavLeading.back,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xs,
            PassqlSpacing.md,
            PassqlSpacing.xl,
          ),
          // 로딩 자리 스켈레톤 > 목록·빈·오류 페이드 교체
          child: PassqlFadeSwitcher(
            child: hardestAsync.when(
              loading: () => const PassqlListSkeleton(key: ValueKey('loading')),
              error: (error, _) => KeyedSubtree(
                key: const ValueKey('error'),
                child: PassqlStatusView.error(
                  message: error.asAppException.message,
                  onRetry: () => ref.invalidate(hardestQuestionsProvider),
                ),
              ),
              data: (response) => KeyedSubtree(
                key: const ValueKey('data'),
                child: response.items.isEmpty
                    ? PassqlStatusView.empty(
                        icon: CupertinoIcons.chart_bar,
                        title: '아직 순위를 낼 만큼 푼 기록이 없어요',
                        message:
                            '${response.minimumAttemptCount}명 이상 푼 문제부터 보여요',
                      )
                    : _HardestContent(response: response),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 집계 기준 한 줄 > 한 번에 풀기 > 순위 목록
class _HardestContent extends StatelessWidget {
  const _HardestContent({required this.response});

  final HardestQuestionsResponse response;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final aggregatedWhen = formatNotificationElapsed(response.aggregatedAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          [
            '처음 푼 ${response.minimumAttemptCount}명 이상 문제 기준',
            if (aggregatedWhen.isNotEmpty) '$aggregatedWhen 집계',
          ].join(' | '),
          style: PassqlTypography.footnote.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
        const SizedBox(height: PassqlSpacing.sm),
        PassqlButton(
          label: '${response.items.length}문제 한 번에 풀기',
          icon: CupertinoIcons.play_fill,
          onPressed: () => context.push(AppRoutes.hardestPractice),
        ),
        const SizedBox(height: PassqlSpacing.md),
        PassqlGroupedSection(
          children: [
            for (final item in response.items) _HardestRow(item: item),
          ],
        ),
      ],
    );
  }
}

class _HardestRow extends StatelessWidget {
  const _HardestRow({required this.item});

  final HardestQuestionItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final wrongRateLabel = '오답률 ${item.wrongRatePercent.toStringAsFixed(1)}%';
    return QuestionPreviewRow(
      leading: SizedBox(
        width: _rankColumnWidth,
        child: Text(
          '${item.rank}',
          textAlign: TextAlign.center,
          style: PassqlTypography.headline.copyWith(
            color: item.rank <= _highlightedRankCount
                ? colors.accentText
                : colors.secondaryLabel,
            fontFeatures: PassqlTypography.tabular,
          ),
        ),
      ),
      leadingSemanticLabel: '${item.rank}위',
      stemPreview: item.stemPreview,
      // 메타 한 줄: 오답률 | 토픽 | 과목 | 푼 사람 수
      metaParts: [
        wrongRateLabel,
        item.topicName ?? '',
        mockExamSubjectShortName(item.subject),
        '${item.attemptCount}명',
      ],
      footer: PassqlProgressBar(
        value: item.wrongRatePercent / 100,
        fillColor: colors.wrong,
        semanticValue: wrongRateLabel,
      ),
      onTap: () => context.push(AppRoutes.questionDetail(item.questionUuid)),
    );
  }
}
