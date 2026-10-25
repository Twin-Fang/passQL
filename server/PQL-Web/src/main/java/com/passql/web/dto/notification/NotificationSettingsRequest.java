package com.passql.web.dto.notification;

/** 알림 설정 저장 요청: 보관 기간(일), 신고 처리 결과 알림 사용, 오늘의 세트 리마인드 사용 */
public record NotificationSettingsRequest(
        Integer retentionDays,
        Boolean isReportResolvedEnabled
) {
}
