package com.passql.question.event;

import java.util.UUID;

/**
 * 검증을 통과해 풀이에 쓸 수 있는 선택지 세트가 저장됨 > 선택지별 AI 해설 미리 생성 (#496)
 * 샌드박스 미검증(AI 판단 fallback) 세트는 발행하지 않는다.
 */
public record ChoiceSetReadyEvent(UUID choiceSetUuid) {}
