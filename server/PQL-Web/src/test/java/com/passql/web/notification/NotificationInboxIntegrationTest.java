package com.passql.web.notification;

import com.passql.application.notification.MemberNotificationQueryService;
import com.passql.application.notification.MemberNotificationService;
import com.passql.application.notification.NotificationDispatchEvent;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.AuthProvider;
import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.MemberStatus;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.NotificationItemResponse;
import com.passql.member.dto.NotificationPageResponse;
import com.passql.member.dto.PushSendAcceptedResponse;
import com.passql.member.dto.PushSendRequest;
import com.passql.member.dto.UnreadNotificationCountResponse;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.meta.dto.AppNoticeResponse;
import com.passql.meta.dto.AppNoticeSaveRequest;
import com.passql.meta.service.AppNoticeService;
import com.passql.web.PassqlApplication;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 알림함 핵심 동작 (실제 dev DB, 테스트 끝에 롤백): 커서 목록, 안 읽은 개수, 읽음, 공지 탭, 전체 팬아웃, 회수, 푸시 배지 개수, 보관 정리
 */
@SpringBootTest(classes = PassqlApplication.class)
@ActiveProfiles("dev")
@Transactional
class NotificationInboxIntegrationTest {

    @Autowired MemberNotificationService memberNotificationService;
    @Autowired MemberNotificationQueryService queryService;
    @Autowired AppNoticeService appNoticeService;
    @Autowired MemberRepository memberRepository;
    @Autowired EntityManager entityManager;

    private UUID newMember() {
        String suffix = UUID.randomUUID().toString().substring(0, 8);
        Member member = Member.signUp("test-" + suffix, AuthProvider.GOOGLE, suffix + "@test.local", true, "알림테스트" + suffix);
        return memberRepository.save(member).getMemberUuid();
    }

    private void notify(UUID memberUuid, String title) {
        memberNotificationService.notifyMember(memberUuid, MemberNotificationType.ADMIN_MESSAGE, title, "본문",
                PushLinkTarget.HOME, null);
    }

    @Test
    void 알림_25건을_커서로_나눠_중복_없이_최신순으로_읽는다() {
        UUID memberUuid = newMember();
        for (int index = 0; index < 25; index++) {
            notify(memberUuid, "알림" + index);
        }

        List<NotificationItemResponse> allItems = new ArrayList<>();
        String cursor = null;
        int pageCount = 0;
        do {
            NotificationPageResponse page = queryService.getNotifications(memberUuid, "GENERAL", cursor, 10);
            allItems.addAll(page.items());
            cursor = page.nextCursor();
            pageCount++;
        } while (cursor != null);

        assertEquals(3, pageCount);
        assertEquals(25, allItems.size());
        assertEquals(25, new HashSet<>(allItems.stream().map(NotificationItemResponse::id).toList()).size());
        for (int index = 1; index < allItems.size(); index++) {
            assertFalse(allItems.get(index).createdAt().isAfter(allItems.get(index - 1).createdAt()));
        }
    }

    @Test
    void 읽음_모두_읽음에_따라_안_읽은_개수가_줄어든다() {
        UUID memberUuid = newMember();
        UUID otherMemberUuid = newMember();
        notify(memberUuid, "하나");
        notify(memberUuid, "둘");
        notify(otherMemberUuid, "남의 알림");
        UnreadNotificationCountResponse before = queryService.getUnreadCount(memberUuid);
        UUID firstId = queryService.getNotifications(memberUuid, "GENERAL", null, 20).items().get(0).id();

        queryService.markRead(memberUuid, "GENERAL", firstId.toString());
        // 남의 알림 id 로 읽음 요청해도 내 개수는 그대로
        UUID otherId = queryService.getNotifications(otherMemberUuid, "GENERAL", null, 20).items().get(0).id();
        queryService.markRead(memberUuid, "GENERAL", otherId.toString());
        long afterOne = queryService.getUnreadCount(memberUuid).general();
        queryService.markAllRead(memberUuid, "GENERAL");

        assertEquals(2, before.general());
        assertEquals(1, afterOne);
        assertEquals(0, queryService.getUnreadCount(memberUuid).general());
        assertEquals(1, queryService.getUnreadCount(otherMemberUuid).general());
    }

    @Test
    void 공지_탭은_노출_중_공지의_읽음을_계산하고_합계에_더한다() {
        UUID memberUuid = newMember();
        long visibleBefore = appNoticeService.getVisibleNotices().size();
        AppNoticeResponse notice = appNoticeService.createNotice(
                new AppNoticeSaveRequest("테스트 공지", "본문", null, null, true, true));
        notify(memberUuid, "알림 하나");

        UnreadNotificationCountResponse before = queryService.getUnreadCount(memberUuid);
        queryService.markRead(memberUuid, "NOTICE", notice.noticeUuid().toString());
        UnreadNotificationCountResponse after = queryService.getUnreadCount(memberUuid);
        NotificationItemResponse noticeItem = queryService.getNotifications(memberUuid, "NOTICE", null, null).items().stream()
                .filter(item -> item.id().equals(notice.noticeUuid())).findFirst().orElseThrow();

        assertEquals(visibleBefore + 1, before.notice());
        assertEquals(visibleBefore, after.notice());
        assertEquals(1, after.general());
        assertEquals(after.general() + after.notice(), after.total());
        assertTrue(noticeItem.isRead());
        assertTrue(noticeItem.isImportant());
        assertNull(noticeItem.linkTarget());
    }

    @Test
    void 전체_팬아웃은_활성_회원마다_1건을_만들고_회수하면_모두_숨겨진다() {
        UUID memberUuid = newMember();
        long expectedRecipientCount = memberRepository.countByIsDeletedFalseAndStatusNot(MemberStatus.WITHDRAWN);
        // 테스트 트랜잭션은 커밋되지 않아 비동기 후처리는 실행되지 않음 > 팬아웃을 직접 호출
        PushSendAcceptedResponse accepted = memberNotificationService.sendAdminMessage(
                new PushSendRequest("전체 알림", "본문", "ALL", null, "HOME", null, "INBOX_ONLY"), "test-admin");

        int createdCount = memberNotificationService.fanOutToAllMembers(new NotificationDispatchEvent(
                accepted.pushSendHistoryUuid(), null, MemberNotificationType.ADMIN_MESSAGE, "전체 알림", "본문",
                PushLinkTarget.HOME, null, true, false));
        entityManager.clear();
        long unreadBeforeRetract = queryService.getUnreadCount(memberUuid).general();
        int hiddenCount = memberNotificationService.retractAdminMessage(accepted.pushSendHistoryUuid(), "test-admin");
        entityManager.clear();

        assertEquals(expectedRecipientCount, accepted.targetMemberCount());
        assertEquals(expectedRecipientCount, createdCount);
        assertEquals(1, unreadBeforeRetract);
        assertEquals(createdCount, hiddenCount);
        // 회수 표시가 실제로 저장돼 두 번째 회수는 거절
        assertTrue(assertThrows(CustomException.class,
                () -> memberNotificationService.retractAdminMessage(accepted.pushSendHistoryUuid(), "test-admin"))
                .getErrorCode() == ErrorCode.PUSH_ALREADY_RETRACTED);
        assertEquals(0, queryService.getUnreadCount(memberUuid).general());
        assertTrue(queryService.getNotifications(memberUuid, "GENERAL", null, 20).items().isEmpty());
    }

    @Test
    void 푸시_배지는_회원별_안_읽은_알림과_공지를_GROUP_BY로_계산한다() {
        UUID memberWithTwo = newMember();
        UUID memberWithNone = newMember();
        notify(memberWithTwo, "하나");
        notify(memberWithTwo, "둘");
        long visibleNoticeCount = appNoticeService.getVisibleNotices().size();
        entityManager.flush();

        Map<UUID, Integer> badgeByMember = queryService.countBadgeByMember(Set.of(memberWithTwo, memberWithNone));

        assertEquals(2 + visibleNoticeCount, (long) badgeByMember.get(memberWithTwo));
        assertEquals(visibleNoticeCount, (long) badgeByMember.get(memberWithNone));
    }

    @Test
    void 보관_기간이_지난_알림만_정리한다() {
        UUID memberUuid = newMember();
        notify(memberUuid, "오래된 알림");
        notify(memberUuid, "최근 알림");
        entityManager.flush();
        // 첫 번째 알림을 보관 기간(기본 90일)보다 오래된 시각으로 되돌림
        entityManager.createNativeQuery("UPDATE member_notification SET created_at = :oldAt "
                        + "WHERE member_uuid = :memberUuid AND title = '오래된 알림'")
                .setParameter("oldAt", LocalDateTime.now().minusDays(400))
                .setParameter("memberUuid", memberUuid).executeUpdate();
        entityManager.clear();

        int purgedCount = memberNotificationService.purgeExpiredNotifications();

        assertTrue(purgedCount >= 1);
        List<NotificationItemResponse> remainingItems = queryService.getNotifications(memberUuid, "GENERAL", null, 20).items();
        assertEquals(1, remainingItems.size());
        assertEquals("최근 알림", remainingItems.get(0).title());
    }
}
