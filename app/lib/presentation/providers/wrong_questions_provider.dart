import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/monitoring/app_analytics.dart';
import '../../core/network/safe_call.dart';

import '../../data/sources/api_providers.dart';
import '../../data/models/progress/wrong_questions_response.dart';
import 'session_reset.dart';

/// 오답 노트에 한 번에 보여줄 최대 개수.
const wrongNotePageSize = 20;

/// 오답 노트 Provider. 화면을 벗어나면 해제되어 돌아올 때 최신 오답을 다시 받는다.
///
/// 실패는 그대로 노출해 화면이 재시도 UI 를 보여주게 한다(선택적 섹션이 아니라
/// 이 섹션의 본 기능이므로 조용히 비우지 않는다).
final wrongQuestionsProvider =
    FutureProvider.autoDispose<WrongQuestionsResponse>((ref) async {
      // 로그아웃이면 빈 목록 (API 호출·진입 기록 없음)
      if (ref.watch(currentMemberUuidProvider) == null) {
        return const WrongQuestionsResponse();
      }
      // 오답 노트 진입 기록 (오답 노트 화면 진입·다시 시도마다 1회, 설정 개수 표시는 별도 Provider)
      ref.read(appAnalyticsProvider).logWrongNotesOpened();
      return ref
          .read(progressApiProvider)
          .getWrongQuestions(size: wrongNotePageSize);
    });

/// 설정 행에 보일 오답 개수만 조회 (목록은 1건만 받아 버림, 진입 분석 기록 없음)
/// 실패하면 null (개수 숨김)
final wrongQuestionTotalCountProvider = FutureProvider.autoDispose<int?>((
  ref,
) async {
  if (ref.watch(currentMemberUuidProvider) == null) return null;
  final response = await safeCall(
    ref.read(progressApiProvider).getWrongQuestions(size: 1),
    label: 'wrongQuestionTotalCount',
  );
  return response?.totalCount;
});
