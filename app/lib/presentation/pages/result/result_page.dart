import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_routes.dart';
import '../../../router/result_route_arguments.dart';
import '../../design/design.dart';
import '../../widgets/question/ai_explain_sheet.dart';
import '../../widgets/question/execute_result_card.dart';
import '../../widgets/report/report_button.dart';
import '../../widgets/result/similar_questions_section.dart';

/// 정답/오답 피드백 화면.
/// 이동 인자(ResultRouteArguments 가 해석)로 채점 결과를 받아 렌더링. API 재호출 없음.
class ResultPage extends ConsumerWidget {
  /// 없으면 결과 없음 화면
  final QuestionResultArguments? arguments;

  const ResultPage({super.key, this.arguments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = arguments?.result;

    if (result == null) {
      return PassqlStatusScaffold(
        leading: PassqlNavLeading.close,
        onLeadingTap: () => context.pop(),
        body: PassqlStatusView.empty(
          icon: CupertinoIcons.exclamationmark_circle,
          title: '결과를 불러올 수 없어요',
        ),
      );
    }

    // questionUuid는 GoRouterState pathParameters에서 꺼낸다.
    final goRouterState = GoRouterState.of(context);
    final questionUuid =
        goRouterState.pathParameters[AppRoutes.questionUuidParameter] ?? '';
    final isCorrect = result.isCorrect;
    final colors = context.passqlColors;

    // AI 해설 버튼 — 오답 항상, 정답 + CONCEPT_ONLY 표시.
    // 정답 + EXECUTABLE (correctSql/correctResult 있음)은 표시 안 함.
    final showAi =
        questionUuid.isNotEmpty &&
        (!isCorrect ||
            (result.correctSql == null && result.correctResult == null));

    // 오답이면 정답 선택지 키를 제목에 다시 보여 준다(기존 헤더 문구 보존).
    final correctLabel = arguments?.correctDisplayLabel ?? result.correctKey;
    final correctTitle = !isCorrect && correctLabel != null
        ? '정답 ($correctLabel)'
        : '정답';

    return PassqlResultScaffold(
      title: '채점 결과',
      onClose: () => context.go(AppRoutes.home),
      header: _ResultHeader(isCorrect: isCorrect),
      sections: [
        // 오답일 때만 내가 고른 SQL 을 보여 준다.
        if (!isCorrect && result.selectedSql != null)
          PassqlCard(
            title: '내 답',
            child: PassqlCodeBlock(code: result.selectedSql!),
          ),
        // EXECUTABLE: 정답 SQL, CONCEPT_ONLY: 정답 키만 텍스트로.
        if (result.correctSql != null)
          PassqlCard(
            title: correctTitle,
            child: PassqlCodeBlock(code: result.correctSql!),
          )
        else
          PassqlCard(
            title: correctTitle,
            child: Text(
              correctLabel ?? '-',
              style: PassqlTypography.callout.copyWith(color: colors.label),
            ),
          ),
        // 카드가 이미 좌우 inset 을 가지므로 목록 inset 과 겹치지 않게 가로 여백을 뺀다.
        if (result.correctResult != null)
          ExecuteResultCard(
            result: result.correctResult!,
            margin: EdgeInsets.zero,
          ),
        if (result.rationale != null && result.rationale!.isNotEmpty)
          PassqlCard(
            title: '해설',
            child: Text(
              result.rationale!,
              style: PassqlTypography.callout.copyWith(color: colors.label),
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
          PassqlButton(
            label: 'AI 해설',
            variant: PassqlButtonVariant.tinted,
            onPressed: () => AiExplainSheet.show(
              context,
              // 고른 키는 서버가 마지막 제출에서 찾는다 (정답 키를 보내던 오류 수정, #496)
              payload: {'questionUuid': questionUuid},
              isErrorExplain: false,
              initialExplanation: result.explanation,
            ),
          ),
        // 기존 동작(닫기 = 홈 이동)을 그대로 유지한다.
        PassqlButton(label: '닫기', onPressed: () => context.go(AppRoutes.home)),
      ],
    );
  }
}

/// 결과 머리: 정답/오답 표시 + 처음 나타날 때 한 번 햅틱 (챕터 피드백 바와 같은 느낌)
class _ResultHeader extends StatefulWidget {
  const _ResultHeader({required this.isCorrect});

  final bool isCorrect;

  @override
  State<_ResultHeader> createState() => _ResultHeaderState();
}

class _ResultHeaderState extends State<_ResultHeader> {
  @override
  void initState() {
    super.initState();
    PassqlHaptics.playAnswerResult(isCorrect: widget.isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    return PassqlResultMark(
      isCorrect: widget.isCorrect,
      isLarge: true,
      label: widget.isCorrect ? '정답이에요' : '오답이에요',
    );
  }
}
