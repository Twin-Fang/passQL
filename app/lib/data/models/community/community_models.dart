/// 피드 탭 4종 (서버 source 쿼리 값과 1:1)
enum CommunityFeedSource {
  hot('hot', '뜨는 토론'),
  trend('trend', '최신 경향'),
  solved('solved', '내가 푼 문제'),
  mine('mine', '내 의견');

  const CommunityFeedSource(this.serverValue, this.label);

  final String serverValue;
  final String label;

  /// 서버 값 > 탭 (모르는 값은 뜨는 토론)
  static CommunityFeedSource fromServerValue(String? value) => values
      .firstWhere((source) => source.serverValue == value, orElse: () => hot);
}

/// 의견 목록 정렬 (서버 sort 쿼리 값과 1:1)
enum CommunityPostSort {
  latest('latest', '최신순'),
  likes('likes', '좋아요순');

  const CommunityPostSort(this.serverValue, this.label);

  final String serverValue;
  final String label;
}

/// 글 신고 사유 (서버 category 값과 1:1)
enum CommunityReportCategory {
  abuse('ABUSE', '욕설·비방이 있어요'),
  spam('SPAM', '광고·도배예요'),
  answerSpoiler('ANSWER_SPOILER', '정답을 그대로 알려 줘요'),
  etc('ETC', '기타');

  const CommunityReportCategory(this.serverValue, this.label);

  final String serverValue;
  final String label;
}

/// 피드 문제 카드 1건: 지문 일부, 토픽, 의견 수, 최근 활동 (내 의견 탭은 내 글 수·받은 좋아요 포함)
class CommunityFeedCard {
  const CommunityFeedCard({
    required this.questionUuid,
    required this.stemPreview,
    required this.postCount,
    required this.lastActivityAt,
    required this.isSolvedByMe,
    this.topicCode,
    this.topicName,
    this.myPostCount,
    this.receivedLikeCount,
  });

  final String questionUuid;
  final String stemPreview;
  final String? topicCode;
  final String? topicName;
  final int postCount;
  final DateTime lastActivityAt;
  final bool isSolvedByMe;
  final int? myPostCount;
  final int? receivedLikeCount;

  factory CommunityFeedCard.fromJson(Map<String, dynamic> json) =>
      CommunityFeedCard(
        questionUuid: json['questionUuid'] as String,
        stemPreview: json['stemPreview'] as String? ?? '',
        topicCode: json['topicCode'] as String?,
        topicName: json['topicName'] as String?,
        postCount: json['postCount'] as int? ?? 0,
        lastActivityAt: _parseTime(json['lastActivityAt']),
        isSolvedByMe: json['isSolvedByMe'] as bool? ?? false,
        myPostCount: json['myPostCount'] as int?,
        receivedLikeCount: json['receivedLikeCount'] as int?,
      );
}

/// 피드 한 페이지: 카드 + 다음 커서 (null 이면 끝)
class CommunityFeedPageResponse {
  const CommunityFeedPageResponse({required this.items, this.nextCursor});

  final List<CommunityFeedCard> items;
  final String? nextCursor;

  factory CommunityFeedPageResponse.fromJson(Map<String, dynamic> json) =>
      CommunityFeedPageResponse(
        items: [
          for (final item in json['items'] as List? ?? const [])
            CommunityFeedCard.fromJson(item as Map<String, dynamic>),
        ],
        nextCursor: json['nextCursor'] as String?,
      );
}

/// 글에 붙은 내 풀이 (서버가 제출 기록으로 만든 값)
class SolveSnapshot {
  const SolveSnapshot({
    required this.isCorrect,
    required this.attemptCount,
    this.solvedAt,
    this.topicCode,
    this.difficulty,
  });

  final bool isCorrect;
  final int attemptCount;
  final String? solvedAt;
  final String? topicCode;
  final int? difficulty;

  /// 배지 문구: "정답 · 2번째 시도에 해결", "정답 · 한 번에 해결", "오답 · 3번 시도"
  String get badgeText {
    if (!isCorrect) return '오답 · $attemptCount번 시도';
    return attemptCount <= 1
        ? '정답 · 한 번에 해결'
        : '정답 · $attemptCount번째 시도에 해결';
  }

  factory SolveSnapshot.fromJson(Map<String, dynamic> json) => SolveSnapshot(
    isCorrect: json['isCorrect'] as bool? ?? false,
    attemptCount: json['attemptCount'] as int? ?? 1,
    solvedAt: json['solvedAt'] as String?,
    topicCode: json['topicCode'] as String?,
    difficulty: json['difficulty'] as int?,
  );
}

/// 의견 1건
class CommunityPost {
  const CommunityPost({
    required this.postUuid,
    required this.authorNickname,
    required this.content,
    required this.isMine,
    required this.likeCount,
    required this.isLikedByMe,
    required this.createdAt,
    this.solveSnapshot,
  });

  final String postUuid;
  final String authorNickname;
  final String content;
  final bool isMine;
  final int likeCount;
  final bool isLikedByMe;
  final SolveSnapshot? solveSnapshot;
  final DateTime createdAt;

  CommunityPost copyWithLike({
    required bool isLikedByMe,
    required int likeCount,
  }) => CommunityPost(
    postUuid: postUuid,
    authorNickname: authorNickname,
    content: content,
    isMine: isMine,
    likeCount: likeCount,
    isLikedByMe: isLikedByMe,
    solveSnapshot: solveSnapshot,
    createdAt: createdAt,
  );

  factory CommunityPost.fromJson(Map<String, dynamic> json) => CommunityPost(
    postUuid: json['postUuid'] as String,
    authorNickname: json['authorNickname'] as String? ?? '',
    content: json['content'] as String? ?? '',
    isMine: json['isMine'] as bool? ?? false,
    likeCount: json['likeCount'] as int? ?? 0,
    isLikedByMe: json['isLikedByMe'] as bool? ?? false,
    solveSnapshot: json['solveSnapshot'] == null
        ? null
        : SolveSnapshot.fromJson(json['solveSnapshot'] as Map<String, dynamic>),
    createdAt: _parseTime(json['createdAt']),
  );
}

/// 의견 한 페이지: 글 + 다음 커서 (null 이면 끝)
class CommunityPostPageResponse {
  const CommunityPostPageResponse({required this.items, this.nextCursor});

  final List<CommunityPost> items;
  final String? nextCursor;

  factory CommunityPostPageResponse.fromJson(Map<String, dynamic> json) =>
      CommunityPostPageResponse(
        items: [
          for (final item in json['items'] as List? ?? const [])
            CommunityPost.fromJson(item as Map<String, dynamic>),
        ],
        nextCursor: json['nextCursor'] as String?,
      );
}

/// 좋아요 토글 결과: 서버가 센 최종 값
class CommunityPostLikeResponse {
  const CommunityPostLikeResponse({
    required this.isLiked,
    required this.likeCount,
  });

  final bool isLiked;
  final int likeCount;

  factory CommunityPostLikeResponse.fromJson(Map<String, dynamic> json) =>
      CommunityPostLikeResponse(
        isLiked: json['isLiked'] as bool? ?? false,
        likeCount: json['likeCount'] as int? ?? 0,
      );
}

/// `POST /community/questions/{questionUuid}/posts` 요청 (풀이 스냅샷은 서버가 제출 기록으로 만듦)
class CommunityPostCreateRequest {
  const CommunityPostCreateRequest({
    required this.content,
    required this.includeSolveSnapshot,
  });

  final String content;
  final bool includeSolveSnapshot;

  Map<String, dynamic> toJson() => {
    'content': content,
    'includeSolveSnapshot': includeSolveSnapshot,
  };
}

/// `POST /community/posts/{postUuid}/report` 요청
class CommunityReportRequest {
  const CommunityReportRequest({required this.category, this.detail});

  final String category;
  final String? detail;

  Map<String, dynamic> toJson() => {'category': category, 'detail': ?detail};
}

/// 차단한 사용자 1명
class BlockedMemberResponse {
  const BlockedMemberResponse({
    required this.blockUuid,
    required this.nickname,
    required this.blockedAt,
  });

  final String blockUuid;
  final String nickname;
  final DateTime blockedAt;

  factory BlockedMemberResponse.fromJson(Map<String, dynamic> json) =>
      BlockedMemberResponse(
        blockUuid: json['blockUuid'] as String,
        nickname: json['nickname'] as String? ?? '',
        blockedAt: _parseTime(json['blockedAt']),
      );
}

// 서버 시각 문자열 > DateTime (파싱 실패는 에포크 0)
DateTime _parseTime(Object? value) =>
    DateTime.tryParse(value as String? ?? '') ??
    DateTime.fromMillisecondsSinceEpoch(0);
