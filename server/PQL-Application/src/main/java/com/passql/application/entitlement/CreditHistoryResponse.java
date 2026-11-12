package com.passql.application.entitlement;

import java.util.List;

/**
 * 크레딧 사용 내역 응답 (#974)
 *
 * @param days 날짜별 내역, 오늘 먼저 (받은 보너스도 쓴 것도 없는 지난 날짜는 빠짐, 결제 꺼짐·프로면 빈 목록)
 */
public record CreditHistoryResponse(
    List<CreditHistoryDayResponse> days
) {
}
