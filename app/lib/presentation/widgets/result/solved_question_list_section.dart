import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/question_providers.dart';
import '../question/stem_text.dart';

/// 결과 화면에서 푼 문제 한 건 (문제 uuid + 정답 여부)
typedef SolvedQuestion = ({String questionUuid, bool isCorrect});

/// 결과 화면 푼 문제 목록 (랜덤 요약·챕터 결과·오늘의 세트 결과 공용, #980)
/// 틀린 문제 먼저 > 줄마다 정답·오답 표시 + 토픽·지문 한 줄, 탭 > 문제 상세 (번호 대신 무슨 문제인지 보임)
class SolvedQuestionListSection extends StatelessWidget {
  const SolvedQuestionListSection({
    super.key,
    required this.solvedQuestions,
    this.isTopicShown = true,
  });

  final List<SolvedQuestion> solvedQuestions;

  /// 줄 제목을 토픽 이름으로 할지 (한 토픽만 푼 챕터는 false > 지문이 제목)
  final bool isTopicShown;

  @override
  Widget build(BuildContext context) {
    final orderedQuestions = [
      ...solvedQuestions.where((solved) => !solved.isCorrect),
      ...solvedQuestions.where((solved) => solved.isCorrect),
    ];
    final wrongCount = solvedQuestions
        .where((solved) => !solved.isCorrect)
        .length;
    return PassqlGroupedSection(
      header: wrongCount > 0 ? '틀린 문제 $wrongCount개부터 다시 봐요' : '이번에 푼 문제',
      children: [
        for (final solved in orderedQuestions)
          _SolvedQuestionRow(solved: solved, isTopicShown: isTopicShown),
      ],
    );
  }
}

/// 푼 문제 한 줄: 정답·오답 표시 + 토픽 이름 + 지문 첫 줄 (불러오는 동안·실패면 `문제`)
class _SolvedQuestionRow extends ConsumerWidget {
  const _SolvedQuestionRow({required this.solved, required this.isTopicShown});

  final SolvedQuestion solved;
  final bool isTopicShown;

  // 지문 미리보기 최대 길이 (한 줄에 들어갈 만큼)
  static const int _stemPreviewLength = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref
        .watch(questionDetailProvider(solved.questionUuid))
        .valueOrNull;
    final stem = detail == null
        ? null
        : stripCodeFences(detail.stem).replaceAll(RegExp(r'\s+'), ' ').trim();
    final stemPreview = stem == null
        ? null
        : (stem.length > _stemPreviewLength
              ? '${stem.substring(0, _stemPreviewLength)}…'
              : stem);
    return PassqlListRow(
      leading: PassqlResultMark(isCorrect: solved.isCorrect),
      title: (isTopicShown ? detail?.topicName : stemPreview) ?? '문제',
      subtitle: isTopicShown ? stemPreview : null,
      titleMaxLines: 1,
      hasChevron: true,
      onTap: () => context.push(AppRoutes.questionDetail(solved.questionUuid)),
    );
  }
}
