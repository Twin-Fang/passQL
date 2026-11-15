import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/safe_call.dart';

import '../../data/sources/api_providers.dart';
import '../../data/models/mock_exam/mock_exam_enums.dart';
import '../../data/models/progress/wrong_note_filter.dart';
import '../../data/models/progress/wrong_questions_response.dart';
import 'pro_ui_providers.dart';
import 'session_reset.dart';

/// 오답 노트에 한 번에 보여줄 최대 개수.
const wrongNotePageSize = 20;

/// 오답 다시 풀기 한 번에 푸는 문제 수 (서버 최대와 같음, #1081)
const wrongNoteRetrySetSize = 10;

/// 오답 노트 필터 (#1081): 과목(null 전체), 정렬, 정리된 문제 포함 여부
typedef WrongNotesFilter = ({
  MockExamSubject? subject,
  WrongQuestionSort sort,
  bool isResolvedIncluded,
});

/// 오답 노트 화면 필터 상태. 화면을 벗어나면 기본값(전체, 최근 틀린 순, 정리됨 제외)으로
final wrongNotesFilterProvider = StateProvider.autoDispose<WrongNotesFilter>(
  (ref) => (
    subject: null,
    sort: WrongQuestionSort.recent,
    isResolvedIncluded: false,
  ),
);

/// 오답 노트 Provider. 화면을 벗어나면 해제되어 돌아올 때 최신 오답을 다시 받는다.
///
/// 실패는 그대로 노출해 화면이 재시도 UI 를 보여주게 한다(선택적 섹션이 아니라
/// 이 섹션의 본 기능이므로 조용히 비우지 않는다).
final wrongQuestionsProvider =
    FutureProvider.autoDispose<WrongQuestionsResponse>((ref) async {
      // 로그아웃이면 빈 목록 (API 호출 없음)
      if (ref.watch(currentMemberUuidProvider) == null) {
        return const WrongQuestionsResponse();
      }
      final filter = ref.watch(wrongNotesFilterProvider);
      return ref
          .read(progressApiProvider)
          .getWrongQuestions(
            size: wrongNotePageSize,
            subject: subjectQueryValueOf(filter.subject),
            sort: filter.sort.serverValue,
            includeResolved: filter.isResolvedIncluded,
          );
    });

/// 오답 다시 풀기 문제 uuid (정리 안 된 오답 많이 틀린 순, [subject] null 이면 전체, #1081)
Future<List<String>> fetchWrongNoteRetryQuestionUuids(
  WidgetRef ref,
  MockExamSubject? subject,
) async {
  final response = await ref
      .read(progressApiProvider)
      .getWrongQuestionRetrySet(
        subject: subjectQueryValueOf(subject),
        size: wrongNoteRetrySetSize,
      );
  return response.questionUuids;
}

/// 문제 탭 오답 노트 바로가기에 보일 남은 오답 개수만 조회 (목록은 1건만 받아 버림, 정리된 문제 제외)
/// 실패하면 null (개수 숨김), 무료(결제 켜짐)면 요청 없이 null (오답 목록 잠금)
final wrongQuestionTotalCountProvider = FutureProvider.autoDispose<int?>((
  ref,
) async {
  if (ref.watch(currentMemberUuidProvider) == null) return null;
  final progressClient = ref.read(progressApiProvider);
  if (await watchIsProFeatureLocked(ref)) return null;
  final response = await safeCall(
    progressClient.getWrongQuestions(size: 1),
    label: 'wrongQuestionTotalCount',
  );
  return response?.totalCount;
});
