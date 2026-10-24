package com.passql.application.monitor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

/**
 * 모니터링 화면 필터: 기간(시간), SQL 실행 상태, 서버 오류 URI 키워드
 * 허용 밖 값은 기본값으로 보정 (기간 24시간, 상태·URI 전체)
 */
public record MonitorFilter(int hours, String executionStatus, String uriKeyword) {

    // 선택 가능한 기간 (시간)
    public static final List<Integer> SELECTABLE_HOURS = List.of(1, 6, 24, 72, 168);
    public static final int DEFAULT_HOURS = 24;
    // execution_log.status 값 (빈 값 = 전체)
    public static final List<String> SELECTABLE_EXECUTION_STATUSES = List.of("OK", "ERROR", "TIMEOUT");
    private static final Set<String> EXECUTION_STATUS_SET = Set.copyOf(SELECTABLE_EXECUTION_STATUSES);
    // URI 키워드 최대 길이 (문자)
    private static final int MAX_URI_KEYWORD_LENGTH = 100;

    /** 요청값 > 보정된 필터 */
    public static MonitorFilter of(Integer requestedHours, String requestedExecutionStatus, String requestedUriKeyword) {
        int hours = requestedHours != null && SELECTABLE_HOURS.contains(requestedHours) ? requestedHours : DEFAULT_HOURS;
        String executionStatus = requestedExecutionStatus != null && EXECUTION_STATUS_SET.contains(requestedExecutionStatus.trim())
                ? requestedExecutionStatus.trim() : "";
        String uriKeyword = requestedUriKeyword == null ? "" : requestedUriKeyword.trim();
        if (uriKeyword.length() > MAX_URI_KEYWORD_LENGTH) {
            uriKeyword = uriKeyword.substring(0, MAX_URI_KEYWORD_LENGTH);
        }
        return new MonitorFilter(hours, executionStatus, uriKeyword);
    }

    /** 조회 시작 시각 (지금 - hours) */
    public LocalDateTime getSince() {
        return LocalDateTime.now().minusHours(hours);
    }
}
