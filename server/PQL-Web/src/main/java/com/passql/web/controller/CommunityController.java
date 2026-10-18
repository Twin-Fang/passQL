package com.passql.web.controller;

import com.passql.application.community.CommunityFeedService;
import com.passql.application.community.CommunityImageService;
import com.passql.application.community.CommunityPostReactionService;
import com.passql.application.community.CommunityPostService;
import com.passql.application.community.MemberBlockService;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.question.dto.community.CommunityFeedPageResponse;
import com.passql.question.dto.community.CommunityImageUploadResponse;
import com.passql.question.dto.community.CommunityPostCreateRequest;
import com.passql.question.dto.community.CommunityPostItemResponse;
import com.passql.question.dto.community.CommunityPostLikeResponse;
import com.passql.question.dto.community.CommunityPostPageResponse;
import com.passql.question.dto.community.CommunityReportRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import org.springframework.web.multipart.MultipartFile;

import java.time.Duration;
import java.util.UUID;

/** 커뮤니티 회원 API: 피드, 문제별 글 목록·작성·삭제, 좋아요, 신고, 작성자 차단 */
@RestController
@RequestMapping("/api/community")
@RequiredArgsConstructor
public class CommunityController implements CommunityControllerDocs {

    private final CommunityFeedService communityFeedService;
    private final CommunityPostService communityPostService;
    private final CommunityPostReactionService communityPostReactionService;
    private final MemberBlockService memberBlockService;
    private final CommunityImageService communityImageService;

    @GetMapping("/feed")
    public CommunityFeedPageResponse getFeed(@AuthMember LoginMember loginMember,
                                             @RequestParam(required = false) String source,
                                             @RequestParam(required = false) String cursor) {
        return communityFeedService.getFeed(loginMember.memberUuid(), source, cursor);
    }

    @GetMapping("/questions/{questionUuid}/posts")
    public CommunityPostPageResponse getQuestionPosts(@AuthMember LoginMember loginMember, @PathVariable UUID questionUuid,
                                                      @RequestParam(required = false) String sort,
                                                      @RequestParam(required = false) String cursor,
                                                      @RequestParam(required = false) Integer size) {
        return communityPostService.getQuestionPosts(loginMember.memberUuid(), questionUuid, sort, cursor, size);
    }

    @PostMapping("/questions/{questionUuid}/posts")
    @ResponseStatus(HttpStatus.CREATED)
    public CommunityPostItemResponse createQuestionPost(@AuthMember LoginMember loginMember, @PathVariable UUID questionUuid,
                                                        @RequestBody CommunityPostCreateRequest request) {
        return communityPostService.createQuestionPost(loginMember.memberUuid(), questionUuid, request);
    }

    @DeleteMapping("/posts/{postUuid}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deletePost(@AuthMember LoginMember loginMember, @PathVariable UUID postUuid) {
        communityPostService.deletePost(loginMember.memberUuid(), postUuid);
    }

    @PutMapping("/posts/{postUuid}/like")
    public CommunityPostLikeResponse toggleLike(@AuthMember LoginMember loginMember, @PathVariable UUID postUuid) {
        return communityPostReactionService.toggleLike(loginMember.memberUuid(), postUuid);
    }

    @PostMapping("/posts/{postUuid}/report")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void reportPost(@AuthMember LoginMember loginMember, @PathVariable UUID postUuid,
                           @RequestBody CommunityReportRequest request) {
        communityPostReactionService.reportPost(loginMember.memberUuid(), postUuid, request);
    }

    @PostMapping("/posts/{postUuid}/block-author")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void blockAuthor(@AuthMember LoginMember loginMember, @PathVariable UUID postUuid) {
        memberBlockService.blockAuthorOfPost(loginMember.memberUuid(), postUuid);
    }

    @PostMapping(value = "/images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public CommunityImageUploadResponse uploadImage(@AuthMember LoginMember loginMember,
                                                    @RequestPart("image") MultipartFile image,
                                                    @RequestPart("thumbnail") MultipartFile thumbnail) {
        return communityImageService.upload(loginMember.memberUuid(), image, thumbnail);
    }

    @GetMapping("/images/{imageUuid}")
    public ResponseEntity<byte[]> getImage(@AuthMember LoginMember loginMember, @PathVariable UUID imageUuid,
                                           @RequestParam(required = false) String size) {
        byte[] imageBytes = communityImageService.readImageBytes(loginMember.memberUuid(), imageUuid, size);
        // 이미지는 UUID 별로 불변 (숨김·삭제는 서버가 404 로 막음)
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("image/webp"))
                .cacheControl(CacheControl.maxAge(Duration.ofDays(365)).cachePrivate().immutable())
                .body(imageBytes);
    }
}
