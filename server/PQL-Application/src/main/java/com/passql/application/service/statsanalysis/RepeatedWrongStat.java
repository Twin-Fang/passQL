package com.passql.application.service.statsanalysis;

/**
 * 반복 오답 집계 (최근 90일, 같은 문제 2번 이상 오답, 활성 문제만)
 * dominantTopicName 은 절반 넘게 한 토픽에 몰렸을 때만 (전체 표시 이름), 아니면 null
 */
public record RepeatedWrongStat(int questionCount, int unresolvedCount, String dominantTopicName) {

    public static final RepeatedWrongStat EMPTY = new RepeatedWrongStat(0, 0, null);
}
