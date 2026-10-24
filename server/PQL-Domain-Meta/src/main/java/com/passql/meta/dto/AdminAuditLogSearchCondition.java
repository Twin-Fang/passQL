package com.passql.meta.dto;

import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

/**
 * 감사 로그 화면 필터: 관리자 아이디(부분 일치), 동작, 대상 종류, 대상 ID(부분 일치), 키워드(대상 ID·변경 내용), 기간(날짜, 양끝 포함) — 빈 값은 조건 없음
 */
@Getter
@Setter
public class AdminAuditLogSearchCondition {

    private String adminUsername;

    // AdminAuditAction 이름
    private String action;

    // 대상 ID 부분 일치 (UUID·설정 키·토픽 코드)
    private String targetId;

    // 대상 ID 또는 변경 내용(JSON) 부분 일치
    private String keyword;

    // AdminAuditTargetType 이름
    private String targetType;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate fromDate;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate toDate;
}
