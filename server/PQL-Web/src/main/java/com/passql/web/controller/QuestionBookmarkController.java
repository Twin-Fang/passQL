package com.passql.web.controller;

import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.submission.dto.QuestionBookmarkPracticeSetResponse;
import com.passql.submission.dto.QuestionBookmarkStatusResponse;
import com.passql.submission.dto.QuestionBookmarksResponse;
import com.passql.submission.service.QuestionBookmarkService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

/** 문제 즐겨찾기 (#1082): 추가·해제는 문제 경로 아래, 목록·풀기 묶음은 /api/bookmarks. 등급 제한 없음 */
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class QuestionBookmarkController implements QuestionBookmarkControllerDocs {

    private final QuestionBookmarkService questionBookmarkService;

    @PutMapping("/questions/{questionUuid}/bookmark")
    public ResponseEntity<QuestionBookmarkStatusResponse> addBookmark(
        @AuthMember LoginMember loginMember,
        @PathVariable UUID questionUuid
    ) {
        return ResponseEntity.ok(questionBookmarkService.addBookmark(loginMember.memberUuid(), questionUuid));
    }

    @DeleteMapping("/questions/{questionUuid}/bookmark")
    public ResponseEntity<QuestionBookmarkStatusResponse> removeBookmark(
        @AuthMember LoginMember loginMember,
        @PathVariable UUID questionUuid
    ) {
        return ResponseEntity.ok(questionBookmarkService.removeBookmark(loginMember.memberUuid(), questionUuid));
    }

    @GetMapping("/bookmarks")
    public ResponseEntity<QuestionBookmarksResponse> getBookmarks(
        @AuthMember LoginMember loginMember,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = QuestionBookmarkService.DEFAULT_PAGE_SIZE) int size
    ) {
        return ResponseEntity.ok(questionBookmarkService.getBookmarks(loginMember.memberUuid(), page, size));
    }

    @GetMapping("/bookmarks/practice-set")
    public ResponseEntity<QuestionBookmarkPracticeSetResponse> getPracticeSet(
        @AuthMember LoginMember loginMember,
        @RequestParam(defaultValue = QuestionBookmarkService.DEFAULT_PRACTICE_SET_SIZE) int size
    ) {
        return ResponseEntity.ok(questionBookmarkService.getPracticeSet(loginMember.memberUuid(), size));
    }
}
