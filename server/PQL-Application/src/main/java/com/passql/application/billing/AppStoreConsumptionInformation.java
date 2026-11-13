package com.passql.application.billing;

/**
 * 환불 요청 소비 정보 1건 (Apple ConsumptionRequest 와 분리, #1032)
 *
 * @param isCustomerConsented               고객이 소비 정보 제공에 동의 (false 면 Apple 규정상 보내지 않음)
 * @param isDelivered                       이용권이 정상 지급됨 (구매 기록 VERIFIED)
 * @param isSampleContentProvided           구매 전 무료 체험 제공 (무료 하루 크레딧)
 * @param consumptionPercentageMilliunits   이용 기간 경과 비율 (밀리 단위 0 ~ 100,000, 모르면 null)
 */
public record AppStoreConsumptionInformation(boolean isCustomerConsented, boolean isDelivered,
                                             boolean isSampleContentProvided,
                                             Integer consumptionPercentageMilliunits) {
}
