package com.passql.application.community;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.member.repository.MemberSpecification;
import com.passql.question.constant.CommunityBoardType;
import com.passql.question.constant.CommunityModerationAction;
import com.passql.question.constant.CommunityAdminPostSort;
import com.passql.question.constant.CommunityPostStatus;
import com.passql.question.constant.CommunityReportCategory;
import com.passql.question.constant.CommunityReportStatus;
import com.passql.question.constant.CommunityReportTargetType;
import com.passql.question.dto.community.AdminCommunityPostItem;
import com.passql.question.dto.community.AdminCommunityReportStats;
import com.passql.question.dto.community.AdminMemberCommunityActivity;
import com.passql.question.dto.community.AdminMemberFiledReportItem;
import com.passql.question.dto.community.CommunityBulkResultResponse;
import com.passql.question.dto.community.AdminCommunityPostListItem;
import com.passql.question.dto.community.AdminCommunityPostListPage;
import com.passql.question.dto.community.AdminCommunityPostPage;
import com.passql.question.dto.community.AdminCommunityReportItem;
import com.passql.question.entity.CommunityPost;
import com.passql.question.entity.CommunityReport;
import com.passql.question.repository.CommunityPostRepository;
import com.passql.question.repository.CommunityPostSpecification;
import com.passql.question.repository.CommunityReportRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 관리자 커뮤니티 관리: 신고 글·전체 게시글 목록, 숨김·복원·삭제·신고 기각(건별·일괄), 처리 통계, 회원 활동 조회 (처리마다 감사 로그)
 * 숨김·삭제는 대기 신고를 처리 완료로, 복원·기각은 대기 신고를 기각으로 닫고 처리자·사유 메모·시각을 신고에 기록
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommunityAdminService {

    // member 행이 없는 작성자 표기 (탈퇴 정리)
    public static final String WITHDRAWN_AUTHOR_NICKNAME = "탈퇴회원";
    // 작성자 닉네임 검색으로 찾는 회원 수 상한
    private static final int AUTHOR_NICKNAME_SEARCH_LIMIT = 200;
    private static final double MINUTES_PER_HOUR = 60.0;
    // 처리 통계 집계 기간 (일)
    private static final int REPORT_STATS_DAYS = 30;
    // 회원 상세에 보여 주는 최근 글·신고 수
    private static final int MEMBER_ACTIVITY_LIMIT = 30;

    private final CommunityPostRepository communityPostRepository;
    private final CommunityReportRepository communityReportRepository;
    private final MemberRepository memberRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final CommunityImageService communityImageService;
    private final CommunityDiscussionChangePublisher communityDiscussionChangePublisher;

    /** 신고 글 목록: 대기만 여부·신고 사유 필터 > 선택 정렬(기본 신고 많은 순) > 글별 신고 이력 부착 */
    public AdminCommunityPostPage getReportedPosts(boolean isPendingOnly, CommunityReportCategory category,
                                                   CommunityAdminPostSort sort, Pageable pageable) {
        Specification<CommunityPost> condition = Specification.allOf(
                CommunityPostSpecification.reportedPosts(isPendingOnly),
                CommunityPostSpecification.hasReportOfCategory(category, isPendingOnly));
        CommunityAdminPostSort appliedSort = sort == null ? CommunityAdminPostSort.MOST_REPORTED : sort;
        Pageable sorted = PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), appliedSort.toSort());
        Page<CommunityPost> page = communityPostRepository.findAll(condition, sorted);
        List<UUID> postUuids = page.getContent().stream().map(CommunityPost::getPostUuid).toList();
        Map<UUID, List<AdminCommunityReportItem>> reportsByPostUuid = communityReportRepository
                .findByTargetTypeAndTargetUuidInOrderByCreatedAtDesc(CommunityReportTargetType.POST, postUuids).stream()
                .collect(Collectors.groupingBy(CommunityReport::getTargetUuid,
                        Collectors.mapping(CommunityAdminService::toReportItem, Collectors.toList())));
        Map<UUID, String> nicknameByMemberUuid = findAuthorNicknames(page.getContent());
        List<AdminCommunityPostItem> items = page.getContent().stream().map(post -> new AdminCommunityPostItem(
                post.getPostUuid(), post.getTargetUuid(), post.getAuthorMemberUuid(),
                nicknameByMemberUuid.getOrDefault(post.getAuthorMemberUuid(), WITHDRAWN_AUTHOR_NICKNAME),
                post.getContent(), post.getStatus(), post.getReportCount(), post.getLikeCount(), post.getCreatedAt(),
                reportsByPostUuid.getOrDefault(post.getPostUuid(), List.of()))).toList();
        return new AdminCommunityPostPage(items, page.getNumber(), page.getSize(), page.getTotalElements(),
                page.getTotalPages(), communityPostRepository.countWithPendingReports());
    }

    /**
     * 토론 게시글 목록: 게시판·상태(미지정이면 삭제 제외)·본문 키워드·작성자(UUID 또는 닉네임)·작성 기간·신고 수 하한 필터 > 선택 정렬(기본 최신순)
     */
    public AdminCommunityPostListPage getPosts(CommunityBoardType boardType, CommunityPostStatus status, String keyword,
                                               String authorKeyword, LocalDate fromDate, LocalDate toDate,
                                               Integer minimumReportCount, CommunityAdminPostSort sort, Pageable pageable) {
        Specification<CommunityPost> condition = Specification.allOf(
                CommunityPostSpecification.boardTypeEquals(boardType),
                CommunityPostSpecification.statusEqualsOrNotDeleted(status),
                CommunityPostSpecification.contentContains(keyword),
                CommunityPostSpecification.authorIn(findAuthorMemberUuids(authorKeyword)),
                CommunityPostSpecification.createdFrom(fromDate),
                CommunityPostSpecification.createdTo(toDate),
                CommunityPostSpecification.reportCountAtLeast(minimumReportCount));
        CommunityAdminPostSort appliedSort = sort == null ? CommunityAdminPostSort.NEWEST : sort;
        Pageable sorted = PageRequest.of(pageable.getPageNumber(), pageable.getPageSize(), appliedSort.toSort());
        Page<CommunityPost> page = communityPostRepository.findAll(condition, sorted);
        Map<UUID, String> nicknameByMemberUuid = findAuthorNicknames(page.getContent());
        List<AdminCommunityPostListItem> items = page.getContent().stream()
                .map(post -> toPostListItem(post, nicknameByMemberUuid))
                .toList();
        return new AdminCommunityPostListPage(items, page.getNumber(), page.getSize(), page.getTotalElements(),
                page.getTotalPages());
    }

    public long countPendingPosts() {
        return communityPostRepository.countWithPendingReports();
    }

    /** 숨김: 노출 중 글 > HIDDEN_ADMIN, 대기 신고 처리 완료 */
    @Transactional
    public void hidePost(UUID postUuid, String adminUsername, String handledNote) {
        CommunityPost post = findNotDeletedPost(postUuid);
        CommunityPostStatus before = post.getStatus();
        post.hide(CommunityPostStatus.HIDDEN_ADMIN, adminUsername);
        communityDiscussionChangePublisher.publishChanged(post);
        closeReports(post, CommunityReportStatus.RESOLVED, adminUsername, handledNote);
        publishAudit(post, AdminAuditAction.HIDE, before, handledNote);
    }

    /** 복원: 숨김 글 > VISIBLE, 대기 신고 기각 */
    @Transactional
    public void restorePost(UUID postUuid, String adminUsername, String handledNote) {
        CommunityPost post = findNotDeletedPost(postUuid);
        CommunityPostStatus before = post.getStatus();
        post.restore();
        communityDiscussionChangePublisher.publishChanged(post);
        closeReports(post, CommunityReportStatus.DISMISSED, adminUsername, handledNote);
        publishAudit(post, AdminAuditAction.RESTORE, before, handledNote);
        log.info("[community] admin restored : post={}, admin={}", postUuid, adminUsername);
    }

    /** 삭제: DELETED + 내용 비움 (삭제 전 내용은 감사 로그에 남김), 대기 신고 처리 완료 */
    @Transactional
    public void deletePost(UUID postUuid, String adminUsername, String handledNote) {
        CommunityPost post = findNotDeletedPost(postUuid);
        CommunityPostStatus before = post.getStatus();
        String contentBeforeDelete = post.getContent();
        post.markDeleted(adminUsername);
        communityDiscussionChangePublisher.publishChanged(post);
        communityImageService.deleteImagesOfPost(postUuid);
        closeReports(post, CommunityReportStatus.RESOLVED, adminUsername, handledNote);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.COMMUNITY_POST, postUuid, AdminAuditAction.DELETE,
                AdminAuditEvent.summary("status", before, "content", contentBeforeDelete),
                AdminAuditEvent.summary("status", post.getStatus(), "handledNote", handledNote)));
    }

    /** 신고 기각: 대기 신고 기각, 자동 숨김 글이면 복원 (관리자 숨김은 유지) */
    @Transactional
    public void dismissReports(UUID postUuid, String adminUsername, String handledNote) {
        CommunityPost post = findNotDeletedPost(postUuid);
        CommunityPostStatus before = post.getStatus();
        if (before == CommunityPostStatus.HIDDEN_AUTO) {
            post.restore();
            communityDiscussionChangePublisher.publishChanged(post);
        }
        closeReports(post, CommunityReportStatus.DISMISSED, adminUsername, handledNote);
        publishAudit(post, AdminAuditAction.DISMISS, before, handledNote);
        log.info("[community] admin dismissed reports : post={}, admin={}", postUuid, adminUsername);
    }

    /**
     * 신고 1건 기각: 검토 대기 신고만 > 기각 기록 > 글의 대기 신고 수 1 차감 (글 상태는 그대로)
     */
    @Transactional
    public void dismissReport(UUID reportUuid, String adminUsername, String handledNote) {
        CommunityReport report = communityReportRepository.findById(reportUuid)
                .filter(found -> found.getTargetType() == CommunityReportTargetType.POST)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));
        if (report.getStatus() != CommunityReportStatus.PENDING) {
            throw new CustomException(ErrorCode.INVALID_REQUEST);
        }
        report.close(CommunityReportStatus.DISMISSED, adminUsername, normalizeHandledNote(handledNote));
        CommunityPost post = communityPostRepository.findById(report.getTargetUuid())
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_POST_NOT_FOUND));
        post.updateReportCount(Math.max(0, post.getReportCount() - 1));
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.COMMUNITY_POST, post.getPostUuid(),
                AdminAuditAction.DISMISS, null,
                AdminAuditEvent.summary("reportUuid", reportUuid, "category", report.getCategory(),
                        "handledNote", report.getHandledNote())));
    }

    /**
     * 글 일괄 처리: 동작(숨김·복원·삭제·기각) > 글별 실행 > 없거나 이미 삭제된 글은 건너뜀 (한 트랜잭션, 최대 100건)
     */
    @Transactional
    public CommunityBulkResultResponse moderatePosts(CommunityModerationAction action, List<UUID> postUuids,
                                                     String adminUsername, String handledNote) {
        int succeededCount = 0;
        int skippedCount = 0;
        for (UUID postUuid : postUuids) {
            try {
                moderateOnePost(action, postUuid, adminUsername, handledNote);
                succeededCount++;
            } catch (CustomException skippedPost) {
                // 글 없음·이미 삭제 (조회 단계에서만 던져 이 트랜잭션은 롤백 대상 아님)
                skippedCount++;
            }
        }
        return new CommunityBulkResultResponse(succeededCount, skippedCount);
    }

    private void moderateOnePost(CommunityModerationAction action, UUID postUuid, String adminUsername, String handledNote) {
        switch (action) {
            case HIDE -> hidePost(postUuid, adminUsername, handledNote);
            case RESTORE -> restorePost(postUuid, adminUsername, handledNote);
            case DELETE -> deletePost(postUuid, adminUsername, handledNote);
            case DISMISS -> dismissReports(postUuid, adminUsername, handledNote);
        }
    }

    /** 신고 처리 통계: 대기 신고 수, 최근 30일 처리 완료·기각 건수, 평균 처리 시간 (처리 기록 도입 이후 처리분만) */
    public AdminCommunityReportStats getReportStats() {
        LocalDateTime since = LocalDateTime.now().minusDays(REPORT_STATS_DAYS);
        Map<CommunityReportStatus, Long> handledCountByStatus = communityReportRepository.countHandledSinceGroupByStatus(since)
                .stream().collect(Collectors.toMap(row -> (CommunityReportStatus) row[0], row -> (Long) row[1]));
        List<Object[]> createdAndHandledTimes = communityReportRepository.findCreatedAndHandledTimesSince(since);
        Double averageHandlingHours = createdAndHandledTimes.isEmpty() ? null
                : createdAndHandledTimes.stream()
                        .mapToLong(row -> Duration.between((LocalDateTime) row[0], (LocalDateTime) row[1]).toMinutes())
                        .average().orElse(0) / MINUTES_PER_HOUR;
        return new AdminCommunityReportStats(communityReportRepository.countByStatus(CommunityReportStatus.PENDING),
                handledCountByStatus.getOrDefault(CommunityReportStatus.RESOLVED, 0L),
                handledCountByStatus.getOrDefault(CommunityReportStatus.DISMISSED, 0L),
                REPORT_STATS_DAYS, averageHandlingHours);
    }

    /** 관리자 회원 상세: 작성 글(최근 30건)과 이 회원이 한 신고(최근 30건) */
    public AdminMemberCommunityActivity getMemberActivity(UUID memberUuid, String memberNickname) {
        Pageable recent = PageRequest.of(0, MEMBER_ACTIVITY_LIMIT);
        Map<UUID, String> nicknameByMemberUuid = Map.of(memberUuid, memberNickname);
        List<AdminCommunityPostListItem> posts = communityPostRepository
                .findByAuthorMemberUuidOrderByCreatedAtDesc(memberUuid, recent).stream()
                .map(post -> toPostListItem(post, nicknameByMemberUuid)).toList();
        List<AdminMemberFiledReportItem> filedReports = communityReportRepository
                .findByReporterMemberUuidOrderByCreatedAtDesc(memberUuid, recent).stream()
                .map(report -> new AdminMemberFiledReportItem(report.getReportUuid(), report.getTargetUuid(),
                        report.getCategory().getLabel(), report.getDetail(), report.getStatus(), report.getCreatedAt()))
                .toList();
        return new AdminMemberCommunityActivity(posts, communityPostRepository.countByAuthorMemberUuid(memberUuid), filedReports);
    }

    private CommunityPost findNotDeletedPost(UUID postUuid) {
        return communityPostRepository.findById(postUuid)
                .filter(post -> post.getStatus() != CommunityPostStatus.DELETED)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMUNITY_POST_NOT_FOUND));
    }

    /** 대기 신고를 한 상태로 닫고(처리자·사유 메모·시각 기록) 글의 신고 수 0 */
    private void closeReports(CommunityPost post, CommunityReportStatus toStatus, String adminUsername, String handledNote) {
        communityReportRepository.closePendingPostReports(post.getPostUuid(), toStatus, adminUsername,
                normalizeHandledNote(handledNote), LocalDateTime.now());
        post.updateReportCount(0);
    }

    /** 처리 사유 메모: 앞뒤 공백 제거, 비면 null */
    private static String normalizeHandledNote(String handledNote) {
        return handledNote == null || handledNote.isBlank() ? null : handledNote.trim();
    }

    private void publishAudit(CommunityPost post, AdminAuditAction action, CommunityPostStatus before, String handledNote) {
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.COMMUNITY_POST, post.getPostUuid(), action,
                AdminAuditEvent.summary("status", before),
                AdminAuditEvent.summary("status", post.getStatus(), "questionUuid", post.getTargetUuid(),
                        "handledNote", normalizeHandledNote(handledNote))));
    }

    /** 작성자 검색어 > 후보 회원 UUID (비면 null=조건 없음, UUID 형식이면 그 회원, 아니면 닉네임 부분 일치 최대 200명) */
    private Set<UUID> findAuthorMemberUuids(String authorKeyword) {
        if (authorKeyword == null || authorKeyword.isBlank()) {
            return null;
        }
        try {
            return Set.of(UUID.fromString(authorKeyword.trim()));
        } catch (IllegalArgumentException notUuidFormat) {
            return memberRepository.findAll(MemberSpecification.nicknameContains(authorKeyword.trim()),
                            PageRequest.of(0, AUTHOR_NICKNAME_SEARCH_LIMIT)).stream()
                    .map(Member::getMemberUuid).collect(Collectors.toSet());
        }
    }

    /** 글 작성자 > 닉네임 (탈퇴 정리로 member 행 없는 작성자는 빠짐) */
    private Map<UUID, String> findAuthorNicknames(List<CommunityPost> posts) {
        return memberRepository.findAllById(posts.stream().map(CommunityPost::getAuthorMemberUuid).collect(Collectors.toSet()))
                .stream()
                .collect(Collectors.toMap(Member::getMemberUuid, Member::getNickname));
    }

    private static AdminCommunityPostListItem toPostListItem(CommunityPost post, Map<UUID, String> nicknameByMemberUuid) {
        return new AdminCommunityPostListItem(post.getPostUuid(), post.getBoardType(), post.getTargetType(),
                post.getTargetUuid(), post.getAuthorMemberUuid(),
                nicknameByMemberUuid.getOrDefault(post.getAuthorMemberUuid(), WITHDRAWN_AUTHOR_NICKNAME),
                post.getContent(), post.getStatus(), post.getLikeCount(), post.getCommentCount(), post.getReportCount(),
                post.getCreatedAt());
    }

    private static AdminCommunityReportItem toReportItem(CommunityReport report) {
        return new AdminCommunityReportItem(report.getReportUuid(), report.getCategory().name(),
                report.getCategory().getLabel(), report.getDetail(), report.getStatus(), report.getCreatedAt(),
                report.getHandledBy(), report.getHandledNote(), report.getHandledAt());
    }
}
