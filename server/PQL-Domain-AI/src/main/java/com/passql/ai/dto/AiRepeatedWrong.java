package com.passql.ai.dto;

/**
 * 반복 오답 (#862): 최근 90일 같은 문제를 2번 이상 틀린 문제 수와 그중 마지막 시도도 오답인 문제 수
 * text 는 서버 문구 (예: "4문제를 2번 이상 틀렸고, 3문제는 아직 못 맞혔어요")
 */
public record AiRepeatedWrong(int questionCount, int unresolvedCount, String text) {}
