import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/topic_providers.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../widgets/question/topic_card.dart';

/// 문제 탭 1단계 — 토픽 선택 화면.
/// 토픽 행 탭 시 /questions/list?topic=CODE&topicName=NAME으로 이동.
class TopicListPage extends ConsumerWidget {
  const TopicListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);

    return Scaffold(
      backgroundColor: context.passqlColors.background,
      body: PassqlLargeTitleScrollView(
        title: '문제',
        // 토픽 추가·비활성화를 앱 재시작 없이 반영
        onRefresh: () async {
          ref.invalidate(topicsProvider);
          await ref.read(topicsProvider.future);
        },
        slivers: [
          topicsAsync.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: PassqlStatusView.loading(),
            ),
            // 다시 시도할 방법이 없으면 탭을 오가야 해서 버튼을 둔다 (#375).
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: PassqlStatusView.error(
                message: '토픽을 불러올 수 없어요',
                onRetry: () => ref.invalidate(topicsProvider),
              ),
            ),
            data: (topics) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                PassqlSpacing.md,
                PassqlSpacing.md,
                PassqlSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: PassqlGroupedSection(
                  header: '학습할 토픽을 선택하세요',
                  children: [
                    // 토픽 행이 위에서부터 차례로 나타난다
                    for (final (index, topic) in topics.indexed)
                      PassqlReveal(
                        index: index,
                        child: TopicCard(
                          topic: topic,
                          onTap: () => context.push(
                            AppRoutes.questionChapterOf(
                              topicCode: topic.code,
                              topicName: topic.displayName,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
