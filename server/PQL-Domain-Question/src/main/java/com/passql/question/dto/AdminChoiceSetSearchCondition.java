package com.passql.question.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

/**
 * 관리자 선택지 세트 목록 필터: 출처(ChoiceSetSource 이름), 상태(ChoiceSetStatus 이름), 문제 uuid (모두 비면 전체)
 */
@Getter
@Setter
public class AdminChoiceSetSearchCondition {

    private String source;
    private String status;
    private UUID questionUuid;
}
