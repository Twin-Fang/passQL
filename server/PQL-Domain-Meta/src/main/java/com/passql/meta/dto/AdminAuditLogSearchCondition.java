package com.passql.meta.dto;

import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

/**
 * 감사 로그 화면 필터: 관리자 아이디(일치), 대상 종류, 기간(날짜, 양끝 포함) — 빈 값은 조건 없음
 */
@Getter
@Setter
public class AdminAuditLogSearchCondition {

    private String adminUsername;

    // AdminAuditTargetType 이름
    private String targetType;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate fromDate;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate toDate;
}
