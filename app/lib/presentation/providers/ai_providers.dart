import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/safe_call.dart';
import '../../data/models/ai/similar_question.dart';
import '../../data/sources/api_providers.dart';

/// AI 해설 요청 1건: 종류(SQL 실행 오류 / 오답) + 서버로 보낼 본문
/// provider family 키라서 본문 내용이 같으면 같은 요청으로 본다.
@immutable
class AiExplanationRequest {
  const AiExplanationRequest({
    required this.isErrorExplanation,
    required this.payload,
  });

  /// true: explain-error(SQL 실행 오류), false: diff-explain(오답)
  final bool isErrorExplanation;
  final Map<String, dynamic> payload;

  @override
  bool operator ==(Object other) =>
      other is AiExplanationRequest &&
      other.isErrorExplanation == isErrorExplanation &&
      mapEquals(other.payload, payload);

  @override
  int get hashCode => Object.hash(
    isErrorExplanation,
    Object.hashAllUnordered(
      payload.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}

/// AI 해설 본문. 시트를 닫으면 해제되고 실패는 그대로 노출(시트가 안내 문구로 표시)
final aiExplanationProvider = FutureProvider.autoDispose
    .family<String, AiExplanationRequest>((ref, request) async {
      final aiClient = ref.read(aiApiProvider);
      final explanation = request.isErrorExplanation
          ? await aiClient.explainError(request.payload)
          : await aiClient.diffExplain(request.payload);
      return explanation.text;
    });

/// 결과 화면에 보여 줄 비슷한 문제 수
const similarQuestionCount = 3;

/// 비슷한 문제 목록. 선택 섹션이라 실패하면 빈 목록(인증 만료는 safeCall 이 다시 던짐)
final similarQuestionsProvider = FutureProvider.autoDispose
    .family<List<SimilarQuestion>, String>((ref, questionUuid) async {
      final similarQuestions = await safeCall(
        ref.read(aiApiProvider).getSimilar(questionUuid, similarQuestionCount),
        label: 'similarQuestions',
      );
      return similarQuestions ?? const [];
    });
