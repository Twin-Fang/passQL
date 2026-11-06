import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/meta/topic_tree.dart';
import '../../../data/models/progress/ai_stats_analysis.dart';
import '../../../router/app_routes.dart';
import '../../../router/questions_tab_view.dart';
import '../../design/design.dart';
import '../../providers/topic_providers.dart';

/// 통계 AI 분석 바로 풀기 버튼 (#861, #862): 토픽 문제 풀기 > 챕터 흐름, 오답 다시 풀기 > 오답 노트,
/// 랜덤 풀기 > 랜덤 풀기 풀이, 최신 경향 풀기 > 문제 탭 최신 경향 보기
/// 이동할 곳을 모르는 버튼(모르는 종류·토픽 목록에 없는 토픽)은 숨김, 남은 버튼이 없으면 자리 없음
class AiAnalysisActionButtons extends ConsumerWidget {
  const AiAnalysisActionButtons({super.key, required this.actions});

  final List<AiAnalysisAction> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 서버 액션은 topicUuid 만 실음 > 챕터 경로가 받는 토픽 코드는 토픽 목록에서 짝지음
    final topics = ref.watch(topicsProvider).valueOrNull ?? const <TopicTree>[];
    final topicByUuid = {for (final topic in topics) topic.topicUuid: topic};
    final pressableActions = [
      for (final action in actions)
        if (action.label.isNotEmpty)
          if (_onPressedOf(context, action, topicByUuid) case final onPressed?)
            (action.label, onPressed),
    ];
    if (pressableActions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: PassqlSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < pressableActions.length; index++) ...[
            if (index > 0) const SizedBox(height: PassqlSpacing.xs),
            PassqlButton(
              label: pressableActions[index].$1,
              onPressed: pressableActions[index].$2,
              // 첫 버튼(가장 급한 처방)만 채움, 나머지는 옅은 강조
              variant: index == 0
                  ? PassqlButtonVariant.filled
                  : PassqlButtonVariant.tinted,
              size: PassqlButtonSize.regular,
            ),
          ],
        ],
      ),
    );
  }

  /// 버튼 종류 > 이동 동작 (이동할 곳을 모르면 null)
  VoidCallback? _onPressedOf(
    BuildContext context,
    AiAnalysisAction action,
    Map<String, TopicTree> topicByUuid,
  ) {
    switch (action.type) {
      case AiAnalysisActionType.practiceTopic:
        final topic = topicByUuid[action.topicUuid];
        if (topic == null) return null;
        // 문제 탭 토픽 목록과 같은 챕터 흐름 (제목도 같은 토픽 표시 이름)
        return () => context.push(
          AppRoutes.questionChapterOf(
            topicCode: topic.code,
            topicName: topic.displayName,
          ),
        );
      case AiAnalysisActionType.reviewWrong:
        return () => context.push(AppRoutes.wrongNotes);
      case AiAnalysisActionType.randomPractice:
        return () => context.push(AppRoutes.randomPractice);
      // 탭 루트라 go 로 탭 전환 (홈 출제 경향과 같은 이동)
      case AiAnalysisActionType.practiceLatestTrend:
        return () => context.go(QuestionsTabView.latestTrend.location);
      case AiAnalysisActionType.unknown:
        return null;
    }
  }
}
