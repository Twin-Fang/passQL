package com.passql.web.notification;

import com.passql.application.notification.MemberNotificationQueryService;
import com.passql.application.notification.MemberNotificationService;
import com.passql.application.notification.NotificationDispatchEvent;
import com.passql.application.notification.NotificationDispatcher;
import com.passql.member.constant.MemberNotificationType;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.PushDevice;
import com.passql.member.dto.PushSendResult;
import com.passql.member.push.PushMessage;
import com.passql.member.service.PushAudienceResolver;
import com.passql.member.service.PushNotificationService;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 커밋 뒤 처리 순서: 팬아웃 > 기기 조회 > 배지 계산 > 전달 > 이력 기록, 방식·대상별 분기, 실패 격리 */
class NotificationDispatcherTest {

    private final MemberNotificationService memberNotificationService = mock(MemberNotificationService.class);
    private final MemberNotificationQueryService queryService = mock(MemberNotificationQueryService.class);
    private final PushNotificationService pushNotificationService = mock(PushNotificationService.class);
    private final PushAudienceResolver pushAudienceResolver = mock(PushAudienceResolver.class);
    private final NotificationDispatcher dispatcher =
            new NotificationDispatcher(memberNotificationService, queryService, pushNotificationService, pushAudienceResolver);

    private final UUID historyUuid = UUID.randomUUID();
    private final PushMessage pushMessage = new PushMessage("제목", "본문", Map.of());

    private NotificationDispatchEvent event(UUID targetMemberUuid, boolean isFanoutRequired, boolean isPushRequired) {
        return new NotificationDispatchEvent(historyUuid, targetMemberUuid, MemberNotificationType.ADMIN_MESSAGE,
                "제목", "본문", PushLinkTarget.HOME, null, isFanoutRequired, isPushRequired);
    }

    @Test
    void 전체_발송은_팬아웃_뒤_전체_배지로_푸시를_전달하고_결과를_기록한다() {
        UUID memberUuid = UUID.randomUUID();
        List<PushDevice> devices = List.of(new PushDevice(memberUuid, "token-a"));
        PushSendResult result = new PushSendResult(1, 1, 0, 0);
        when(pushNotificationService.findDevices(null)).thenReturn(devices);
        when(queryService.countBadgeByMember(null)).thenReturn(Map.of(memberUuid, 4));
        when(pushNotificationService.toPushMessage("제목", "본문", PushLinkTarget.HOME, null)).thenReturn(pushMessage);
        when(pushNotificationService.deliver(pushMessage, devices, Map.of(memberUuid, 4), historyUuid)).thenReturn(result);
        NotificationDispatchEvent event = event(null, true, true);

        dispatcher.dispatch(event);

        var order = inOrder(memberNotificationService, pushNotificationService);
        order.verify(memberNotificationService).fanOutToAllMembers(event);
        order.verify(pushNotificationService).deliver(pushMessage, devices, Map.of(memberUuid, 4), historyUuid);
        order.verify(pushNotificationService).recordDeliveryResult(historyUuid, result);
    }

    @Test
    void 알림함만_보내면_푸시_전달을_하지_않는다() {
        dispatcher.dispatch(event(null, true, false));

        verify(memberNotificationService).fanOutToAllMembers(any());
        verify(pushNotificationService, never()).findDevices(any());
    }

    @Test
    void 특정_회원은_팬아웃_없이_그_회원_기기에만_배지를_계산한다() {
        UUID memberUuid = UUID.randomUUID();
        List<PushDevice> devices = List.of(new PushDevice(memberUuid, "token-a"));
        when(pushNotificationService.findDevices(memberUuid)).thenReturn(devices);
        when(pushNotificationService.deliver(any(), eq(devices), any(), eq(historyUuid))).thenReturn(new PushSendResult(1, 1, 0, 0));

        dispatcher.dispatch(event(memberUuid, false, true));

        verify(memberNotificationService, never()).fanOutToAllMembers(any());
        verify(queryService).countBadgeByMember(Set.of(memberUuid));
    }

    @Test
    void 기기가_없으면_전달하지_않고_처리_중_예외는_밖으로_던지지_않는다() {
        when(pushNotificationService.findDevices(null)).thenReturn(List.of());
        dispatcher.dispatch(event(null, false, true));
        verify(pushNotificationService, never()).deliver(any(), any(), any());

        when(memberNotificationService.fanOutToAllMembers(any())).thenThrow(new IllegalStateException("db down"));
        dispatcher.dispatch(event(null, true, true));
    }
}
