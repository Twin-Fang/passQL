package com.passql.application.billing;

import com.passql.common.util.ServiceTimeZone;
import com.passql.member.constant.AppStoreNotificationResult;
import com.passql.member.constant.PurchaseStatus;
import com.passql.member.constant.PurchaseStore;
import com.passql.member.entity.EntitlementPurchase;
import com.passql.member.repository.EntitlementPurchaseRepository;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Optional;

/**
 * App Store 환불 요청(CONSUMPTION_REQUEST) 응답 (#1032): 접수 기록 > 설정·키 있으면 소비 정보 보냄
 * 소비 정보: 지급 여부(VERIFIED), 무료 체험 제공(무료 하루 크레딧), 이용 기간 경과 비율, 고객 동의 = 자동 응답 설정
 * 자동 응답은 기본 꺼짐 (Apple 규정: 고객 동의를 받은 경우에만 보냄)
 */
@Slf4j
@Component
public class AppStoreConsumptionResponder {

    // 소비 비율 최대값 (Apple consumptionPercentage 밀리 단위 100%)
    static final int MAXIMUM_CONSUMPTION_MILLIUNITS = 100_000;
    // 무료 사용자도 하루 크레딧으로 기능을 써 볼 수 있음 (sampleContentProvided)
    private static final boolean IS_SAMPLE_CONTENT_PROVIDED = true;

    private final AppStoreServerApiClient appStoreServerApiClient;
    private final EntitlementPurchaseRepository entitlementPurchaseRepository;
    private final AppSettingService appSettingService;
    private final Clock clock;

    @Autowired
    public AppStoreConsumptionResponder(AppStoreServerApiClient appStoreServerApiClient,
                                        EntitlementPurchaseRepository entitlementPurchaseRepository,
                                        AppSettingService appSettingService) {
        this.appStoreServerApiClient = appStoreServerApiClient;
        this.entitlementPurchaseRepository = entitlementPurchaseRepository;
        this.appSettingService = appSettingService;
        this.clock = Clock.system(ServiceTimeZone.ZONE);
    }

    /** 환불 요청 1건: 접수 로그 > (설정 켜짐·키 있음·거래 있음) 소비 정보 보냄 > 결과 */
    public AppStoreNotificationResult respond(AppStoreTransaction transaction) {
        String transactionId = transaction == null ? null : transaction.transactionId();
        log.info("[billing] app store refund requested : transaction={}", transactionId);
        if (transaction == null || !isAutoResponseEnabled() || !appStoreServerApiClient.isConfigured()) {
            return AppStoreNotificationResult.REFUND_REQUESTED;
        }
        Optional<EntitlementPurchase> purchase = entitlementPurchaseRepository.findByOrderId(transactionId)
            .filter(foundPurchase -> foundPurchase.getStore() == PurchaseStore.APP_STORE);
        try {
            appStoreServerApiClient.sendConsumptionInformation(transactionId, transaction.environment(),
                buildConsumptionInformation(purchase, LocalDateTime.now(clock)));
            log.info("[billing] app store consumption sent : transaction={}", transactionId);
            return AppStoreNotificationResult.CONSUMPTION_SENT;
        } catch (RuntimeException exception) {
            log.warn("[billing] app store consumption failed : transaction={}, cause={}",
                transactionId, exception.getClass().getSimpleName());
            return AppStoreNotificationResult.CONSUMPTION_FAILED;
        }
    }

    /** 구매 기록 > 소비 정보 (기록 없음 > 미지급·비율 모름, 비율 = 구매 후 경과 / 이용 일수) */
    static AppStoreConsumptionInformation buildConsumptionInformation(Optional<EntitlementPurchase> purchase,
                                                                      LocalDateTime now) {
        boolean isDelivered = purchase.map(foundPurchase -> foundPurchase.getStatus() == PurchaseStatus.VERIFIED)
            .orElse(false);
        Integer consumptionMilliunits = purchase
            .filter(foundPurchase -> foundPurchase.getGrantedDays() != null && foundPurchase.getGrantedDays() > 0)
            .map(foundPurchase -> toConsumptionMilliunits(foundPurchase, now))
            .orElse(null);
        return new AppStoreConsumptionInformation(true, isDelivered, IS_SAMPLE_CONTENT_PROVIDED, consumptionMilliunits);
    }

    private static int toConsumptionMilliunits(EntitlementPurchase purchase, LocalDateTime now) {
        long elapsedSeconds = Math.max(0, Duration.between(purchase.getPurchasedAt(), now).getSeconds());
        long periodSeconds = Duration.ofDays(purchase.getGrantedDays()).getSeconds();
        return (int) Math.min(MAXIMUM_CONSUMPTION_MILLIUNITS, elapsedSeconds * MAXIMUM_CONSUMPTION_MILLIUNITS / periodSeconds);
    }

    private boolean isAutoResponseEnabled() {
        return appSettingService.getBooleanOrDefault(AppSettingKeys.BILLING_APP_STORE_CONSUMPTION_RESPONSE_ENABLED, false);
    }
}
