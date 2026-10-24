package com.passql.application.member;

import com.passql.application.notification.MemberNotificationService;
import com.passql.common.exception.CustomException;
import com.passql.member.constant.MemberStatus;
import com.passql.member.constant.SuspendReasonCategory;
import com.passql.member.dto.MemberBulkPushRequest;
import com.passql.member.dto.MemberBulkResultResponse;
import com.passql.member.dto.MemberBulkSuspendRequest;
import com.passql.member.dto.PushSendRequest;
import com.passql.member.entity.Member;
import com.passql.member.repository.MemberRepository;
import com.passql.member.service.MemberAdminService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 관리자 회원 일괄 작업: 일괄 제재, 회원 푸시(1명·여러 명)
 * 건별 처리 > 건너뜀(없는 회원·관리자·탈퇴) / 실패(규칙 위반) 집계, 건마다 별도 트랜잭션·감사 로그는 각 서비스가 담당
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MemberAdminOperationService {

    // 푸시 이동 화면: 홈 (회원 푸시는 특정 화면 이동 없음)
    private static final String PUSH_LINK_TARGET_HOME = "HOME";
    // 푸시 대상 지정 방식: 특정 회원
    private static final String PUSH_AUDIENCE_MEMBER = "MEMBER";

    private final MemberRepository memberRepository;
    private final MemberAdminService memberAdminService;
    private final MemberNotificationService memberNotificationService;

    /** 일괄 제재: 분류 검증 > 대상 조회 > 관리자·탈퇴·없는 회원 건너뜀 > 건별 제재 */
    public MemberBulkResultResponse suspendMembers(MemberBulkSuspendRequest request) {
        SuspendReasonCategory reasonCategory = SuspendReasonCategory.fromRequestValueOrNull(request.getReasonCategory());
        List<UUID> targetMemberUuids = request.getMemberUuids().stream().distinct().toList();
        Map<UUID, Member> memberByUuid = findMembersByUuid(targetMemberUuids);
        int succeededCount = 0;
        int skippedCount = 0;
        int failedCount = 0;
        for (UUID memberUuid : targetMemberUuids) {
            Member member = memberByUuid.get(memberUuid);
            if (member == null || member.getRole().isAdmin() || member.getStatus() == MemberStatus.WITHDRAWN) {
                skippedCount++;
                continue;
            }
            try {
                memberAdminService.suspendMember(memberUuid, reasonCategory, request.getReason(), request.getSuspendUntil());
                succeededCount++;
            } catch (CustomException rejectedSuspend) {
                // 만료 시각 오류 등 규칙 위반 (건별 로그만, 나머지 계속)
                log.warn("[member bulk suspend] rejected : member={}, code={}", memberUuid, rejectedSuspend.getErrorCode());
                failedCount++;
            }
        }
        return new MemberBulkResultResponse(succeededCount, skippedCount, failedCount);
    }

    /** 회원 푸시: 대상 조회 > 탈퇴·없는 회원 건너뜀 > 건별 발송(푸시 + 알림함) */
    public MemberBulkResultResponse sendPushToMembers(MemberBulkPushRequest request, String sentByAdmin) {
        List<UUID> targetMemberUuids = request.memberUuids().stream().distinct().toList();
        Map<UUID, Member> memberByUuid = findMembersByUuid(targetMemberUuids);
        int succeededCount = 0;
        int skippedCount = 0;
        int failedCount = 0;
        for (UUID memberUuid : targetMemberUuids) {
            Member member = memberByUuid.get(memberUuid);
            if (member == null || member.getStatus() == MemberStatus.WITHDRAWN) {
                skippedCount++;
                continue;
            }
            try {
                memberNotificationService.sendAdminMessage(new PushSendRequest(request.title(), request.body(),
                    PUSH_AUDIENCE_MEMBER, memberUuid.toString(), PUSH_LINK_TARGET_HOME, null, null), sentByAdmin);
                succeededCount++;
            } catch (CustomException rejectedPush) {
                log.warn("[member push] rejected : member={}, code={}", memberUuid, rejectedPush.getErrorCode());
                failedCount++;
            }
        }
        return new MemberBulkResultResponse(succeededCount, skippedCount, failedCount);
    }

    private Map<UUID, Member> findMembersByUuid(List<UUID> memberUuids) {
        return memberRepository.findAllById(memberUuids).stream()
            .filter(member -> !member.isDeleted())
            .collect(Collectors.toMap(Member::getMemberUuid, Function.identity()));
    }
}
