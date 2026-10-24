package com.passql.member.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

/**
 * 발송 이력 검색 조건 (모두 선택): keyword 는 제목·본문 부분 일치
 * audience·dispatchStatus 는 enum 이름, 기간은 발송(예약) 시각 기준 양 끝 포함
 */
@Getter
@Setter
public class PushHistorySearchCondition {
    private String keyword;
    private String audience;
    private String dispatchStatus;
    private LocalDate fromDate;
    private LocalDate toDate;
    private Boolean isTestIncluded;
}
