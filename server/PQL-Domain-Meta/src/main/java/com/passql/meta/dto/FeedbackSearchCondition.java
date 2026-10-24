package com.passql.meta.dto;

import com.passql.meta.constant.FeedbackStatus;
import lombok.Getter;
import lombok.Setter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

/** 관리자 건의 검색 조건: 상태, 내용 키워드, 회원(UUID 또는 닉네임), 제출 기간 (비면 조건 없음) */
@Getter
@Setter
public class FeedbackSearchCondition {

    private FeedbackStatus status;
    private String keyword;
    private String member;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate fromDate;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate toDate;
}
