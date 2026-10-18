package com.passql.application.community;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.constant.CommunityReportStatus;
import com.passql.question.constant.CommunityReportTargetType;
import com.passql.question.dto.community.AdminCommunityPostItem;
import com.passql.question.dto.community.AdminCommunityPostPage;
import com.passql.question.dto.community.AdminCommunityReportItem;
import com.passql.question.entity.CommunityPost;
import com.passql.question.entity.CommunityReport;
import com.passql.question.repository.CommunityPostRepository;
import com.passql.question.repository.CommunityReportRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 관리자 커뮤니티 신고 관리: 신고 글 목록, 숨김·복원·삭제·신고 기각 (처리마다 감사 로그)
 * 숨김·삭제는 대기 신고를 처리 완료로, 복원·기각은 대기 신고를 기각으로 닫음
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommunityAdminService {

    private final CommunityPostRepository communityPostRepository;
    private final CommunityReportRepository communityReportRepository;
    private final MemberRepository memberRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 신고 글 목록: 대기 신고순(많은 순) > 최신순, pendingOnly 면 검토 대기 글만 */
    public AdminCommunityPostPage getReportedPosts(boolean isPendingOnly, Pageable pageable) {
        Pageable sorted = PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(),
                Sort.by(Sort.Order.desc("reportCount"), Sort.Order.desc("createdAt")));
        Page<CommunityPost> page = isPendingOnly
                ? communityPostRepository.findWithPendingReports(sorted)
                : communityPostRepository.findReportedOrHidden(sorted);
        List<UUID> postUuids = page.getContent().stream().map(CommunityPost::getPostUuid).toList();
        Map<UUID, List<AdminCommunityReportItem>> reportsByPostUuid = communityReportRepository
                .findByTargetTypeAndTargetUuidInOrderByCreatedAtDesc(CommunityReportTargetType.POST, postUuids).stream()
                .collect(Collectors.groupingBy(CommunityReport::getTargetUuid,
                        Collectors.mapping(CommunityAdminService::toReportItem, Collectors.toList())));
        Map<UUID, String> nicknameByMemberUuid = memberRepository.findAllById(
                page.getContent().stream().map(CommunityPost::getAuthorMemberUuid).collect(Collectors.toSet())).stream()
                .collect(Collectors.toMap(Member::getMemberUuid, Member::getNickname));
        List<AdminCommunityPostItem> items = page.getContent().stream().map(post -> new AdminCommunityPostItem(
                post.getPostUuid(), post.getTargetUuid(),
                nicknameByMemberUuid.getOrDefault(post.getAuthorMemberUuid(), "탈퇴회원"),
                post.getContent(), post.getStatus(), post.getReportCount(), post.getLikeCount(), post.getCreatedAt(),
                reportsByPostUuid.getOrDefault(post.getPostUuid(), List.of()))).toList();
        return new AdminCommunityPostPage(items, page.getNumber(), page.getSize(), page.getTotalElements(),
                page.getTotalPages(), communityPostRepository.countWithPendingReports());
    }

    public long countPendingPosts() {
        return communityPostRepository.countWithPendingReports();
    }

    /** 숨김: 노출 중 글 > HIDDEN_ADMIN, 대기 신고 처리 완료 */
    @Transactional
    public void hidePost(UUID postUuid, String adminUsername) {
        CommunityPost post = findNotDeletedPost(postUuid);
        CommunityPostStatus before = post.getStatus();
        post.hide(CommunityPostStatus.HIDDEN_ADMIN, adminUsername);
        closeReports(post, CommunityReportStatus.RESOLVED);
        publishAudit(post, AdminAuditAction.HIDE, before);
    }

    /** 복원: 숨김 글 > VISIBLE, 대기 신고 기각 */
    @Transactional
    public void restorePost(UUID postUuid, String adminUsername) {
        CommunityPost post = findNotDeletedPost(postUuid);
        CommunityPostStatus before = post.getStatus();
        post.restore();
        closeReports(post, CommunityReportStatus.DISMISSED);
        publishAudit(post, AdminAuditAction.RESTORE, before);
        log.info("[community] admin restored : post={}, admin={}", postUuid, adminUsername);
    }

    /** 삭제: DELETED + 내용 비움 (삭제 전 내용은 감사 로그에 남김), 대기 신고 처리 완료 */
    @Transactional
    public void deletePost(UUID postUuid, String adminUsername) {
        CommunityPost post = findNotDeletedPost(postUuid);
        CommunityPostStatus before = post.getStatus();
        String contentBeforeDelete = post.getContent();
        post.markDeleted(adminUsername);
        closeReports(post, CommunityReportStatus.RESOLVED);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.COMMUNITY_POST, postUuid, AdminAuditAction.DELETE,
                AdminAuditEvent.summary("status", before, "content", contentBeforeDelete),
                AdminAuditEvent.summary("status", post.getStatus())));
    }

    /** 신고 기각: 대기 신고 기각, 자동 숨김 글이면 복원 (관리자 숨김은 유지) */
    @Transactional
    public void dismissReports(UUID postUuid, String adminUsername) {
        CommunityPost post = findNotDeletedPost(postUuid);
        CommunityPostStatus before = post.getStatus();
        if (before == CommunityPostStatus.HIDDEN_AUTO) {
            post.restore();
        }
        closeReports(post, CommunityReportStatus.DISMISSED);
        publishAudit(post, AdminAuditAction.DISMISS, before);
        log.info("[community] admin dismissed reports : post={}, admin={}", postUuid, adminUsername);
    }

    private CommunityPost findNotDeletedPost(UUID postUuid) {
        return communityPostRepository.findById(postUuid)
                .filter(post -> post.getStatus() != CommunityPostStatus.DELETED)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_POST_NOT_FOUND));
    }

    /** 대기 신고를 한 상태로 닫고 글의 신고 수 0 */
    private void closeReports(CommunityPost post, CommunityReportStatus toStatus) {
        communityReportRepository.closePendingPostReports(post.getPostUuid(), toStatus);
        post.updateReportCount(0);
    }

    private void publishAudit(CommunityPost post, AdminAuditAction action, CommunityPostStatus before) {
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.COMMUNITY_POST, post.getPostUuid(), action,
                AdminAuditEvent.summary("status", before),
                AdminAuditEvent.summary("status", post.getStatus(), "questionUuid", post.getTargetUuid())));
    }

    private static AdminCommunityReportItem toReportItem(CommunityReport report) {
        return new AdminCommunityReportItem(report.getCategory().name(), report.getCategory().getLabel(),
                report.getDetail(), report.getStatus(), report.getCreatedAt());
    }
}
