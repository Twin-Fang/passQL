import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/question/hardest_questions_response.dart';
import '../../data/sources/api_providers.dart';
import 'session_reset.dart';

/// 오답률 TOP 개수 (서버 최대, #1080)
const hardestQuestionLimit = 30;

/// 오답률 TOP 목록. 로그아웃이면 빈 목록, 화면을 벗어나면 해제
final hardestQuestionsProvider =
    FutureProvider.autoDispose<HardestQuestionsResponse>((ref) async {
      if (ref.watch(currentMemberUuidProvider) == null) {
        return const HardestQuestionsResponse();
      }
      return ref
          .read(questionApiProvider)
          .getHardestQuestions(limit: hardestQuestionLimit);
    });

/// 오답률 TOP 한 번에 풀기 문제 uuid (순위 순서)
Future<List<String>> fetchHardestQuestionUuids(WidgetRef ref) async {
  final response = await ref
      .read(questionApiProvider)
      .getHardestQuestions(limit: hardestQuestionLimit);
  return [for (final item in response.items) item.questionUuid];
}
