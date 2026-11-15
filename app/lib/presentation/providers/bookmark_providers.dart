import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/bookmark/question_bookmark_models.dart';
import '../../data/sources/api_providers.dart';
import 'question_providers.dart';
import 'session_reset.dart';

/// 즐겨찾기 목록 한 번에 받는 개수 (서버 최대, #1082)
const bookmarkListPageSize = 50;

/// 즐겨찾기 풀기 한 번에 푸는 문제 수 (서버 최대)
const bookmarkPracticeSetSize = 10;

/// 즐겨찾기 목록 (최근 추가 순 첫 페이지). 로그아웃이면 빈 목록
final bookmarksProvider = FutureProvider.autoDispose<QuestionBookmarksResponse>(
  (ref) async {
    if (ref.watch(currentMemberUuidProvider) == null) {
      return const QuestionBookmarksResponse();
    }
    return ref
        .read(bookmarkApiProvider)
        .getBookmarks(page: 0, size: bookmarkListPageSize);
  },
);

/// 이번 실행에서 바꾼 즐겨찾기 상태 {문제 uuid: 즐겨찾기 여부}
/// 문제 상세 응답(isBookmarked)보다 우선, 회원이 바뀌면 비움
class QuestionBookmarkOverrides extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    ref.watch(currentMemberUuidProvider);
    return const {};
  }

  void _set(String questionUuid, bool isBookmarked) =>
      state = {...state, questionUuid: isBookmarked};

  /// 즐겨찾기 바꾸기: 화면 먼저 반영 > 서버 요청 > 실패하면 되돌리고 오류 전달
  Future<void> toggle(String questionUuid, {required bool isBookmarked}) async {
    _set(questionUuid, isBookmarked);
    final bookmarkClient = ref.read(bookmarkApiProvider);
    try {
      final status = isBookmarked
          ? await bookmarkClient.addBookmark(questionUuid)
          : await bookmarkClient.removeBookmark(questionUuid);
      _set(questionUuid, status.isBookmarked);
    } catch (_) {
      _set(questionUuid, !isBookmarked);
      rethrow;
    } finally {
      // 목록 화면이 열려 있으면 다시 받음 (성공·실패 공통)
      ref.invalidate(bookmarksProvider);
    }
  }
}

final questionBookmarkOverridesProvider =
    NotifierProvider<QuestionBookmarkOverrides, Map<String, bool>>(
      QuestionBookmarkOverrides.new,
    );

/// 문제 하나의 즐겨찾기 여부: 바꾼 값 > 상세 응답 값 (상세 불러오기 전이면 null)
final isQuestionBookmarkedProvider = Provider.autoDispose.family<bool?, String>(
  (ref, questionUuid) {
    final overridden = ref.watch(
      questionBookmarkOverridesProvider.select(
        (overrides) => overrides[questionUuid],
      ),
    );
    if (overridden != null) return overridden;
    return ref
        .watch(questionDetailProvider(questionUuid))
        .valueOrNull
        ?.isBookmarked;
  },
);

/// 즐겨찾기 풀기 문제 uuid (무작위 최대 10개)
Future<List<String>> fetchBookmarkPracticeQuestionUuids(WidgetRef ref) async {
  final response = await ref
      .read(bookmarkApiProvider)
      .getPracticeSet(size: bookmarkPracticeSetSize);
  return response.questionUuids;
}
