package com.passql.application.community;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.question.constant.CommunityPostSort;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.dto.community.CommunityImageResponse;
import com.passql.question.dto.community.CommunityPostCreateRequest;
import com.passql.question.dto.community.CommunityPostItemResponse;
import com.passql.question.dto.community.CommunityPostPageResponse;
import com.passql.question.entity.CommunityPost;
import com.passql.question.entity.Question;
import com.passql.question.repository.CommunityPostLikeRepository;
import com.passql.question.repository.CommunityPostRepository;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 문제별 의견 글: 목록(풀이 후만), 작성(풀이 후만, 이미지 최대 2장), 본인 삭제
 * 목록은 숨김·삭제 글과 내가 차단한 작성자 글을 제외, 작성자는 닉네임만 노출
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommunityPostService {

    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final int MAX_PAGE_SIZE = 50;

    private final CommunityPostRepository communityPostRepository;
    private final CommunityPostLikeRepository communityPostLikeRepository;
    private final QuestionRepository questionRepository;
    private final MemberRepository memberRepository;
    private final CommunitySolveService communitySolveService;
    private final CommunityContentPolicy communityContentPolicy;
    private final CommunityWriteLimiter communityWriteLimiter;
    private final CommunityImageService communityImageService;
    private final CommunityDiscussionChangePublisher communityDiscussionChangePublisher;

    /** 문제 의견 목록: 풀이 확인 > 정렬별 키셋 조회 > 닉네임·좋아요 여부 결합 */
    public CommunityPostPageResponse getQuestionPosts(UUID viewerMemberUuid, UUID questionUuid, String sortRequestValue,
                                                      String cursor, Integer size) {
        findQuestionOrThrow(questionUuid);
        communitySolveService.requireSolved(viewerMemberUuid, questionUuid);
        CommunityPostSort sort = CommunityPostSort.fromRequestValue(sortRequestValue);
        CommunityPostCursor position = CommunityPostCursor.decode(cursor);
        int pageSize = clampPageSize(size);

        // 다음 페이지 유무 확인용으로 1건 더 조회
        PageRequest fetchLimit = PageRequest.of(0, pageSize + 1);
        List<CommunityPost> fetched = sort == CommunityPostSort.LIKES
                ? communityPostRepository.findLikesPage(questionUuid, viewerMemberUuid, position.likeCount(),
                        position.createdAt(), position.postUuid(), fetchLimit)
                : communityPostRepository.findLatestPage(questionUuid, viewerMemberUuid, position.createdAt(),
                        position.postUuid(), fetchLimit);
        boolean hasNextPage = fetched.size() > pageSize;
        List<CommunityPost> pagePosts = hasNextPage ? fetched.subList(0, pageSize) : fetched;
        String nextCursor = hasNextPage ? CommunityPostCursor.encodeOf(pagePosts.get(pagePosts.size() - 1)) : null;
        return new CommunityPostPageResponse(toItems(pagePosts, viewerMemberUuid), nextCursor);
    }

    /** 글 작성: 풀이 확인 > 작성 제한 > 내용 검증 > 이미지 목록 검증 > 중복 확인 > (스냅샷) > 저장 > 이미지 첨부 */
    @Transactional
    public CommunityPostItemResponse createQuestionPost(UUID authorMemberUuid, UUID questionUuid,
                                                        CommunityPostCreateRequest request) {
        Question question = findQuestionOrThrow(questionUuid);
        communitySolveService.requireSolved(authorMemberUuid, questionUuid);
        communityWriteLimiter.acquireWritePermit(authorMemberUuid);
        String content = communityContentPolicy.validateAndNormalize(request == null ? null : request.content());
        List<UUID> imageUuids = communityImageService.normalizeImageUuids(request == null ? null : request.imageUuids());
        communityWriteLimiter.assertNotRecentDuplicate(authorMemberUuid, content);

        String solveSnapshot = request != null && Boolean.TRUE.equals(request.includeSolveSnapshot())
                ? communitySolveService.buildSnapshotJson(authorMemberUuid, question)
                : null;
        CommunityPost saved = communityPostRepository.save(
                CommunityPost.createQuestionOpinion(questionUuid, authorMemberUuid, content, solveSnapshot));
        communityImageService.attachToPost(saved.getPostUuid(), authorMemberUuid, imageUuids);
        communityWriteLimiter.recordWrittenContent(authorMemberUuid, content);
        communityDiscussionChangePublisher.publishChanged(saved);
        log.info("[community] post created : post={}, question={}, hasSnapshot={}",
                saved.getPostUuid(), questionUuid, solveSnapshot != null);
        return toItems(List.of(saved), authorMemberUuid).get(0);
    }

    /** 본인 글 삭제 (status=DELETED, 내용 비움) */
    @Transactional
    public void deletePost(UUID memberUuid, UUID postUuid) {
        CommunityPost post = communityPostRepository.findById(postUuid)
                .filter(found -> found.getStatus() != CommunityPostStatus.DELETED)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_POST_NOT_FOUND));
        if (!post.isAuthoredBy(memberUuid)) {
            log.warn("[community] rejected 403 : delete by non-author, post={}", postUuid);
            throw new CustomException(ErrorCode.COMMUNITY_POST_FORBIDDEN);
        }
        post.markDeleted(null);
        communityImageService.deleteImagesOfPost(postUuid);
        communityDiscussionChangePublisher.publishChanged(post);
        log.info("[community] post deleted by author : post={}", postUuid);
    }

    private Question findQuestionOrThrow(UUID questionUuid) {
        return questionRepository.findById(questionUuid)
                .filter(Question::getIsActive)
                .orElseThrow(() -> new CustomException(ErrorCode.QUESTION_NOT_FOUND));
    }

    /** 글 > 응답 항목 (닉네임·좋아요 여부는 한 번에 조회) */
    private List<CommunityPostItemResponse> toItems(List<CommunityPost> posts, UUID viewerMemberUuid) {
        Set<UUID> authorUuids = posts.stream().map(CommunityPost::getAuthorMemberUuid).collect(Collectors.toSet());
        Map<UUID, String> nicknameByMemberUuid = memberRepository.findAllById(authorUuids).stream()
                .collect(Collectors.toMap(Member::getMemberUuid, Member::getNickname));
        Set<UUID> likedPostUuids = posts.isEmpty() ? Set.of() : new HashSet<>(communityPostLikeRepository.findLikedPostUuids(
                viewerMemberUuid, posts.stream().map(CommunityPost::getPostUuid).toList()));
        Map<UUID, List<CommunityImageResponse>> imagesByPostUuid = communityImageService.getImageResponsesByPost(
                posts.stream().map(CommunityPost::getPostUuid).toList());
        return posts.stream().map(post -> new CommunityPostItemResponse(
                post.getPostUuid(),
                nicknameByMemberUuid.getOrDefault(post.getAuthorMemberUuid(), "탈퇴회원"),
                post.getContent(),
                post.isAuthoredBy(viewerMemberUuid),
                post.getLikeCount(),
                likedPostUuids.contains(post.getPostUuid()),
                communitySolveService.parseSnapshot(post.getSolveSnapshot()),
                post.getCreatedAt(),
                imagesByPostUuid.getOrDefault(post.getPostUuid(), List.of()))).toList();
    }

    private static int clampPageSize(Integer size) {
        if (size == null || size < 1) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(size, MAX_PAGE_SIZE);
    }
}
