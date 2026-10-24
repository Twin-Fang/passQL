package com.passql.application.member;

import com.passql.application.notification.MemberNotificationService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.AuthProvider;
import com.passql.member.constant.MemberRole;
import com.passql.member.constant.MemberStatus;
import com.passql.member.dto.MemberBulkPushRequest;
import com.passql.member.dto.MemberBulkResultResponse;
import com.passql.member.dto.MemberBulkSuspendRequest;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.member.service.MemberAdminService;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 회원 일괄 작업: 관리자·탈퇴·없는 회원은 건너뛰고, 규칙 위반은 실패로 집계 */
class MemberAdminOperationServiceTest {

    private final MemberRepository memberRepository = mock(MemberRepository.class);
    private final MemberAdminService memberAdminService = mock(MemberAdminService.class);
    private final MemberNotificationService memberNotificationService = mock(MemberNotificationService.class);
    private final MemberAdminOperationService service =
        new MemberAdminOperationService(memberRepository, memberAdminService, memberNotificationService);

    private Member newMember(UUID memberUuid, MemberRole role, MemberStatus status) {
        Member member = Member.signUp("provider-" + memberUuid, AuthProvider.GOOGLE, "a@test.local", true, "닉" + memberUuid);
        member.setMemberUuid(memberUuid);
        member.setRole(role);
        member.setStatus(status);
        return member;
    }

    private MemberBulkSuspendRequest newSuspendRequest(List<UUID> memberUuids, LocalDateTime suspendUntil) {
        MemberBulkSuspendRequest request = new MemberBulkSuspendRequest();
        request.setMemberUuids(memberUuids);
        request.setReasonCategory("SPAM");
        request.setReason("광고");
        request.setSuspendUntil(suspendUntil);
        return request;
    }

    @Test
    void 일괄_제재는_관리자_탈퇴_없는_회원을_건너뛴다() {
        UUID normalUuid = UUID.randomUUID();
        UUID adminUuid = UUID.randomUUID();
        UUID withdrawnUuid = UUID.randomUUID();
        UUID missingUuid = UUID.randomUUID();
        List<UUID> memberUuids = List.of(normalUuid, adminUuid, withdrawnUuid, missingUuid);
        when(memberRepository.findAllById(memberUuids)).thenReturn(List.of(
            newMember(normalUuid, MemberRole.USER, MemberStatus.ACTIVE),
            newMember(adminUuid, MemberRole.ADMIN, MemberStatus.ACTIVE),
            newMember(withdrawnUuid, MemberRole.USER, MemberStatus.WITHDRAWN)));

        MemberBulkResultResponse result = service.suspendMembers(newSuspendRequest(memberUuids, LocalDateTime.now().plusDays(1)));

        assertThat(result).isEqualTo(new MemberBulkResultResponse(1, 3, 0));
        verify(memberAdminService, never()).suspendMember(eq(adminUuid), any(), any(), any());
    }

    @Test
    void 일괄_제재에서_규칙_위반은_실패로_집계하고_나머지를_계속한다() {
        UUID firstUuid = UUID.randomUUID();
        UUID secondUuid = UUID.randomUUID();
        List<UUID> memberUuids = List.of(firstUuid, secondUuid);
        when(memberRepository.findAllById(memberUuids)).thenReturn(List.of(
            newMember(firstUuid, MemberRole.USER, MemberStatus.ACTIVE),
            newMember(secondUuid, MemberRole.USER, MemberStatus.ACTIVE)));
        LocalDateTime suspendUntil = LocalDateTime.now().plusDays(1);
        doThrow(new CustomException(ErrorCode.INVALID_SUSPEND_UNTIL))
            .when(memberAdminService).suspendMember(eq(firstUuid), any(), any(), eq(suspendUntil));

        MemberBulkResultResponse result = service.suspendMembers(newSuspendRequest(memberUuids, suspendUntil));

        assertThat(result).isEqualTo(new MemberBulkResultResponse(1, 0, 1));
    }

    @Test
    void 푸시는_탈퇴_회원을_건너뛰고_정상_회원에게_발송한다() {
        UUID normalUuid = UUID.randomUUID();
        UUID withdrawnUuid = UUID.randomUUID();
        List<UUID> memberUuids = List.of(normalUuid, withdrawnUuid);
        when(memberRepository.findAllById(memberUuids)).thenReturn(List.of(
            newMember(normalUuid, MemberRole.USER, MemberStatus.ACTIVE),
            newMember(withdrawnUuid, MemberRole.USER, MemberStatus.WITHDRAWN)));

        MemberBulkResultResponse result = service.sendPushToMembers(
            new MemberBulkPushRequest(memberUuids, "제목", "본문"), "admin");

        assertThat(result).isEqualTo(new MemberBulkResultResponse(1, 1, 0));
        verify(memberNotificationService).sendAdminMessage(any(), eq("admin"));
    }
}
