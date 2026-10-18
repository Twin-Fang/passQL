package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.question.dto.community.CommunityFeedPageResponse;
import com.passql.question.dto.community.CommunityImageUploadResponse;
import com.passql.question.dto.community.CommunityPostCreateRequest;
import com.passql.question.dto.community.CommunityPostItemResponse;
import com.passql.question.dto.community.CommunityPostLikeResponse;
import com.passql.question.dto.community.CommunityPostPageResponse;
import com.passql.question.dto.community.CommunityReportRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Tag(name = "Community", description = "수험생 커뮤니티: 피드 / 문제별 글 / 좋아요 / 신고 / 차단")
public interface CommunityControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "커뮤니티 피드 조회 API 추가"),
    })
    @Operation(
        summary = "커뮤니티 피드 조회 (문제 카드 목록)",
        description = """
            ## 인증(JWT): **필요**

            ## 쿼리 파라미터
            - **`source`**: hot(뜨는 토론, 기본값) / trend(최신 경향) / solved(내가 푼 문제, 오답 먼저) / mine(내 의견)
            - **`cursor`**: 이전 응답의 nextCursor (처음이면 비움)

            ## 반환값 (CommunityFeedPageResponse)
            - **`items`**: questionUuid, stemPreview(앞 80자·마크다운 제거), topicCode, topicName, postCount, lastActivityAt,
              isSolvedByMe, myPostCount·receivedLikeCount(mine 탭만 값, 그 외 null)
            - **`nextCursor`**: 다음 페이지 커서 (마지막이면 null)

            ## 설명
            - 페이지 크기 20 고정. hot·trend 는 서버가 60초 캐시한 후보로 카드를 조립한다.
            - postCount 는 노출 중 글 수 집계(5분 주기)라 차단한 회원 글을 빼지 않는다. 글 목록에서 차단 글은 빠진다.
            - 풀지 않은 문제 카드(isSolvedByMe=false)를 열면 글 목록 API 가 400 COMMUNITY_SOLVE_REQUIRED 를 준다.
            """
    )
    CommunityFeedPageResponse getFeed(@AuthMember LoginMember loginMember,
                                      @RequestParam(required = false) String source,
                                      @RequestParam(required = false) String cursor);

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "문제별 글 목록 조회 API 추가"),
    })
    @Operation(
        summary = "문제별 글(의견) 목록 조회",
        description = """
            ## 인증(JWT): **필요**

            ## 경로 변수
            - **`questionUuid`**: 문제 UUID

            ## 쿼리 파라미터
            - **`sort`**: latest(기본값) / likes
            - **`cursor`**: 이전 응답의 nextCursor
            - **`size`**: 페이지 크기 (기본 20, 최대 50)

            ## 반환값 (CommunityPostPageResponse)
            - **`items`**: postUuid, authorNickname, content, isMine, likeCount, isLikedByMe, solveSnapshot(없으면 null), createdAt
            - **`nextCursor`**: 다음 페이지 커서 (마지막이면 null)
            - solveSnapshot: isCorrect, attemptCount, solvedAt, topicCode, difficulty

            ## 설명
            - 숨김·삭제 글과 내가 차단한 작성자의 글은 제외. 작성자 회원 UUID 는 제공하지 않는다.

            ## 에러
            - 400 COMMUNITY_SOLVE_REQUIRED: 이 문제를 푼 기록이 없음 (앱이 '풀고 나서 볼 수 있어요' 안내)
            - 404 QUESTION_NOT_FOUND
            """
    )
    CommunityPostPageResponse getQuestionPosts(@AuthMember LoginMember loginMember, @PathVariable UUID questionUuid,
                                               @RequestParam(required = false) String sort,
                                               @RequestParam(required = false) String cursor,
                                               @RequestParam(required = false) Integer size);

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "문제별 글 작성 API 추가 (풀이 스냅샷 첨부 옵션)"),
    })
    @Operation(
        summary = "문제별 글(의견) 작성",
        description = """
            ## 인증(JWT): **필요**

            ## 요청 바디 (CommunityPostCreateRequest)
            - **`content`**: 본문 (공백 제거 후 1~500자, 금칙어 불가)
            - **`includeSolveSnapshot`**: true 면 서버가 내 제출 기록으로 풀이 요약을 붙임 (클라이언트 값은 받지 않음)
            - **`imageUuids`**: 업로드 API 로 올린 내 이미지 UUID, 최대 2장 (없으면 null·빈 목록)

            ## 반환값 (201, CommunityPostItemResponse)
            - 이미지가 있으면 `images`: imageUuid, url, thumbnailUrl, width, height (url 은 인증이 필요한 서버 경로)

            ## 에러
            - 400 COMMUNITY_SOLVE_REQUIRED: 이 문제를 푼 기록이 없음 (스냅샷 요청 포함)
            - 400 COMMUNITY_CONTENT_INVALID / COMMUNITY_CONTENT_FORBIDDEN_WORD
            - 409 COMMUNITY_POST_DUPLICATE: 5분 안에 같은 내용 작성
            - 429 COMMUNITY_POST_RATE_LIMITED(분당 5건) / COMMUNITY_POST_DAILY_LIMIT_EXCEEDED(하루 100건)
            - 400 COMMUNITY_IMAGE_TOO_MANY(3장 이상) / COMMUNITY_IMAGE_INVALID_ATTACHMENT(남의 이미지·이미 첨부·중복·없는 이미지)
            """
    )
    CommunityPostItemResponse createQuestionPost(@AuthMember LoginMember loginMember, @PathVariable UUID questionUuid,
                                                 @RequestBody CommunityPostCreateRequest request);

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "글 삭제 API 추가"),
    })
    @Operation(
        summary = "내 글 삭제",
        description = """
            ## 인증(JWT): **필요**

            ## 에러
            - 403 COMMUNITY_POST_FORBIDDEN: 본인 글이 아님
            - 404 COMMUNITY_POST_NOT_FOUND
            - 응답 204 (본문 없음)
            """
    )
    void deletePost(@AuthMember LoginMember loginMember, @PathVariable UUID postUuid);

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "글 좋아요 토글 API 추가"),
    })
    @Operation(
        summary = "글 좋아요 토글",
        description = """
            ## 인증(JWT): **필요**

            ## 반환값 (CommunityPostLikeResponse)
            - **`isLiked`**: 토글 후 내 좋아요 여부
            - **`likeCount`**: 토글 후 글 좋아요 수

            ## 에러
            - 400 COMMUNITY_SOLVE_REQUIRED / 404 COMMUNITY_POST_NOT_FOUND (숨김·삭제 글 포함)
            """
    )
    CommunityPostLikeResponse toggleLike(@AuthMember LoginMember loginMember, @PathVariable UUID postUuid);

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "글 신고 API 추가 (3명 누적 시 자동 숨김)"),
    })
    @Operation(
        summary = "글 신고",
        description = """
            ## 인증(JWT): **필요**

            ## 요청 바디 (CommunityReportRequest)
            - **`category`**: ABUSE(욕설·비방) / SPAM(광고·스팸) / ANSWER_SPOILER(정답 노출) / ETC(기타)
            - **`detail`**: 상세 (선택, 최대 200자)

            ## 설명
            - 이미 신고한 글은 무시(204). 서로 다른 회원 3명이 신고하면 자동 숨김 후 관리자 검토.

            ## 에러
            - 400 COMMUNITY_SELF_REPORT_FORBIDDEN: 내 글
            - 400 INVALID_INPUT_VALUE: category 오류, detail 200자 초과
            - 404 COMMUNITY_POST_NOT_FOUND
            - 응답 204 (본문 없음)
            """
    )
    void reportPost(@AuthMember LoginMember loginMember, @PathVariable UUID postUuid, @RequestBody CommunityReportRequest request);

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "글 작성자 차단 API 추가"),
    })
    @Operation(
        summary = "글 작성자 차단",
        description = """
            ## 인증(JWT): **필요**

            ## 설명
            - 서버가 글의 작성자를 찾아 차단한다 (작성자 UUID 는 응답에 없음). 이미 차단했으면 무시(204).
            - 차단하면 내 글 목록에서 그 회원 글이 빠진다. 해제는 GET/DELETE /api/members/me/blocks.

            ## 에러
            - 400 COMMUNITY_SELF_BLOCK_FORBIDDEN: 내 글
            - 404 COMMUNITY_POST_NOT_FOUND
            - 응답 204 (본문 없음)
            """
    )
    void blockAuthor(@AuthMember LoginMember loginMember, @PathVariable UUID postUuid);

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "커뮤니티 이미지 업로드 API 추가"),
    })
    @Operation(
        summary = "커뮤니티 이미지 업로드 (multipart)",
        description = """
            ## 인증(JWT): **필요**

            ## 요청 (multipart/form-data)
            - **`image`**: WebP 원본 (500KB 이하, 긴 변 1600px 이하)
            - **`thumbnail`**: WebP 썸네일 (60KB 이하, 앱이 만들어 보냄)

            ## 반환값 (201, CommunityImageUploadResponse)
            - **`imageUuid`**: 글 작성 요청의 `imageUuids` 에 담는다
            - **`objectKey`**: 서버 저장 키 (임시 community/tmp/..., 24시간 안에 글에 붙이지 않으면 삭제)
            - **`url`**, **`thumbnailUrl`**, **`width`**, **`height`**

            ## 설명
            - WebP 판별은 파일 앞부분(RIFF....WEBP)으로만 한다 (Content-Type 은 보지 않음). 서버는 재인코딩하지 않는다.
            - 한도: 분당 5장, 하루 20장, 회원 누적 50MB

            ## 에러
            - 400 COMMUNITY_IMAGE_INVALID_FORMAT(WebP 아님·빈 파일) / COMMUNITY_IMAGE_DIMENSION_EXCEEDED / COMMUNITY_IMAGE_QUOTA_EXCEEDED
            - 413 COMMUNITY_IMAGE_TOO_LARGE
            - 429 COMMUNITY_IMAGE_UPLOAD_RATE_LIMITED / COMMUNITY_IMAGE_DAILY_LIMIT_EXCEEDED
            - 503 COMMUNITY_IMAGE_STORAGE_UNAVAILABLE: 저장소 설정이 없거나 장애
            """
    )
    CommunityImageUploadResponse uploadImage(@AuthMember LoginMember loginMember,
                                             @RequestPart("image") MultipartFile image,
                                             @RequestPart("thumbnail") MultipartFile thumbnail);

    @ApiLogs({
        @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 525, description = "커뮤니티 이미지 조회(스트리밍) API 추가"),
    })
    @Operation(
        summary = "커뮤니티 이미지 조회 (서버 스트리밍, image/webp)",
        description = """
            ## 인증(JWT): **필요** (Authorization 헤더로 불러와야 함)

            ## 쿼리 파라미터
            - **`size`**: thumbnail / full(기본값)

            ## 설명
            - 응답 헤더 `Cache-Control: private, max-age=31536000, immutable`
            - 접근: 올린 본인(미첨부), 노출 중 글의 이미지(문제 글은 풀이 후), 글 작성자 본인. 숨김·삭제 글의 이미지는 404.

            ## 에러
            - 400 COMMUNITY_SOLVE_REQUIRED / 404 COMMUNITY_IMAGE_NOT_FOUND / 503 COMMUNITY_IMAGE_STORAGE_UNAVAILABLE
            """
    )
    ResponseEntity<byte[]> getImage(@AuthMember LoginMember loginMember, @PathVariable UUID imageUuid,
                                    @RequestParam(required = false) String size);
}
