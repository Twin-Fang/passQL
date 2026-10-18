import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_call.dart';
import '../../core/network/safe_call.dart';
import '../../data/community/community_image_compressor.dart';
import '../../data/models/community/community_models.dart';
import '../../data/sources/api_providers.dart';
import '../../data/sources/community_api.dart';
import 'session_reset.dart';

/// 피드 탭 1개의 목록 상태: 불러온 카드, 다음 커서, 추가 로딩 중 여부
@immutable
class CommunityFeedState {
  const CommunityFeedState({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final List<CommunityFeedCard> items;

  /// null 이면 마지막 페이지
  final String? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;

  CommunityFeedState copyWith({bool? isLoadingMore}) => CommunityFeedState(
    items: items,
    nextCursor: nextCursor,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// 피드 탭 목록: 첫 페이지 조회 + 커서 무한 스크롤
/// 회원별 데이터 (#516): 로그아웃이면 API 호출 없이 로딩 유지, 회원이 바뀌면 재생성
class CommunityFeedNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          CommunityFeedState,
          CommunityFeedSource
        > {
  @override
  Future<CommunityFeedState> build(CommunityFeedSource arg) async {
    if (ref.watch(currentMemberUuidProvider) == null) {
      return waitForSignedInMember();
    }
    final page = await callApiThrowingAppException(
      ref.read(communityApiProvider).getFeed(source: arg.serverValue),
    );
    return CommunityFeedState(items: page.items, nextCursor: page.nextCursor);
  }

  /// 처음부터 다시 조회 (당겨서 새로고침)
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  /// 다음 페이지 이어 붙이기 (마지막 페이지·로딩 중·실패 > 변화 없음)
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref
          .read(communityApiProvider)
          .getFeed(source: arg.serverValue, cursor: current.nextCursor);
      state = AsyncData(
        CommunityFeedState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } catch (error) {
      debugPrint('[community feed] load more failed : $error');
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final communityFeedProvider = AsyncNotifierProvider.autoDispose
    .family<CommunityFeedNotifier, CommunityFeedState, CommunityFeedSource>(
      CommunityFeedNotifier.new,
    );

/// 의견 목록 조회 조건: 문제 + 정렬
typedef CommunityPostsQuery = ({String questionUuid, CommunityPostSort sort});

/// 의견 목록 상태: 불러온 글, 다음 커서, 추가 로딩 중 여부
@immutable
class CommunityPostsState {
  const CommunityPostsState({
    required this.items,
    this.nextCursor,
    this.isLoadingMore = false,
  });

  final List<CommunityPost> items;

  /// null 이면 마지막 페이지
  final String? nextCursor;
  final bool isLoadingMore;

  bool get hasMore => nextCursor != null;

  CommunityPostsState copyWith({
    List<CommunityPost>? items,
    bool? isLoadingMore,
  }) => CommunityPostsState(
    items: items ?? this.items,
    nextCursor: nextCursor,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// 문제 1개의 의견 목록: 조회, 무한 스크롤, 작성, 좋아요, 삭제, 신고, 작성자 차단
/// 풀기 전이면 build 가 COMMUNITY_SOLVE_REQUIRED(AppException) 로 실패 > 화면이 풀기 안내로 분기
class CommunityPostsNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          CommunityPostsState,
          CommunityPostsQuery
        > {
  @override
  Future<CommunityPostsState> build(CommunityPostsQuery arg) async {
    if (ref.watch(currentMemberUuidProvider) == null) {
      return waitForSignedInMember();
    }
    final page = await callApiThrowingAppException(
      ref
          .read(communityApiProvider)
          .getQuestionPosts(arg.questionUuid, sort: arg.sort.serverValue),
    );
    return CommunityPostsState(items: page.items, nextCursor: page.nextCursor);
  }

  CommunityApiClient get _api => ref.read(communityApiProvider);

  /// 처음부터 다시 조회 (당겨서 새로고침)
  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  /// 다음 페이지 이어 붙이기 (마지막 페이지·로딩 중·실패 > 변화 없음)
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await _api.getQuestionPosts(
        arg.questionUuid,
        sort: arg.sort.serverValue,
        cursor: current.nextCursor,
      );
      state = AsyncData(
        CommunityPostsState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
        ),
      );
    } catch (error) {
      debugPrint('[community posts] load more failed : $error');
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// 이미지 1장 업로드: 본체 + 썸네일 multipart > 서버 imageUuid (실패는 AppException 그대로)
  Future<String> uploadImage(CompressedCommunityImage compressed) async {
    final uploaded = await callApiThrowingAppException(
      _api.uploadImage(
        FormData.fromMap({
          'image': MultipartFile.fromBytes(
            compressed.imageBytes,
            filename: 'image.webp',
            contentType: DioMediaType('image', 'webp'),
          ),
          'thumbnail': MultipartFile.fromBytes(
            compressed.thumbnailBytes,
            filename: 'thumbnail.webp',
            contentType: DioMediaType('image', 'webp'),
          ),
        }),
      ),
    );
    return uploaded.imageUuid;
  }

  /// 의견 작성: 서버 저장 > 이 문제의 두 정렬 목록 + 피드 다시 조회 (실패는 AppException 그대로)
  Future<void> submitPost({
    required String content,
    required bool shouldIncludeSolveSnapshot,
    List<String> imageUuids = const [],
  }) async {
    await callApiThrowingAppException(
      _api.createQuestionPost(
        arg.questionUuid,
        CommunityPostCreateRequest(
          content: content,
          includeSolveSnapshot: shouldIncludeSolveSnapshot,
          imageUuids: imageUuids,
        ),
      ),
    );
    _refreshAfterContentChange();
  }

  /// 좋아요 토글: 화면에 먼저 반영 > 서버 값으로 확정 (실패하면 되돌리고 AppException)
  Future<void> toggleLike(CommunityPost post) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final optimisticLikeCount = post.likeCount + (post.isLikedByMe ? -1 : 1);
    _replacePost(
      post.postUuid,
      (target) => target.copyWithLike(
        isLikedByMe: !post.isLikedByMe,
        likeCount: optimisticLikeCount < 0 ? 0 : optimisticLikeCount,
      ),
    );
    try {
      final result = await callApiThrowingAppException(
        _api.toggleLike(post.postUuid),
      );
      _replacePost(
        post.postUuid,
        (target) => target.copyWithLike(
          isLikedByMe: result.isLiked,
          likeCount: result.likeCount,
        ),
      );
    } catch (_) {
      _replacePost(post.postUuid, (_) => post);
      rethrow;
    }
  }

  /// 내 글 삭제: 서버 > 목록에서 제거 + 피드 다시 조회
  Future<void> deletePost(String postUuid) async {
    await callApiThrowingAppException(_api.deletePost(postUuid));
    _removePost(postUuid);
    ref.invalidate(communityFeedProvider);
  }

  /// 신고: 서버 접수 > 이 목록에서 숨김
  Future<void> reportPost({
    required String postUuid,
    required CommunityReportCategory category,
    String? detail,
  }) async {
    final trimmedDetail = detail?.trim();
    await callApiThrowingAppException(
      _api.reportPost(
        postUuid,
        CommunityReportRequest(
          category: category.serverValue,
          detail: trimmedDetail == null || trimmedDetail.isEmpty
              ? null
              : trimmedDetail,
        ),
      ),
    );
    _removePost(postUuid);
  }

  /// 작성자 차단: 서버 > 차단 목록·모든 의견 목록·피드 다시 조회 (그 작성자의 글이 사라짐)
  Future<void> blockAuthor(String postUuid) async {
    await callApiThrowingAppException(_api.blockAuthor(postUuid));
    ref.invalidate(blockedMembersProvider);
    _refreshAfterContentChange();
  }

  void _refreshAfterContentChange() {
    ref.invalidate(communityQuestionPostsProvider);
    ref.invalidate(communityFeedProvider);
  }

  void _replacePost(
    String postUuid,
    CommunityPost Function(CommunityPost post) transform,
  ) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final post in current.items)
            post.postUuid == postUuid ? transform(post) : post,
        ],
      ),
    );
  }

  void _removePost(String postUuid) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final post in current.items)
            if (post.postUuid != postUuid) post,
        ],
      ),
    );
  }
}

final communityQuestionPostsProvider = AsyncNotifierProvider.autoDispose
    .family<CommunityPostsNotifier, CommunityPostsState, CommunityPostsQuery>(
      CommunityPostsNotifier.new,
    );

/// 문제 결과 화면 '의견 N' 칩용 개수: 최신순 첫 페이지 기준 (다음 페이지가 있으면 [hasMore] > "N+")
/// 조회 중·실패(풀기 전 포함) > null (칩은 개수 없이 표시)
typedef CommunityOpinionCount = ({int count, bool hasMore});

final communityOpinionCountProvider = Provider.autoDispose
    .family<CommunityOpinionCount?, String>((ref, questionUuid) {
      final posts = ref
          .watch(
            communityQuestionPostsProvider((
              questionUuid: questionUuid,
              sort: CommunityPostSort.latest,
            )),
          )
          .valueOrNull;
      if (posts == null) return null;
      return (count: posts.items.length, hasMore: posts.hasMore);
    });

/// 홈 '오늘의 토론': 뜨는 토론 1위 문제 (없거나 조회 실패 > null, 카드 숨김)
final communityDailyDiscussionProvider =
    FutureProvider.autoDispose<CommunityFeedCard?>((ref) async {
      if (ref.watch(currentMemberUuidProvider) == null) return null;
      final page = await safeCall(
        ref
            .read(communityApiProvider)
            .getFeed(source: CommunityFeedSource.hot.serverValue),
        label: 'communityDailyDiscussion',
      );
      return page?.items.firstOrNull;
    });

/// 차단한 사용자 목록: 조회 + 해제 (설정 > 차단한 사용자 관리)
class BlockedMembersNotifier
    extends AutoDisposeAsyncNotifier<List<BlockedMemberResponse>> {
  @override
  Future<List<BlockedMemberResponse>> build() async {
    if (ref.watch(currentMemberUuidProvider) == null) {
      return waitForSignedInMember();
    }
    return callApiThrowingAppException(
      ref.read(communityApiProvider).getMyBlocks(),
    );
  }

  /// 차단 해제: 서버 > 목록에서 제거 + 의견 목록·피드 다시 조회 (실패는 AppException 그대로)
  Future<void> unblock(String blockUuid) async {
    await callApiThrowingAppException(
      ref.read(communityApiProvider).unblock(blockUuid),
    );
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData([
        for (final blocked in current)
          if (blocked.blockUuid != blockUuid) blocked,
      ]);
    }
    ref.invalidate(communityQuestionPostsProvider);
    ref.invalidate(communityFeedProvider);
  }
}

final blockedMembersProvider =
    AsyncNotifierProvider.autoDispose<
      BlockedMembersNotifier,
      List<BlockedMemberResponse>
    >(BlockedMembersNotifier.new);
