package com.passql.member.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushLinkTarget;
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
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 푸시 발송 공통 지점: 대상 조회, 발송, 만료 토큰 삭제, 결과 집계, 이력 저장
 * 대상은 수신 동의 기기만
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PushNotificationService {

    private final MemberPushTokenRepository memberPushTokenRepository;
    private final PushSendHistoryRepository pushSendHistoryRepository;
    private final MemberRepository memberRepository;
    private final PushMessageSender pushMessageSender;

    /** 관리자 발송: 검증 > 대상 토큰 조회 > 발송 > 만료 토큰 삭제 > 이력 저장 */
    @Transactional
    public PushSendResult send(PushSendRequest request, String sentByAdmin) {
        PushAudience audience = PushAudience.fromRequestValue(request.getAudience());
        PushLinkTarget linkTarget = PushLinkTarget.fromRequestValue(request.getLinkTarget());
        UUID targetMemberUuid = resolveTargetMemberUuid(audience, request.getTargetMemberUuid());
        UUID linkQuestionUuid = resolveLinkQuestionUuid(linkTarget, request.getLinkQuestionUuid());

        List<String> tokens = findTargetTokens(audience, targetMemberUuid);
        List<PushDeliveryResult> deliveries = tokens.isEmpty()
                ? List.of()
                : pushMessageSender.send(toPushMessage(request, linkTarget, linkQuestionUuid), tokens);
        int removedTokenCount = removeExpiredTokens(deliveries);

        PushSendResult result = summarize(tokens.size(), deliveries, removedTokenCount);
        pushSendHistoryRepository.save(PushSendHistory.of(
                request.getTitle(), request.getBody(), audience, targetMemberUuid, linkTarget, linkQuestionUuid,
                result.targetDeviceCount(), result.successCount(), result.failureCount(),
                result.removedTokenCount(), sentByAdmin));
        log.info("[push send] {} by {} : devices={}, success={}, failure={}, removed={}",
                audience, sentByAdmin, result.targetDeviceCount(), result.successCount(),
                result.failureCount(), result.removedTokenCount());
        return result;
    }

    /** 발송 이력 (최신순) */
    public Page<PushSendHistory> getSendHistories(Pageable pageable) {
        return pushSendHistoryRepository.findAllByOrderBySentAtDesc(pageable);
    }

    /** 전체 발송 시 대상 기기 수 (수신 동의) */
    public long countPushEnabledDevices() {
        return memberPushTokenRepository.countByIsPushEnabledTrue();
    }

    /** 대상 회원 UUID: ALL > null, MEMBER > 형식·존재 확인 */
    private UUID resolveTargetMemberUuid(PushAudience audience, String targetMemberUuid) {
        if (audience == PushAudience.ALL) {
            return null;
        }
        UUID memberUuid = parseUuidOrThrow(targetMemberUuid, ErrorCode.PUSH_TARGET_MEMBER_REQUIRED);
        if (!memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)) {
            throw new CustomException(ErrorCode.MEMBER_NOT_FOUND);
        }
        return memberUuid;
    }

    /** 이동 문제 UUID: 문제 상세만 필수, 그 외 무시 */
    private UUID resolveLinkQuestionUuid(PushLinkTarget linkTarget, String linkQuestionUuid) {
        if (!linkTarget.isQuestionUuidRequired()) {
            return null;
        }
        return parseUuidOrThrow(linkQuestionUuid, ErrorCode.PUSH_LINK_QUESTION_REQUIRED);
    }

    private List<String> findTargetTokens(PushAudience audience, UUID targetMemberUuid) {
        List<MemberPushToken> pushTokens = audience == PushAudience.ALL
                ? memberPushTokenRepository.findAllByIsPushEnabledTrue()
                : memberPushTokenRepository.findAllByMemberUuidAndIsPushEnabledTrue(targetMemberUuid);
        return pushTokens.stream().map(MemberPushToken::getToken).toList();
    }

    /** 알림 내용 + 이동 데이터 (linkTarget, 문제 상세면 questionUuid) */
    private PushMessage toPushMessage(PushSendRequest request, PushLinkTarget linkTarget, UUID linkQuestionUuid) {
        Map<String, String> data = new LinkedHashMap<>();
        data.put(PushDataKeys.LINK_TARGET, linkTarget.name());
        if (linkQuestionUuid != null) {
            data.put(PushDataKeys.QUESTION_UUID, linkQuestionUuid.toString());
        }
        return new PushMessage(request.getTitle(), request.getBody(), data);
    }

    /** 만료 토큰 삭제 > 삭제 수 */
    private int removeExpiredTokens(List<PushDeliveryResult> deliveries) {
        List<String> expiredTokens = deliveries.stream()
                .filter(PushDeliveryResult::isTokenExpired)
                .map(PushDeliveryResult::token)
                .toList();
        if (expiredTokens.isEmpty()) {
            return 0;
        }
        return memberPushTokenRepository.deleteAllByTokenIn(expiredTokens);
    }

    private PushSendResult summarize(int targetDeviceCount, List<PushDeliveryResult> deliveries, int removedTokenCount) {
        int successCount = (int) deliveries.stream().filter(PushDeliveryResult::isDelivered).count();
        return new PushSendResult(targetDeviceCount, successCount, deliveries.size() - successCount, removedTokenCount);
    }

    private static UUID parseUuidOrThrow(String value, ErrorCode errorCode) {
        if (value == null || value.isBlank()) {
            throw new CustomException(errorCode);
        }
        try {
            return UUID.fromString(value.trim());
        } catch (IllegalArgumentException e) {
            throw new CustomException(errorCode);
        }
    }
}
