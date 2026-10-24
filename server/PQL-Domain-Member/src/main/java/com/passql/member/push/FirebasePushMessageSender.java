package com.passql.member.push;

import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.AndroidNotification;
import com.google.firebase.messaging.ApnsConfig;
import com.google.firebase.messaging.Aps;
import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.MessagingErrorCode;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.google.firebase.messaging.SendResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;

/**
 * FCM 일괄 발송(sendEach): 500개 단위 분할 > 토큰별 결과 변환 (만료 토큰 표시)
 * 묶음 전체 실패는 그 묶음 토큰을 실패로 기록하고 다음 묶음 계속
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class FirebasePushMessageSender implements PushMessageSender {

    // FCM sendEach 1회 최대 메시지 수
    private static final int MAX_TOKENS_PER_BATCH = 500;
    // 만료 토큰 판정 오류 2종: 앱 삭제·토큰 폐기, 다른 Firebase 프로젝트 토큰
    private static final Set<MessagingErrorCode> EXPIRED_TOKEN_ERROR_CODES =
            EnumSet.of(MessagingErrorCode.UNREGISTERED, MessagingErrorCode.SENDER_ID_MISMATCH);
    // iOS 알림 소리
    private static final String DEFAULT_SOUND = "default";

    private final FirebaseMessaging firebaseMessaging;

    @Override
    public List<PushDeliveryResult> send(PushMessage message, List<PushTarget> targets) {
        List<PushDeliveryResult> results = new ArrayList<>(targets.size());
        for (int start = 0; start < targets.size(); start += MAX_TOKENS_PER_BATCH) {
            List<PushTarget> targetChunk = targets.subList(start, Math.min(start + MAX_TOKENS_PER_BATCH, targets.size()));
            results.addAll(sendChunk(message, targetChunk));
        }
        return results;
    }

    /** 묶음 1회 발송 > 토큰별 결과 (응답 순서 = 대상 순서) */
    private List<PushDeliveryResult> sendChunk(PushMessage message, List<PushTarget> targetChunk) {
        try {
            BatchResponse batchResponse = firebaseMessaging.sendEach(
                    targetChunk.stream().map(target -> toTokenMessage(message, target)).toList());
            List<SendResponse> responses = batchResponse.getResponses();
            List<PushDeliveryResult> results = new ArrayList<>(targetChunk.size());
            for (int index = 0; index < targetChunk.size(); index++) {
                results.add(toDeliveryResult(targetChunk.get(index).token(), responses.get(index)));
            }
            return results;
        } catch (FirebaseMessagingException e) {
            log.error("[push send] batch failed : {} tokens, code={}", targetChunk.size(), e.getMessagingErrorCode(), e);
            String failureReason = e.getMessagingErrorCode() == null
                    ? PushDeliveryResult.UNKNOWN_FAILURE_REASON : e.getMessagingErrorCode().name();
            return targetChunk.stream().map(target -> PushDeliveryResult.failed(target.token(), false, failureReason)).toList();
        }
    }

    private PushDeliveryResult toDeliveryResult(String token, SendResponse response) {
        if (response.isSuccessful()) {
            return PushDeliveryResult.delivered(token);
        }
        MessagingErrorCode errorCode = response.getException() == null ? null : response.getException().getMessagingErrorCode();
        String failureReason = errorCode == null ? PushDeliveryResult.UNKNOWN_FAILURE_REASON : errorCode.name();
        return PushDeliveryResult.failed(token, errorCode != null && EXPIRED_TOKEN_ERROR_CODES.contains(errorCode), failureReason);
    }

    /** 알림(제목·본문) + 이동 데이터 + 플랫폼 설정 (Android 채널·우선순위, iOS 소리·앱 아이콘 숫자) */
    // setToken 은 FID 대상 지정으로 대체 예정(deprecated)이나 앱 SDK 가 등록 토큰만 제공
    @SuppressWarnings("deprecation")
    private Message toTokenMessage(PushMessage message, PushTarget target) {
        return Message.builder()
                .setToken(target.token())
                .setNotification(Notification.builder()
                        .setTitle(message.title())
                        .setBody(message.body())
                        .build())
                .putAllData(message.data())
                .setAndroidConfig(AndroidConfig.builder()
                        .setPriority(AndroidConfig.Priority.HIGH)
                        .setNotification(AndroidNotification.builder()
                                .setChannelId(PushDataKeys.ANDROID_CHANNEL_ID)
                                .build())
                        .build())
                .setApnsConfig(ApnsConfig.builder()
                        .setAps(Aps.builder().setSound(DEFAULT_SOUND).setBadge(target.badgeCount()).build())
                        .build())
                .build();
    }
}
