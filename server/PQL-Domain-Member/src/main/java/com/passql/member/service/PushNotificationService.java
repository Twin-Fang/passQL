package com.passql.member.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.constant.MemberStatus;
import com.passql.member.constant.NotificationDeliveryMode;
import com.passql.member.constant.PushAudience;
import com.passql.member.constant.PushLinkTarget;
import com.passql.member.dto.PushDevice;
import com.passql.member.dto.PushDeviceSummary;
import com.passql.member.dto.PushSendRequest;
import com.passql.member.dto.PushSendResult;
import com.passql.member.entity.MemberPushToken;
import com.passql.member.entity.PushSendHistory;
import com.passql.member.push.PushDataKeys;
import com.passql.member.push.PushDeliveryResult;
import com.passql.member.push.PushMessage;
import com.passql.member.push.PushMessageSender;
import com.passql.member.push.PushTarget;
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
 * 푸시 전달 공통 지점: 발송 접수(검증 > 이력 저장), 대상 기기 조회, 전달, 만료 토큰 삭제, 결과 기록, 회수
 * 알림함 저장은 MemberNotificationService 가 담당, 여기서는 기기 전달과 이력만
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PushNotificationService {

    // 앱 아이콘 숫자 하한 (안 읽은 알림이 없으면 0 = 숫자 제거)
    private static final int NO_UNREAD_BADGE_COUNT = 0;

    private final MemberPushTokenRepository memberPushTokenRepository;
    private final PushSendHistoryRepository pushSendHistoryRepository;
    private final MemberRepository memberRepository;
    private final PushMessageSender pushMessageSender;

    /** 관리자 발송 접수: 대상·이동 검증 > 이력 저장 (결과 수 0, 저장·전달은 호출부가 이어서 처리) */
    @Transactional
    public PushSendHistory acceptSend(PushSendRequest request, String sentByAdmin) {
        PushAudience audience = PushAudience.fromRequestValue(request.getAudience());
        PushLinkTarget linkTarget = PushLinkTarget.fromRequestValue(request.getLinkTarget());
        NotificationDeliveryMode deliveryMode = NotificationDeliveryMode.fromRequestValue(request.getDeliveryMode());
        UUID targetMemberUuid = resolveTargetMemberUuid(audience, request.getTargetMemberUuid());
        UUID linkQuestionUuid = resolveLinkQuestionUuid(linkTarget, request.getLinkQuestionUuid());
        return pushSendHistoryRepository.save(PushSendHistory.accept(
                request.getTitle(), request.getBody(), audience, targetMemberUuid,
                linkTarget, linkQuestionUuid, deliveryMode, sentByAdmin));
    }

    /** 푸시 수신 동의 기기 (회원 지정이면 그 회원 기기만, null 이면 전체) */
    public List<PushDevice> findDevices(UUID targetMemberUuid) {
        List<MemberPushToken> pushTokens = targetMemberUuid == null
                ? memberPushTokenRepository.findAllByIsPushEnabledTrue()
                : memberPushTokenRepository.findAllByMemberUuidAndIsPushEnabledTrue(targetMemberUuid);
        return pushTokens.stream().map(token -> new PushDevice(token.getMemberUuid(), token.getToken())).toList();
    }

    /** 푸시 전달: 기기별 badge 부착 > 발송 > 만료 토큰 삭제 > 결과 집계 */
    @Transactional
    public PushSendResult deliver(PushMessage message, List<PushDevice> devices, Map<UUID, Integer> badgeCountByMemberUuid) {
        if (devices.isEmpty()) {
            return new PushSendResult(0, 0, 0, 0);
        }
        List<PushTarget> targets = devices.stream()
                .map(device -> new PushTarget(device.token(),
                        badgeCountByMemberUuid.getOrDefault(device.memberUuid(), NO_UNREAD_BADGE_COUNT)))
                .toList();
        List<PushDeliveryResult> deliveries = pushMessageSender.send(message, targets);
        int removedTokenCount = removeExpiredTokens(deliveries);
        return summarize(devices.size(), deliveries, removedTokenCount);
    }

    /** 알림 내용 + 이동 데이터 (linkTarget, 문제 상세면 questionUuid) */
    public PushMessage toPushMessage(String title, String body, PushLinkTarget linkTarget, UUID linkQuestionUuid) {
        Map<String, String> data = new LinkedHashMap<>();
        data.put(PushDataKeys.LINK_TARGET, linkTarget.name());
        if (linkQuestionUuid != null) {
            data.put(PushDataKeys.QUESTION_UUID, linkQuestionUuid.toString());
        }
        return new PushMessage(title, body, data);
    }

    /** 알림함에 만든 행 수 기록 */
    @Transactional
    public void recordRecipientCount(UUID pushSendHistoryUuid, int recipientCount) {
        findHistory(pushSendHistoryUuid).recordRecipientCount(recipientCount);
    }

    /** 푸시 전달 결과 기록 */
    @Transactional
    public void recordDeliveryResult(UUID pushSendHistoryUuid, PushSendResult result) {
        findHistory(pushSendHistoryUuid).recordDeliveryResult(
                result.targetDeviceCount(), result.successCount(), result.failureCount(), result.removedTokenCount());
        log.info("[push send] delivered : history={}, devices={}, success={}, failure={}, removed={}",
                pushSendHistoryUuid, result.targetDeviceCount(), result.successCount(),
                result.failureCount(), result.removedTokenCount());
    }

    /** 회수 표시 (이미 회수한 발송은 PUSH_ALREADY_RETRACTED) > 이력 */
    @Transactional
    public PushSendHistory markRetracted(UUID pushSendHistoryUuid, String retractedByAdmin) {
        PushSendHistory history = findHistory(pushSendHistoryUuid);
        if (history.getIsRetracted()) {
            throw new CustomException(ErrorCode.PUSH_ALREADY_RETRACTED);
        }
        history.retract(retractedByAdmin);
        return history;
    }

    public PushSendHistory findHistory(UUID pushSendHistoryUuid) {
        return pushSendHistoryRepository.findById(pushSendHistoryUuid)
                .orElseThrow(() -> new CustomException(ErrorCode.PUSH_SEND_HISTORY_NOT_FOUND));
    }

    /** 발송 이력 (최신순) */
    public Page<PushSendHistory> getSendHistories(Pageable pageable) {
        return pushSendHistoryRepository.findAllByOrderBySentAtDesc(pageable);
    }

    /** 전체 발송 시 대상 기기 수 (수신 동의) */
    public long countPushEnabledDevices() {
        return memberPushTokenRepository.countByIsPushEnabledTrue();
    }

    /** 알림함 전체 발송 대상 회원 수 (탈퇴 제외) */
    public long countAllInboxRecipients() {
        return memberRepository.countByIsDeletedFalseAndStatusNot(MemberStatus.WITHDRAWN);
    }

    /** 회원의 푸시 기기 현황 (등록 수, 수신 동의 수) */
    public PushDeviceSummary summarizeDevices(UUID memberUuid) {
        List<MemberPushToken> pushTokens = memberPushTokenRepository.findAllByMemberUuid(memberUuid);
        long pushEnabledCount = pushTokens.stream().filter(MemberPushToken::getIsPushEnabled).count();
        return new PushDeviceSummary(pushTokens.size(), pushEnabledCount);
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
