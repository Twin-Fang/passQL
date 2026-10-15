package com.passql.member.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.constant.PushPlatform;
import com.passql.member.dto.PushSendRequest;
import com.passql.member.dto.PushSendResult;
import com.passql.member.entity.MemberPushToken;
import com.passql.member.entity.PushSendHistory;
import com.passql.member.push.PushDataKeys;
import com.passql.member.push.PushDeliveryResult;
import com.passql.member.push.PushMessage;
import com.passql.member.push.PushMessageSender;
import com.passql.member.repository.MemberPushTokenRepository;
import com.passql.member.repository.MemberRepository;
import com.passql.member.repository.PushSendHistoryRepository;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 푸시 발송: 결과 집계, 만료 토큰 삭제, 이력 저장, 대상·이동 검증 (#467). Firebase 대신 가짜 발송기. */
class PushNotificationServiceTest {

    private final MemberPushTokenRepository memberPushTokenRepository = mock(MemberPushTokenRepository.class);
    private final PushSendHistoryRepository pushSendHistoryRepository = mock(PushSendHistoryRepository.class);
    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final FakePushMessageSender fakePushMessageSender = new FakePushMessageSender();
    private final PushNotificationService service = new PushNotificationService(
            memberPushTokenRepository, pushSendHistoryRepository, memberRepository, fakePushMessageSender);

    /** 정해 둔 만료 토큰만 실패(만료)로 돌려주는 가짜 발송기. 받은 알림을 남긴다 */
    private static class FakePushMessageSender implements PushMessageSender {
        final List<String> expiredTokens = new ArrayList<>();
        final List<PushMessage> sentMessages = new ArrayList<>();

        @Override
        public List<PushDeliveryResult> send(PushMessage message, List<String> tokens) {
            sentMessages.add(message);
            return tokens.stream()
                    .map(token -> expiredTokens.contains(token)
                            ? PushDeliveryResult.failed(token, true)
                            : PushDeliveryResult.delivered(token))
                    .toList();
        }
    }

    private static MemberPushToken pushToken(String token) {
        return MemberPushToken.create(UUID.randomUUID(), token, PushPlatform.ANDROID);
    }

    @Test
    void 전체_발송은_성공_실패를_세고_만료_토큰을_지우고_이력을_남긴다() {
        when(memberPushTokenRepository.findAllByIsPushEnabledTrue())
                .thenReturn(List.of(pushToken("token-a"), pushToken("token-b"), pushToken("token-expired")));
        when(memberPushTokenRepository.deleteAllByTokenIn(List.of("token-expired"))).thenReturn(1);
        fakePushMessageSender.expiredTokens.add("token-expired");

        PushSendResult result = service.send(
                new PushSendRequest("제목", "본문", "ALL", null, "HOME", null), "admin");

        assertThat(result).isEqualTo(new PushSendResult(3, 2, 1, 1));
        assertThat(fakePushMessageSender.sentMessages.get(0).data())
                .containsEntry(PushDataKeys.LINK_TARGET, "HOME")
                .doesNotContainKey(PushDataKeys.QUESTION_UUID);
        ArgumentCaptor<PushSendHistory> savedHistory = ArgumentCaptor.forClass(PushSendHistory.class);
        verify(pushSendHistoryRepository).save(savedHistory.capture());
        assertThat(savedHistory.getValue().getAudience()).isEqualTo(PushAudience.ALL);
        assertThat(savedHistory.getValue().getSuccessCount()).isEqualTo(2);
        assertThat(savedHistory.getValue().getSentByAdmin()).isEqualTo("admin");
    }

    @Test
    void 특정_회원_문제_상세_발송은_문제_UUID를_데이터에_싣는다() {
        UUID memberUuid = UUID.randomUUID();
        UUID questionUuid = UUID.randomUUID();
        when(memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)).thenReturn(true);
        when(memberPushTokenRepository.findAllByMemberUuidAndIsPushEnabledTrue(memberUuid))
                .thenReturn(List.of(pushToken("token-a")));

        service.send(new PushSendRequest("제목", "본문", "MEMBER", memberUuid.toString(),
                "QUESTION_DETAIL", questionUuid.toString()), "admin");

        assertThat(fakePushMessageSender.sentMessages.get(0).data())
                .containsEntry(PushDataKeys.LINK_TARGET, PushLinkTarget.QUESTION_DETAIL.name())
                .containsEntry(PushDataKeys.QUESTION_UUID, questionUuid.toString());
        verify(memberPushTokenRepository, never()).deleteAllByTokenIn(any());
    }

    @Test
    void 대상_기기가_없으면_발송하지_않고_0건_이력을_남긴다() {
        when(memberPushTokenRepository.findAllByIsPushEnabledTrue()).thenReturn(List.of());

        PushSendResult result = service.send(
                new PushSendRequest("제목", "본문", "ALL", null, "STATS", null), "admin");

        assertThat(result).isEqualTo(new PushSendResult(0, 0, 0, 0));
        assertThat(fakePushMessageSender.sentMessages).isEmpty();
        verify(pushSendHistoryRepository).save(any());
    }

    @Test
    void 특정_회원_발송에_UUID가_없거나_틀리면_거절한다() {
        assertThatThrownBy(() -> service.send(
                new PushSendRequest("제목", "본문", "MEMBER", "not-a-uuid", "HOME", null), "admin"))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.PUSH_TARGET_MEMBER_REQUIRED);
        assertThat(fakePushMessageSender.sentMessages).isEmpty();
    }

    @Test
    void 문제_상세_이동에_문제_UUID가_없으면_거절한다() {
        assertThatThrownBy(() -> service.send(
                new PushSendRequest("제목", "본문", "ALL", null, "QUESTION_DETAIL", " "), "admin"))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.PUSH_LINK_QUESTION_REQUIRED);
    }

    @Test
    void 허용_목록에_없는_이동_경로는_거절한다() {
        assertThatThrownBy(() -> service.send(
                new PushSendRequest("제목", "본문", "ALL", null, "/admin", null), "admin"))
                .isInstanceOf(CustomException.class)
                .extracting("errorCode").isEqualTo(ErrorCode.INVALID_INPUT_VALUE);
    }
}
