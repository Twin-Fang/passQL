package com.passql.question.dto;

import java.util.List;
import java.util.UUID;

/** 선택지 세트 일괄 처리 요청 (일괄 비활성화·재사용 풀 승격 공통) */
public record AdminChoiceSetBulkRequest(List<UUID> choiceSetUuids) {}
