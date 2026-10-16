package com.passql.application.notification;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.dto.VisibleNoticeSummary;
import com.passql.meta.service.AppNoticeService;
import com.passql.member.constant.NotificationCategory;
import com.passql.member.dto.NotificationItemResponse;
import com.passql.member.dto.NotificationPageResponse;
import com.passql.member.dto.UnreadNotificationCountResponse;
import com.passql.member.entity.MemberNotification;
import com.passql.member.repository.MemberNoticeReadRepository;
import com.passql.member.repository.MemberNotificationRepository;
import com.passql.member.repository.UuidCountProjection;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 알림함 조회·읽음: 목록(커서), 안 읽은 개수(30초 캐시), 읽음, 모두 읽음, 푸시 배지 개수
 * 알림 탭은 member_notification, 공지 탭은 노출 중 공지 + member_notice_read (공지는 수 건이라 메모리에서 합침)
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberNotificationQueryService {

    public static final int DEFAULT_PAGE_SIZE = 20;
    public static final int MAX_PAGE_SIZE = 50;
    // 공지 탭 한 번에 내려주는 최대 건수 (노출 중 공지는 수 건)
    private static final int MAX_NOTICE_ITEMS = 50;
    // 커서 문자열: {createdAt ISO}|{uuid} 를 URL-safe Base64 로 감싼 값
    private static final String CURSOR_DELIMITER = "|";
    private static final String NOTICE_TYPE_NAME = NotificationCategory.NOTICE.name();

    private final MemberNotificationRepository memberNotificationRepository;
    private final MemberNoticeReadRepository memberNoticeReadRepository;
    private final AppNoticeService appNoticeService;
    private final UnreadNotificationCountCache unreadNotificationCountCache;

    /** 탭별 목록: 알림 > 커서 페이지(size+1 조회로 다음 페이지 유무 판정), 공지 > 노출 중 공지 전체 */
    public NotificationPageResponse getNotifications(UUID memberUuid, String categoryRequestValue, String cursor, Integer size) {
        NotificationCategory category = parseCategoryOrDefault(categoryRequestValue);
        if (category == NotificationCategory.NOTICE) {
            return new NotificationPageResponse(getNoticeItems(memberUuid), null);
        }
        return getGeneralPage(memberUuid, cursor, clampPageSize(size));
    }

    /** 안 읽은 개수: 캐시 > 알림 탭(부분 인덱스 COUNT) + 공지 탭(노출 중 공지 - 읽은 공지) */
    public UnreadNotificationCountResponse getUnreadCount(UUID memberUuid) {
        return unreadNotificationCountCache.getOrLoad(memberUuid, () -> {
            long generalCount = memberNotificationRepository.countByMemberUuidAndReadAtIsNullAndIsHiddenFalse(memberUuid);
            return UnreadNotificationCountResponse.of(generalCount, countUnreadNotices(memberUuid));
        });
    }

    /** 1건 읽음: 알림 > 본인 미읽음 행만 갱신, 공지 > 노출 중 공지만 읽음 기록 (없는 id 는 무시) */
    @Transactional
    public void markRead(UUID memberUuid, String categoryRequestValue, String notificationId) {
        NotificationCategory category = parseCategoryOrDefault(categoryRequestValue);
        UUID notificationUuid = parseUuid(notificationId);
        if (category == NotificationCategory.GENERAL) {
            memberNotificationRepository.markRead(memberUuid, notificationUuid, LocalDateTime.now());
        } else if (isVisibleNotice(notificationUuid)) {
            memberNoticeReadRepository.insertIfAbsent(memberUuid, notificationUuid, LocalDateTime.now());
        }
        unreadNotificationCountCache.evict(memberUuid);
    }

    /** 모두 읽음: category 지정이면 그 탭만, 비우면 두 탭 모두 */
    @Transactional
    public void markAllRead(UUID memberUuid, String categoryRequestValue) {
        boolean isAllCategories = categoryRequestValue == null || categoryRequestValue.isBlank();
        NotificationCategory category = isAllCategories ? null : NotificationCategory.fromRequestValue(categoryRequestValue);
        if (isAllCategories || category == NotificationCategory.GENERAL) {
            memberNotificationRepository.markAllRead(memberUuid, LocalDateTime.now());
        }
        if (isAllCategories || category == NotificationCategory.NOTICE) {
            markAllVisibleNoticesRead(memberUuid);
        }
        unreadNotificationCountCache.evict(memberUuid);
    }

    /**
     * 푸시 앱 아이콘 숫자: 회원별 안 읽은 알림 + 안 읽은 공지 (GROUP BY 1회씩, 회원마다 쿼리 금지)
     * memberUuids null = 전체 회원 조회, 결과에 없는 회원은 알림 0 + 공지 전체로 계산
     */
    public Map<UUID, Integer> countBadgeByMember(Collection<UUID> memberUuids) {
        List<UuidCountProjection> unreadGeneralRows = memberUuids == null
                ? memberNotificationRepository.countUnreadGroupedByAllMembers()
                : memberNotificationRepository.countUnreadGroupedByMember(memberUuids);
        Map<UUID, Long> unreadGeneralByMember = toCountMap(unreadGeneralRows);

        List<UUID> visibleNoticeUuids = getVisibleNoticeUuids();
        Map<UUID, Long> readNoticeByMember = visibleNoticeUuids.isEmpty() ? Map.of()
                : toCountMap(memberUuids == null
                        ? memberNoticeReadRepository.countReadGroupedByMember(visibleNoticeUuids)
                        : memberNoticeReadRepository.countReadGroupedByMember(memberUuids, visibleNoticeUuids));

        Set<UUID> badgeMemberUuids = memberUuids == null ? unreadGeneralByMember.keySet() : Set.copyOf(memberUuids);
        Map<UUID, Integer> badgeByMember = new HashMap<>();
        for (UUID memberUuid : badgeMemberUuids) {
            long unreadNoticeCount = visibleNoticeUuids.size() - readNoticeByMember.getOrDefault(memberUuid, 0L);
            badgeByMember.put(memberUuid, (int) (unreadGeneralByMember.getOrDefault(memberUuid, 0L) + unreadNoticeCount));
        }
        return badgeByMember;
    }

    /** 관리자 공지 목록: 공지별 읽은 회원 수 (GROUP BY 1회) */
    public Map<UUID, Long> countReadMembersByNotice(Collection<UUID> noticeUuids) {
        if (noticeUuids.isEmpty()) {
            return Map.of();
        }
        return toCountMap(memberNoticeReadRepository.countReadMembersGroupedByNotice(noticeUuids));
    }

    /** 알림 탭 한 페이지: 커서 이후 size+1 건 조회 > 남으면 마지막 항목 커서를 nextCursor 로 */
    private NotificationPageResponse getGeneralPage(UUID memberUuid, String cursor, int pageSize) {
        PageRequest fetchSize = PageRequest.of(0, pageSize + 1);
        List<MemberNotification> fetched;
        if (cursor == null || cursor.isBlank()) {
            fetched = memberNotificationRepository.findFirstPage(memberUuid, fetchSize);
        } else {
            NotificationCursor decodedCursor = NotificationCursor.decode(cursor);
            fetched = memberNotificationRepository.findNextPage(
                    memberUuid, decodedCursor.createdAt(), decodedCursor.notificationUuid(), fetchSize);
        }
        boolean hasNextPage = fetched.size() > pageSize;
        List<MemberNotification> pageRows = hasNextPage ? fetched.subList(0, pageSize) : fetched;
        String nextCursor = hasNextPage ? NotificationCursor.encode(pageRows.get(pageRows.size() - 1)) : null;
        return new NotificationPageResponse(pageRows.stream().map(MemberNotificationQueryService::toItem).toList(), nextCursor);
    }

    /** 공지 탭: 노출 중 공지 > 읽은 공지 1회 조회(IN) > isRead 계산 */
    private List<NotificationItemResponse> getNoticeItems(UUID memberUuid) {
        List<VisibleNoticeSummary> notices = appNoticeService.getVisibleNoticeSummaries();
        if (notices.isEmpty()) {
            return List.of();
        }
        List<VisibleNoticeSummary> limitedNotices = notices.size() > MAX_NOTICE_ITEMS ? notices.subList(0, MAX_NOTICE_ITEMS) : notices;
        Set<UUID> readNoticeUuids = memberNoticeReadRepository.findReadNoticeUuids(
                memberUuid, limitedNotices.stream().map(VisibleNoticeSummary::noticeUuid).toList());
        List<NotificationItemResponse> items = new ArrayList<>(limitedNotices.size());
        for (VisibleNoticeSummary notice : limitedNotices) {
            items.add(new NotificationItemResponse(notice.noticeUuid(), NotificationCategory.NOTICE, NOTICE_TYPE_NAME,
                    notice.title(), notice.body(), null, null, readNoticeUuids.contains(notice.noticeUuid()),
                    notice.publishedAt(), notice.isImportant()));
        }
        return items;
    }

    private long countUnreadNotices(UUID memberUuid) {
        List<UUID> visibleNoticeUuids = getVisibleNoticeUuids();
        if (visibleNoticeUuids.isEmpty()) {
            return 0;
        }
        return visibleNoticeUuids.size() - memberNoticeReadRepository.findReadNoticeUuids(memberUuid, visibleNoticeUuids).size();
    }

    /** 노출 중 공지 모두 읽음: 아직 안 읽은 공지만 기록 */
    private void markAllVisibleNoticesRead(UUID memberUuid) {
        List<UUID> visibleNoticeUuids = getVisibleNoticeUuids();
        if (visibleNoticeUuids.isEmpty()) {
            return;
        }
        Set<UUID> readNoticeUuids = memberNoticeReadRepository.findReadNoticeUuids(memberUuid, visibleNoticeUuids);
        LocalDateTime now = LocalDateTime.now();
        for (UUID noticeUuid : visibleNoticeUuids) {
            if (!readNoticeUuids.contains(noticeUuid)) {
                memberNoticeReadRepository.insertIfAbsent(memberUuid, noticeUuid, now);
            }
        }
    }

    private List<UUID> getVisibleNoticeUuids() {
        return appNoticeService.getVisibleNoticeSummaries().stream().map(VisibleNoticeSummary::noticeUuid).toList();
    }

    private boolean isVisibleNotice(UUID noticeUuid) {
        return getVisibleNoticeUuids().contains(noticeUuid);
    }

    private static NotificationItemResponse toItem(MemberNotification notification) {
        return new NotificationItemResponse(notification.getMemberNotificationUuid(), NotificationCategory.GENERAL,
                notification.getNotificationType().name(), notification.getTitle(), notification.getBody(),
                notification.getLinkTarget().name(), notification.getLinkQuestionUuid(), notification.isRead(),
                notification.getCreatedAt(), false);
    }

    private static Map<UUID, Long> toCountMap(List<UuidCountProjection> rows) {
        return rows.stream().collect(Collectors.toMap(UuidCountProjection::getKeyUuid, UuidCountProjection::getRowCount));
    }

    private static NotificationCategory parseCategoryOrDefault(String categoryRequestValue) {
        if (categoryRequestValue == null || categoryRequestValue.isBlank()) {
            return NotificationCategory.GENERAL;
        }
        return NotificationCategory.fromRequestValue(categoryRequestValue);
    }

    private static int clampPageSize(Integer size) {
        if (size == null || size < 1) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(size, MAX_PAGE_SIZE);
    }

    private static UUID parseUuid(String value) {
        try {
            return UUID.fromString(value);
        } catch (IllegalArgumentException | NullPointerException e) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "notification id");
        }
    }

    /** 목록 커서: 마지막 항목의 (createdAt, uuid) */
    record NotificationCursor(LocalDateTime createdAt, UUID notificationUuid) {

        static String encode(MemberNotification lastNotification) {
            String raw = lastNotification.getCreatedAt() + CURSOR_DELIMITER + lastNotification.getMemberNotificationUuid();
            return Base64.getUrlEncoder().withoutPadding().encodeToString(raw.getBytes(StandardCharsets.UTF_8));
        }

        /** 잘못된 커서 > INVALID_INPUT_VALUE */
        static NotificationCursor decode(String cursor) {
            try {
                String raw = new String(Base64.getUrlDecoder().decode(cursor), StandardCharsets.UTF_8);
                int delimiterIndex = raw.indexOf(CURSOR_DELIMITER);
                return new NotificationCursor(LocalDateTime.parse(raw.substring(0, delimiterIndex)),
                        UUID.fromString(raw.substring(delimiterIndex + 1)));
            } catch (IllegalArgumentException | DateTimeParseException | StringIndexOutOfBoundsException e) {
                throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "cursor");
            }
        }
    }
}
