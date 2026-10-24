package com.passql.member.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.NotificationDeliveryMode;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.PushDevice;
import com.passql.member.dto.PushSendRequest;
import com.passql.member.dto.PushSendResult;
import com.passql.member.entity.PushSendHistory;
import com.passql.member.push.PushDeliveryResult;
import com.passql.member.push.PushMessage;
import com.passql.member.push.PushMessageSender;
import com.passql.member.push.PushTarget;
import com.passql.member.repository.MemberPushTokenRepository;
import com.passql.member.repository.MemberRepository;
import com.passql.member.repository.PushDeliveryFailureRepository;
import com.passql.member.repository.PushSendHistoryRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 푸시 전달: 결과 집계, 만료 토큰 삭제, 회원별 badge 부착, 발송 접수 검증·이력 (#467, #491). Firebase 대신 가짜 발송기. */
class PushNotificationServiceTest {

    private final MemberPushTokenRepository memberPushTokenRepository = mock(MemberPushTokenRepository.class);
    private final PushDeliveryFailureRepository pushDeliveryFailureRepository = mock(PushDeliveryFailureRepository.class);
    private final PushSendHistoryRepository pushSendHistoryRepository = mock(PushSendHistoryRepository.class);
    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final FakePushMessageSender fakePushMessageSender = new FakePushMessageSender();
    private final PushNotificationService service = new PushNotificationService(
            memberPushTokenRepository, pushDeliveryFailureRepository, pushSendHistoryRepository, memberRepository, fakePushMessageSender);

    /** 정해 둔 만료 토큰만 실패(만료)로 돌려주는 가짜 발송기. 받은 알림·대상을 남긴다 */
    private static class FakePushMessageSender implements PushMessageSender {
        final List<String> expiredTokens = new ArrayList<>();
        final List<PushMessage> sentMessages = new ArrayList<>();
        final List<PushTarget> sentTargets = new ArrayList<>();

        @Override
        public List<PushDeliveryResult> send(PushMessage message, List<PushTarget> targets) {
            sentMessages.add(message);
            sentTargets.addAll(targets);
            return targets.stream()
                    .map(target -> expiredTokens.contains(target.token())
                            ? PushDeliveryResult.failed(target.token(), true)
                            : PushDeliveryResult.delivered(target.token()))
                    .toList();
        }
    }

    @Test
    void 전달은_성공_실패를_세고_만료_토큰을_지우고_회원별_badge를_붙인다() {
        UUID memberWithUnread = UUID.randomUUID();
        UUID memberWithoutUnread = UUID.randomUUID();
        when(memberPushTokenRepository.deleteAllByTokenIn(List.of("token-expired"))).thenReturn(1);
        fakePushMessageSender.expiredTokens.add("token-expired");

        PushSendResult result = service.deliver(
                service.toPushMessage("제목", "본문", PushLinkTarget.HOME, null),
                List.of(new PushDevice(memberWithUnread, "token-a"), new PushDevice(memberWithUnread, "token-expired"),
                        new PushDevice(memberWithoutUnread, "token-b")),
                Map.of(memberWithUnread, 3));

        assertThat(result).isEqualTo(new PushSendResult(3, 2, 1, 1));
        assertThat(fakePushMessageSender.sentTargets).extracting(PushTarget::badgeCount).containsExactly(3, 3, 0);
        assertThat(fakePushMessageSender.sentMessages.get(0).data()).containsEntry("linkTarget", "HOME");
    }

    @Test
    void 대상_기기가_없으면_발송하지_않는다() {
        PushSendResult result = service.deliver(
                service.toPushMessage("제목", "본문", PushLinkTarget.STATS, null), List.of(), Map.of());

        assertThat(result).isEqualTo(new PushSendResult(0, 0, 0, 0));
        assertThat(fakePushMessageSender.sentMessages).isEmpty();
        verify(memberPushTokenRepository, never()).deleteAllByTokenIn(any());
    }

    @Test
    void 발송_접수는_검증_뒤_결과_수_0인_이력을_저장한다() {
        UUID memberUuid = UUID.randomUUID();
        UUID questionUuid = UUID.randomUUID();
        when(memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)).thenReturn(true);
        when(pushSendHistoryRepository.save(any(PushSendHistory.class))).thenAnswer(call -> call.getArgument(0));

        service.acceptSend(new PushSendRequest("제목", "본문", "MEMBER", memberUuid.toString(),
                "QUESTION_DETAIL", questionUuid.toString(), "INBOX_ONLY"), "admin");

        ArgumentCaptor<PushSendHistory> saved = ArgumentCaptor.forClass(PushSendHistory.class);
        verify(pushSendHistoryRepository).save(saved.capture());
        assertThat(saved.getValue().getAudience()).isEqualTo(PushAudience.MEMBER);
        assertThat(saved.getValue().getDeliveryMode()).isEqualTo(NotificationDeliveryMode.INBOX_ONLY);
        assertThat(saved.getValue().getLinkQuestionUuid()).isEqualTo(questionUuid);
        assertThat(saved.getValue().getRecipientCount()).isZero();
        assertThat(saved.getValue().getIsRetracted()).isFalse();
    }

    @Test
    void 전달_방식을_비우면_푸시와_알림함으로_접수한다() {
        when(pushSendHistoryRepository.save(any(PushSendHistory.class))).thenAnswer(call -> call.getArgument(0));

        PushSendHistory history = service.acceptSend(
                new PushSendRequest("제목", "본문", "ALL", null, "HOME", null, null), "admin");

        assertThat(history.getDeliveryMode()).isEqualTo(NotificationDeliveryMode.PUSH_AND_INBOX);
    }

    @Test
    void 특정_회원_발송에_UUID가_없거나_틀리면_거절한다() {
        assertThatThrownBy(() -> service.acceptSend(
                new PushSendRequest("제목", "본문", "MEMBER", "not-a-uuid", "HOME", null, null), "admin"))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.PUSH_TARGET_MEMBER_REQUIRED);
        verify(pushSendHistoryRepository, never()).save(any());
    }

    @Test
    void 문제_상세_이동에_문제_UUID가_없으면_거절한다() {
        assertThatThrownBy(() -> service.acceptSend(
                new PushSendRequest("제목", "본문", "ALL", null, "QUESTION_DETAIL", " ", null), "admin"))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.PUSH_LINK_QUESTION_REQUIRED);
    }

    @Test
    void 허용_목록에_없는_이동_경로나_전달_방식은_거절한다() {
        assertThatThrownBy(() -> service.acceptSend(
                new PushSendRequest("제목", "본문", "ALL", null, "/admin", null, null), "admin"))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
        assertThatThrownBy(() -> service.acceptSend(
                new PushSendRequest("제목", "본문", "ALL", null, "HOME", null, "SMS"), "admin"))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }

    @Test
    void 이미_회수한_발송은_다시_회수할_수_없다() {
        UUID historyUuid = UUID.randomUUID();
        PushSendHistory history = PushSendHistory.accept("제목", "본문", PushAudience.ALL, null,
                PushLinkTarget.HOME, null, NotificationDeliveryMode.INBOX_ONLY, "admin");
        when(pushSendHistoryRepository.findById(historyUuid)).thenReturn(Optional.of(history));

        service.markRetracted(historyUuid, "admin");

        assertThat(history.getIsRetracted()).isTrue();
        assertThatThrownBy(() -> service.markRetracted(historyUuid, "admin"))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.PUSH_ALREADY_RETRACTED);
    }

    @Test
    void 미접속_대상은_일수가_없으면_거부하고_있으면_이력에_남긴다() {
        when(pushSendHistoryRepository.save(any(PushSendHistory.class))).thenAnswer(call -> call.getArgument(0));

        assertThatThrownBy(() -> service.acceptSend(new PushSendRequest("제목", "본문", "INACTIVE_MEMBERS", null,
                "HOME", null, null, null, null), "admin"))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.PUSH_INACTIVE_DAYS_INVALID);

        PushSendHistory history = service.acceptSend(new PushSendRequest("제목", "본문", "INACTIVE_MEMBERS", null,
                "HOME", null, null, 30, null), "admin");
        assertThat(history.getInactiveDays()).isEqualTo(30);
        assertThat(history.getTargetMemberUuid()).isNull();
        assertThat(history.isScheduled()).isFalse();
    }

    @Test
    void 예약_시각이_범위를_벗어나면_거부하고_범위_안이면_예약_대기로_저장한다() {
        when(pushSendHistoryRepository.save(any(PushSendHistory.class))).thenAnswer(call -> call.getArgument(0));
        LocalDateTime tooSoon = LocalDateTime.now().plusSeconds(10);
        LocalDateTime tooFar = LocalDateTime.now().plusDays(91);
        LocalDateTime valid = LocalDateTime.now().plusHours(2);

        for (LocalDateTime invalid : List.of(tooSoon, tooFar)) {
            assertThatThrownBy(() -> service.acceptSend(new PushSendRequest("제목", "본문", "PRO_MEMBERS", null,
                    "HOME", null, null, null, invalid), "admin"))
                    .isInstanceOf(CustomException.class)
                    .extracting("errorCode").isEqualTo(ErrorCode.PUSH_SCHEDULE_TIME_INVALID);
        }

        PushSendHistory history = service.acceptSend(new PushSendRequest("제목", "본문", "PRO_MEMBERS", null,
                "HOME", null, null, null, valid), "admin", true);
        assertThat(history.isScheduled()).isTrue();
        assertThat(history.getSentAt()).isEqualTo(valid);
        assertThat(history.getIsTest()).isTrue();
    }

    @Test
    void 예약이_아닌_발송은_회수할_수_없다() {
        UUID historyUuid = UUID.randomUUID();
        PushSendHistory canceled = PushSendHistory.accept("제목", "본문", PushAudience.ALL, null, null, PushLinkTarget.HOME, null,
                NotificationDeliveryMode.PUSH_AND_INBOX, "admin", LocalDateTime.now().plusHours(1), false);
        when(pushSendHistoryRepository.findById(historyUuid)).thenReturn(Optional.of(canceled));

        assertThatThrownBy(() -> service.markRetracted(historyUuid, "admin"))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.PUSH_RETRACT_NOT_DISPATCHED);
    }
}
