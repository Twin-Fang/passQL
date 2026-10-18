package com.passql.question.dto;

/**
 * 토픽별 최신 경향 문제 수 (토픽 목록 배지·경향 화면 풀기 버튼, #523)
 */
public record LatestTrendTopicCount(
    String topicCode,
    String topicName,
    Integer latestTrendQuestionCount
) {}
