package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.submission.dto.QuestionBookmarkPracticeSetResponse;
import com.passql.submission.dto.QuestionBookmarkStatusResponse;
import com.passql.submission.dto.QuestionBookmarksResponse;
import com.passql.submission.service.QuestionBookmarkService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.UUID;

@Tag(name = "Bookmark", description = "문제 즐겨찾기")
public interface QuestionBookmarkControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.11.16", author = Author.SUHSAECHAN, issueNumber = 1082, description = "문제 즐겨찾기 추가 API"),
    })
    @Operation(summary = "문제 즐겨찾기 추가", description = """
        ## 인증(JWT): **필요** | 등급 제한 없음
        - 이미 즐겨찾기면 그대로 성공 (같은 요청 반복 안전)
        - 없거나 비활성 문제 > 404 QUESTION_NOT_FOUND
        - 반환 QuestionBookmarkStatusResponse { questionUuid, isBookmarked=true }
        """)
    ResponseEntity<QuestionBookmarkStatusResponse> addBookmark(
        @AuthMember LoginMember loginMember,
        @PathVariable UUID questionUuid
    );

    @ApiLogs({
        @ApiLog(date = "2026.11.16", author = Author.SUHSAECHAN, issueNumber = 1082, description = "문제 즐겨찾기 해제 API"),
    })
    @Operation(summary = "문제 즐겨찾기 해제", description = """
        ## 인증(JWT): **필요** | 등급 제한 없음
        - 즐겨찾기가 없어도 성공 (같은 요청 반복 안전)
        - 반환 QuestionBookmarkStatusResponse { questionUuid, isBookmarked=false }
        """)
    ResponseEntity<QuestionBookmarkStatusResponse> removeBookmark(
        @AuthMember LoginMember loginMember,
        @PathVariable UUID questionUuid
    );

    @ApiLogs({
        @ApiLog(date = "2026.11.16", author = Author.SUHSAECHAN, issueNumber = 1082, description = "즐겨찾기 목록 API"),
    })
    @Operation(summary = "즐겨찾기 목록", description = """
        ## 인증(JWT): **필요** | 등급 제한 없음
        ## 요청 파라미터
        - page (기본 0), size (기본 20, 1~50 보정)
        ## 반환값 (QuestionBookmarksResponse)
        - items[]: questionUuid, stemPreview(50자), topicName, subject(SUBJECT_ONE | SUBJECT_TWO), bookmarkedAt
        - totalCount, page, hasNext
        - 활성 문제만, 최근 추가 순
        """)
    ResponseEntity<QuestionBookmarksResponse> getBookmarks(
        @AuthMember LoginMember loginMember,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = QuestionBookmarkService.DEFAULT_PAGE_SIZE) int size
    );

    @ApiLogs({
        @ApiLog(date = "2026.11.16", author = Author.SUHSAECHAN, issueNumber = 1082, description = "즐겨찾기 풀기 묶음 API (무작위 10개)"),
    })
    @Operation(summary = "즐겨찾기 풀기 묶음", description = """
        ## 인증(JWT): **필요** | 등급 제한 없음 (풀이는 문제 상세의 기존 크레딧 규칙)
        - size (기본 10, 1~10 보정)
        - 반환 QuestionBookmarkPracticeSetResponse { questionUuids }: 활성 즐겨찾기 문제 무작위, 없으면 빈 목록
        """)
    ResponseEntity<QuestionBookmarkPracticeSetResponse> getPracticeSet(
        @AuthMember LoginMember loginMember,
        @RequestParam(defaultValue = QuestionBookmarkService.DEFAULT_PRACTICE_SET_SIZE) int size
    );
}
