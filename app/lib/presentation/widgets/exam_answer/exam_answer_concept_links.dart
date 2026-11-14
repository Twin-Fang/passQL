import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/concept_providers.dart';
import '../../providers/topic_providers.dart';

/// 출제 개념 > 기존 학습 연결 버튼 2개: 개념 학습(단원 상세, 개념 탭 이용 가능할 때만) · 문제 풀기(토픽 챕터)
/// 토픽 코드가 없거나 토픽 목록에 없으면 아무것도 그리지 않음
class ExamAnswerConceptLinks extends ConsumerWidget {
  const ExamAnswerConceptLinks({
    super.key,
    required this.topicCode,
    this.isInSheet = false,
  });

  final String? topicCode;

  /// 시트 안 버튼인지 (이동 전에 시트를 닫아 돌아왔을 때 시트가 남지 않게)
  final bool isInSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = topicCode;
    if (code == null || code.isEmpty) return const SizedBox.shrink();
    final topics = ref.watch(topicsProvider).valueOrNull ?? const [];
    final topic = topics.where((topic) => topic.code == code).firstOrNull;
    if (topic == null) return const SizedBox.shrink();
    final isConceptAvailable = ref.watch(isConceptLearningAvailableProvider);
    return Row(
      children: [
        if (isConceptAvailable) ...[
          Expanded(
            child: PassqlButton(
              label: '개념 학습',
              icon: CupertinoIcons.book_fill,
              variant: PassqlButtonVariant.tinted,
              size: PassqlButtonSize.small,
              onPressed: () =>
                  _open(context, AppRoutes.conceptTopic(topic.topicUuid)),
            ),
          ),
          const SizedBox(width: PassqlSpacing.xs),
        ],
        Expanded(
          child: PassqlButton(
            label: '${topic.displayName} 풀기',
            icon: CupertinoIcons.pencil,
            variant: PassqlButtonVariant.tinted,
            size: PassqlButtonSize.small,
            onPressed: () => _open(
              context,
              AppRoutes.questionChapterOf(
                topicCode: topic.code,
                topicName: topic.displayName,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 이동 (시트면 닫은 뒤, 라우터는 닫기 전에 잡아 둠)
  void _open(BuildContext context, String location) {
    final router = GoRouter.of(context);
    if (isInSheet) Navigator.of(context).pop();
    router.push(location);
  }
}
