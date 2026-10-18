package com.passql.meta.service;

import com.passql.common.audit.AdminAuditEvent;
import com.passql.common.audit.constant.AdminAuditAction;
import com.passql.common.audit.constant.AdminAuditTargetType;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.dto.AppNoticePageResponse;
import com.passql.meta.dto.AppNoticeResponse;
import com.passql.meta.dto.AppNoticeSaveRequest;
import com.passql.meta.dto.VisibleNoticeSummary;
import com.passql.meta.entity.AppNotice;
import com.passql.meta.repository.AppNoticeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 앱 공지: 노출 공지·게시 공지 목록·상세 조회(앱·웹), 목록·등록·수정·활성 전환(관리자)
 * 사용자에게 보이는 공지 = 활성 + 노출 시작 지남 (노출 끝난 공지도 지난 공지로 목록·상세에 남음)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AppNoticeService {

    // 노출 기간은 관리자가 한국 시각으로 입력 > 서버 시간대와 무관하게 KST 기준 비교
    private static final ZoneId KST = ZoneId.of("Asia/Seoul");
    // 제목 최대 길이 (문자 수, app_notice.title 컬럼과 같음)
    private static final int TITLE_MAX_LENGTH = 100;
    // 본문 최대 길이 (문자 수)
    private static final int BODY_MAX_LENGTH = 2000;
    // 공지 목록 페이지 크기 기본값·상한 (건)
    public static final int DEFAULT_PAGE_SIZE = 20;
    public static final int MAX_PAGE_SIZE = 50;

    private final AppNoticeRepository appNoticeRepository;
    private final ApplicationEventPublisher eventPublisher;

    /** 지금 노출할 공지 (중요 먼저 > 최근 등록 순) */
    public List<AppNoticeResponse> getVisibleNotices() {
        return appNoticeRepository.findVisibleNotices(LocalDateTime.now(KST)).stream()
                .map(AppNoticeResponse::from)
                .toList();
    }

    /** 지금 노출할 공지 요약 (알림함 공지 탭, 중요 먼저 > 최근 등록 순) */
    public List<VisibleNoticeSummary> getVisibleNoticeSummaries() {
        return appNoticeRepository.findVisibleNotices(LocalDateTime.now(KST)).stream()
                .map(VisibleNoticeSummary::from)
                .toList();
    }

    /** 게시 공지 목록 한 페이지 (지난 공지 포함, 노출 중 중요 먼저 > 게시 최신 순) */
    public AppNoticePageResponse getPublishedNotices(Integer page, Integer size) {
        int pageIndex = page == null || page < 0 ? 0 : page;
        Page<AppNotice> noticePage = appNoticeRepository.findPublishedNotices(
                LocalDateTime.now(KST), PageRequest.of(pageIndex, clampPageSize(size)));
        return new AppNoticePageResponse(
                noticePage.getContent().stream().map(AppNoticeResponse::from).toList(),
                pageIndex,
                noticePage.hasNext());
    }

    /** 게시 공지 1건 (비활성·노출 전·없음 > APP_NOTICE_NOT_FOUND) */
    public AppNoticeResponse getPublishedNotice(UUID noticeUuid) {
        return appNoticeRepository.findPublishedNotice(noticeUuid, LocalDateTime.now(KST))
                .map(AppNoticeResponse::from)
                .orElseThrow(() -> new CustomException(ErrorCode.APP_NOTICE_NOT_FOUND));
    }

    /** 관리자 목록 (최근 등록 순, 비활성 포함) */
    public List<AppNoticeResponse> getAllNotices() {
        return appNoticeRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(AppNoticeResponse::from)
                .toList();
    }

    /** 등록: 검증 > 저장 */
    @Transactional
    public AppNoticeResponse createNotice(AppNoticeSaveRequest request) {
        validate(request);
        AppNotice notice = AppNotice.builder()
                .title(request.title().trim())
                .body(request.body().trim())
                .startsAt(request.startsAt())
                .endsAt(request.endsAt())
                .isActive(!Boolean.FALSE.equals(request.isActive()))
                .isImportant(Boolean.TRUE.equals(request.isImportant()))
                .build();
        AppNotice saved = appNoticeRepository.save(notice);
        log.info("[app notice] created : uuid={}", saved.getAppNoticeUuid());
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTICE, saved.getAppNoticeUuid(),
                AdminAuditAction.CREATE, null, toAuditSummary(saved)));
        return AppNoticeResponse.from(saved);
    }

    /** 수정: 검증 > 전체 필드 교체 */
    @Transactional
    public AppNoticeResponse updateNotice(UUID noticeUuid, AppNoticeSaveRequest request) {
        validate(request);
        AppNotice notice = findNotice(noticeUuid);
        Map<String, Object> before = toAuditSummary(notice);
        notice.setTitle(request.title().trim());
        notice.setBody(request.body().trim());
        notice.setStartsAt(request.startsAt());
        notice.setEndsAt(request.endsAt());
        notice.setIsActive(!Boolean.FALSE.equals(request.isActive()));
        notice.setIsImportant(Boolean.TRUE.equals(request.isImportant()));
        log.info("[app notice] updated : uuid={}", noticeUuid);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTICE, noticeUuid,
                AdminAuditAction.UPDATE, before, toAuditSummary(notice)));
        return AppNoticeResponse.from(notice);
    }

    /** 활성·비활성 전환 (삭제 대신 비활성으로 이력 보존) */
    @Transactional
    public void changeNoticeActive(UUID noticeUuid, boolean isActive) {
        AppNotice notice = findNotice(noticeUuid);
        notice.setIsActive(isActive);
        log.info("[app notice] active changed : uuid={}, isActive={}", noticeUuid, isActive);
        eventPublisher.publishEvent(AdminAuditEvent.of(AdminAuditTargetType.NOTICE, noticeUuid,
                isActive ? AdminAuditAction.ACTIVATE : AdminAuditAction.DEACTIVATE));
    }

    /** 감사 로그용 공지 요약 (제목, 본문 앞부분, 기간, 활성, 중요) */
    private static Map<String, Object> toAuditSummary(AppNotice notice) {
        return AdminAuditEvent.summary("title", notice.getTitle(), "body", notice.getBody(),
                "startsAt", notice.getStartsAt(), "endsAt", notice.getEndsAt(),
                "isActive", notice.getIsActive(), "isImportant", notice.getIsImportant());
    }

    private static int clampPageSize(Integer size) {
        if (size == null || size < 1) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(size, MAX_PAGE_SIZE);
    }

    private AppNotice findNotice(UUID noticeUuid) {
        return appNoticeRepository.findById(noticeUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.APP_NOTICE_NOT_FOUND));
    }

    /** 요청 검증 (제목·본문 필수와 길이, 기간 순서) */
    private void validate(AppNoticeSaveRequest request) {
        if (!StringUtils.hasText(request.title()) || !StringUtils.hasText(request.body())
                || request.title().trim().length() > TITLE_MAX_LENGTH
                || request.body().trim().length() > BODY_MAX_LENGTH) {
            throw new CustomException(ErrorCode.APP_NOTICE_INPUT_INVALID);
        }
        if (request.startsAt() != null && request.endsAt() != null && !request.endsAt().isAfter(request.startsAt())) {
            throw new CustomException(ErrorCode.APP_NOTICE_PERIOD_INVALID);
        }
    }
}
