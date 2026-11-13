import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/question_providers.dart';
import '../question/stem_text.dart';

/// 결과 화면에서 푼 문제 한 건 (문제 uuid + 정답 여부)
typedef SolvedQuestion = ({String questionUuid, bool isCorrect});

/// 결과 화면 푼 문제 표 (오늘의 세트 결과·랜덤 요약·챕터 결과 공용, #980 > #999)
/// 문제마다 한 행: 토픽 이름(또는 지문 한 줄) | 정답·오답, 탭 > 문제 상세 (다시 풀기·해설)
class SolvedQuestionResultTable extends ConsumerWidget {
  const SolvedQuestionResultTable({
    super.key,
    required this.query,
    required this.solvedQuestions,
    this.isTopicShown = true,
    this.isWrongFirst = false,
    this.collapsedRowLimit = defaultCollapsedRowLimit,
    this.retriedCorrectQuestionUuids = const {},
  });

  /// 표 위 SQL 문 (화면마다 상수 한 곳)
  final String query;
  final List<SolvedQuestion> solvedQuestions;

  /// 행 이름을 토픽으로 할지 (한 토픽만 푼 챕터는 false > 지문 한 줄)
  final bool isTopicShown;

  /// 틀린 문제 먼저 (접힌 표에서도 다시 풀 문제가 보이게)
  final bool isWrongFirst;

  /// 접힌 상태에서 보일 행 수 (오늘의 세트 5문제는 접히지 않음)
  final int collapsedRowLimit;

  /// 다시 풀어 맞힌 문제 uuid (오늘의 세트 다시 풀기, 행에 `맞힘` 표시, #1035)
  final Set<String> retriedCorrectQuestionUuids;

  static const int defaultCollapsedRowLimit = 5;

  // 지문 미리보기 최대 길이 (한 줄에 들어갈 만큼)
  static const int _stemPreviewLength = 40;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderedQuestions = isWrongFirst
        ? [
            ...solvedQuestions.where((solved) => !solved.isCorrect),
            ...solvedQuestions.where((solved) => solved.isCorrect),
          ]
        : solvedQuestions;
    return PassqlQueryResultTable(
      query: query,
      labelColumnTitle: isTopicShown ? '영역' : '문제',
      collapsedRowLimit: collapsedRowLimit,
      rows: [
        for (var index = 0; index < orderedQuestions.length; index++)
          PassqlQueryResultRow(
            label: _labelOf(ref, orderedQuestions[index], index),
            isCorrect: orderedQuestions[index].isCorrect,
            isRetriedCorrect: retriedCorrectQuestionUuids.contains(
              orderedQuestions[index].questionUuid,
            ),
            onTap: () => context.push(
              AppRoutes.questionDetail(orderedQuestions[index].questionUuid),
            ),
          ),
      ],
    );
  }

  /// 행 이름: 토픽 이름 또는 지문 한 줄 (불러오는 동안·실패면 `문제 N`)
  String _labelOf(WidgetRef ref, SolvedQuestion solved, int index) {
    final detail = ref
        .watch(questionDetailProvider(solved.questionUuid))
        .valueOrNull;
    final fallbackLabel = '문제 ${index + 1}';
    if (detail == null) return fallbackLabel;
    if (isTopicShown) return detail.topicName ?? fallbackLabel;
    final stem = stripCodeFences(
      detail.stem,
    ).replaceAll(RegExp(r'\s+'), ' ').trim();
    return stem.length > _stemPreviewLength
        ? '${stem.substring(0, _stemPreviewLength)}…'
        : stem;
  }
}
