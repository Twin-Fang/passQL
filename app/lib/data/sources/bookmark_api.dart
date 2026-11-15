import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/bookmark/question_bookmark_models.dart';

part 'bookmark_api.g.dart';

/// 문제 즐겨찾기 API (#1082, 등급 제한 없음)
@RestApi()
abstract class BookmarkApiClient {
  factory BookmarkApiClient(Dio dio, {String baseUrl}) = _BookmarkApiClient;

  /// 즐겨찾기 추가 (이미 있으면 그대로 성공)
  @PUT('/questions/{questionUuid}/bookmark')
  Future<QuestionBookmarkStatusResponse> addBookmark(
    @Path('questionUuid') String questionUuid,
  );

  /// 즐겨찾기 해제 (없어도 성공)
  @DELETE('/questions/{questionUuid}/bookmark')
  Future<QuestionBookmarkStatusResponse> removeBookmark(
    @Path('questionUuid') String questionUuid,
  );

  /// 즐겨찾기 목록 (최근 추가 순, page 0부터, size 최대 50)
  @GET('/bookmarks')
  Future<QuestionBookmarksResponse> getBookmarks({
    @Query('page') int? page,
    @Query('size') int? size,
  });

  /// 즐겨찾기 풀기 묶음 (무작위 최대 10개)
  @GET('/bookmarks/practice-set')
  Future<QuestionBookmarkPracticeSetResponse> getPracticeSet({
    @Query('size') int? size,
  });
}
