import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/question/submit_result.dart';
import '../../providers/ai_explanation_session_provider.dart';
import '../../providers/chapter_providers.dart';
import '../../providers/choice_explanation_providers.dart';

/// 해설함에 이번 제출 추가 > 미리보기용 해설 조회가 바로 시작되고 다음 문제로 가도 계속됨 (풀이 화면 공용)
void addSubmissionExplanationEntry(
  WidgetRef ref, {
  required String questionUuid,
  required SubmitResult result,
  required String selectedKey,
  required int questionNumber,
  required Map<String, String> displayLabelByChoiceKey,
}) {
  final request = ChoiceExplanationRequest.fromSubmission(
    questionUuid: questionUuid,
    result: result,
    selectedChoiceKey: selectedKey,
  );
  if (request == null) return;
  ref
      .read(aiExplanationSessionProvider.notifier)
      .addEntry(
        AiExplanationEntry(
          request: request,
          isCorrect: result.isCorrect,
          questionNumber: questionNumber,
          displayLabelByChoiceKey: displayLabelByChoiceKey,
          rationale: result.rationale,
          correctChoiceKey: result.correctKey,
        ),
      );
}

/// 현재 문제 제출의 해설함 항목 구독 (세트를 몰라 해설이 없으면 null, build 안에서만 호출)
AiExplanationEntry? watchSubmissionExplanationEntry(
  WidgetRef ref,
  String questionUuid,
  ChapterState chapter,
) {
  final result = chapter.lastSubmitResult;
  if (!chapter.isAnswered || result == null) return null;
  final request = ChoiceExplanationRequest.fromSubmission(
    questionUuid: questionUuid,
    result: result,
    selectedChoiceKey: chapter.lastSelectedKey,
  );
  if (request == null) return null;
  return ref.watch(
    aiExplanationSessionProvider.select(
      (session) => session.entryById(request.id),
    ),
  );
}
