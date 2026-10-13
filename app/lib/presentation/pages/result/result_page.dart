import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/question/submit_result.dart';
import '../../design/design.dart';
import '../../widgets/question/ai_explain_sheet.dart';
import '../../widgets/question/execute_result_card.dart';
import '../../widgets/report/report_button.dart';
import '../../widgets/result/similar_questions_section.dart';

/// 정답/오답 피드백 화면.
/// GoRouterState.extra로 SubmitResult를 받아 렌더링. API 재호출 없음.
class ResultPage extends ConsumerWidget {
  final Object? extra;

  const ResultPage({super.key, this.extra});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = extra is SubmitResult ? extra as SubmitResult : null;

    if (result == null) {
      return Scaffold(
        appBar: PqNavBar(
          leading: PqNavLeading.close,
          onLeadingTap: () => context.pop(),
        ),
        body: PqStatusView.empty(
          icon: CupertinoIcons.exclamationmark_circle,
          title: '결과를 불러올 수 없어요',
        ),
      );
    }

    // questionUuid는 GoRouterState pathParameters에서 꺼낸다.
    final goRouterState = GoRouterState.of(context);
    final questionUuid = goRouterState.pathParameters['questionUuid'] ?? '';
    final isCorrect = result.isCorrect;
    final c = context.pq;

    // AI 해설 버튼 — 오답 항상, 정답 + CONCEPT_ONLY 표시.
    // 정답 + EXECUTABLE (correctSql/correctResult 있음)은 표시 안 함.
    final showAi =
        questionUuid.isNotEmpty &&
        (!isCorrect ||
            (result.correctSql == null && result.correctResult == null));

    // 오답이면 정답 선택지 키를 제목에 다시 보여 준다(기존 헤더 문구 보존).
    final correctTitle = !isCorrect && result.correctKey != null
        ? '정답 (${result.correctKey})'
        : '정답';

    return PqResultScaffold(
      title: '채점 결과',
      onClose: () => context.go('/home'),
      header: PqResultMark(
        correct: isCorrect,
        large: true,
        label: isCorrect ? '정답이에요' : '오답이에요',
      ),
      sections: [
        // 오답일 때만 내가 고른 SQL 을 보여 준다.
        if (!isCorrect && result.selectedSql != null)
          PqCard(
            title: '내 답',
            child: PqCodeBlock(code: result.selectedSql!),
          ),
        // EXECUTABLE: 정답 SQL, CONCEPT_ONLY: 정답 키만 텍스트로.
        if (result.correctSql != null)
          PqCard(
            title: correctTitle,
            child: PqCodeBlock(code: result.correctSql!),
          )
        else
          PqCard(
            title: correctTitle,
            child: Text(
              result.correctKey ?? '-',
              style: PqType.callout.copyWith(color: c.label),
            ),
          ),
        // 카드가 이미 좌우 inset 을 가지므로 목록 inset 과 겹치지 않게 가로 여백을 뺀다.
        if (result.correctResult != null)
          ExecuteResultCard(
            result: result.correctResult!,
            margin: EdgeInsets.zero,
          ),
        if (result.rationale != null && result.rationale!.isNotEmpty)
          PqCard(
            title: '해설',
            child: Text(
              result.rationale!,
              style: PqType.callout.copyWith(color: c.label),
            ),
          ),
        // 문제 신고
        if (questionUuid.isNotEmpty && result.submissionUuid != null)
          Align(
            alignment: Alignment.centerRight,
            child: ReportButton(
              questionUuid: questionUuid,
              submissionUuid: result.submissionUuid!,
              choiceSetUuid: result.choiceSetUuid,
            ),
          ),
        // 유사 문제 (비동기 로드)
        if (questionUuid.isNotEmpty)
          SimilarQuestionsSection(questionUuid: questionUuid),
      ],
      actions: [
        if (showAi)
          PqButton(
            label: 'AI 해설',
            variant: PqButtonVariant.tinted,
            onPressed: () => AiExplainSheet.show(
              context,
              payload: {
                'questionUuid': questionUuid,
                'selectedChoiceKey': result.correctKey ?? '',
              },
              isErrorExplain: false,
            ),
          ),
        // 기존 동작(닫기 = 홈 이동)을 그대로 유지한다.
        PqButton(label: '닫기', onPressed: () => context.go('/home')),
      ],
    );
  }
}
