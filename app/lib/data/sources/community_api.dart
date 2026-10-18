import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/community/community_models.dart';

part 'community_api.g.dart';

/// 커뮤니티 API (인증 필요): 피드, 문제별 의견, 좋아요·신고·차단
@RestApi()
abstract class CommunityApiClient {
  factory CommunityApiClient(Dio dio, {String baseUrl}) = _CommunityApiClient;

  /// 피드 탭별 문제 카드 (커서 페이지네이션)
  @GET('/community/feed')
  Future<CommunityFeedPageResponse> getFeed({
    @Query('source') required String source,
    @Query('cursor') String? cursor,
  });

  /// 문제별 의견 목록 (푼 문제만, 풀기 전 400 COMMUNITY_SOLVE_REQUIRED)
  @GET('/community/questions/{questionUuid}/posts')
  Future<CommunityPostPageResponse> getQuestionPosts(
    @Path('questionUuid') String questionUuid, {
    @Query('sort') required String sort,
    @Query('cursor') String? cursor,
    @Query('size') int size = 20,
  });

  /// 의견 작성 (성공 201, 만든 글 1건)
  @POST('/community/questions/{questionUuid}/posts')
  Future<CommunityPost> createQuestionPost(
    @Path('questionUuid') String questionUuid,
    @Body() CommunityPostCreateRequest body,
  );

  /// 내 글 삭제 (성공 204)
  @DELETE('/community/posts/{postUuid}')
  Future<void> deletePost(@Path('postUuid') String postUuid);

  /// 좋아요 토글 (최종 상태와 개수)
  @PUT('/community/posts/{postUuid}/like')
  Future<CommunityPostLikeResponse> toggleLike(
    @Path('postUuid') String postUuid,
  );

  /// 글 신고 (성공 204)
  @POST('/community/posts/{postUuid}/report')
  Future<void> reportPost(
    @Path('postUuid') String postUuid,
    @Body() CommunityReportRequest body,
  );

  /// 글 작성자 차단 (성공 204)
  @POST('/community/posts/{postUuid}/block-author')
  Future<void> blockAuthor(@Path('postUuid') String postUuid);

  /// 내가 차단한 사용자 목록
  @GET('/members/me/blocks')
  Future<List<BlockedMemberResponse>> getMyBlocks();

  /// 차단 해제 (성공 204)
  @DELETE('/members/me/blocks/{blockUuid}')
  Future<void> unblock(@Path('blockUuid') String blockUuid);
}
