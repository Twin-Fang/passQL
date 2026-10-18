package com.passql.application.community;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.constant.CommunityReportCategory;
import com.passql.question.constant.CommunityReportStatus;
import com.passql.question.constant.CommunityReportTargetType;
import com.passql.question.constant.CommunityTargetType;
import com.passql.question.dto.community.CommunityPostLikeResponse;
import com.passql.question.dto.community.CommunityReportRequest;
import com.passql.question.entity.CommunityPost;
import com.passql.question.entity.CommunityPostLike;
import com.passql.question.entity.CommunityReport;
import com.passql.question.repository.CommunityPostLikeRepository;
import com.passql.question.repository.CommunityPostRepository;
import com.passql.question.repository.CommunityReportRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * 글 반응: 좋아요 토글, 신고 (서로 다른 회원 3명이면 자동 숨김)
 * 그 외 상태(삭제·이미 숨김 글)는 반응 대상이 아님 (404)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommunityPostReactionService {

    // 자동 숨김 기준: 검토 대기 신고 회원 수
    static final int AUTO_HIDE_REPORT_THRESHOLD = 3;

    private final CommunityPostRepository communityPostRepository;
    private final CommunityPostLikeRepository communityPostLikeRepository;
    private final CommunityReportRepository communityReportRepository;
    private final CommunitySolveService communitySolveService;

    /** 좋아요 토글: 있으면 취소 > 없으면 추가, 카운터는 DB 원자 갱신 */
    @Transactional
    public CommunityPostLikeResponse toggleLike(UUID memberUuid, UUID postUuid) {
        CommunityPost post = findVisiblePostForMember(memberUuid, postUuid);
        boolean isLiked;
        if (communityPostLikeRepository.deleteByPostUuidAndMemberUuid(postUuid, memberUuid) > 0) {
            communityPostRepository.decreaseLikeCount(postUuid);
            isLiked = false;
        } else {
            communityPostLikeRepository.save(CommunityPostLike.of(post.getPostUuid(), memberUuid));
            communityPostRepository.increaseLikeCount(postUuid);
            isLiked = true;
        }
        return new CommunityPostLikeResponse(isLiked, communityPostRepository.findLikeCount(postUuid));
    }

    /** 신고: 본인 글 금지 > 중복 신고 무시 > 저장 > 대기 신고 수 갱신 > 기준 이상이면 자동 숨김 */
    @Transactional
    public void reportPost(UUID reporterMemberUuid, UUID postUuid, CommunityReportRequest request) {
        CommunityPost post = findVisiblePostForMember(reporterMemberUuid, postUuid);
        if (post.isAuthoredBy(reporterMemberUuid)) {
            throw new CustomException(ErrorCode.COMMUNITY_SELF_REPORT_FORBIDDEN);
        }
        CommunityReportCategory category = CommunityReportCategory.fromRequestValue(request == null ? null : request.category());
        String detail = normalizeDetail(request == null ? null : request.detail());
        if (communityReportRepository.existsByTargetTypeAndTargetUuidAndReporterMemberUuid(
                CommunityReportTargetType.POST, postUuid, reporterMemberUuid)) {
            log.info("[community] duplicate report ignored : post={}", postUuid);
            return;
        }
        communityReportRepository.save(CommunityReport.ofPost(postUuid, reporterMemberUuid, category, detail));
        int pendingReportCount = (int) communityReportRepository.countByTargetTypeAndTargetUuidAndStatus(
                CommunityReportTargetType.POST, postUuid, CommunityReportStatus.PENDING);
        post.updateReportCount(pendingReportCount);
        log.info("[community] post reported : post={}, category={}, pendingReports={}", postUuid, category, pendingReportCount);
        if (pendingReportCount >= AUTO_HIDE_REPORT_THRESHOLD) {
            post.hide(CommunityPostStatus.HIDDEN_AUTO, CommunityPost.HANDLED_BY_AUTO_REPORT);
            log.warn("[community] post auto hidden : post={}, pendingReports={}", postUuid, pendingReportCount);
        }
    }

    /** 노출 중인 글 + (문제 글이면) 풀이 확인 */
    private CommunityPost findVisiblePostForMember(UUID memberUuid, UUID postUuid) {
        CommunityPost post = communityPostRepository.findById(postUuid)
                .filter(CommunityPost::isVisible)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_POST_NOT_FOUND));
        if (post.getTargetUuid() != null && post.getTargetType() == CommunityTargetType.QUESTION) {
            communitySolveService.requireSolved(memberUuid, post.getTargetUuid());
        }
        return post;
    }

    private static String normalizeDetail(String detail) {
        if (detail == null || detail.isBlank()) {
            return null;
        }
        String stripped = detail.strip();
        if (stripped.length() > CommunityReport.MAX_DETAIL_LENGTH) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "detail");
        }
        return stripped;
    }
}
