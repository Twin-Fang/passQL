package com.passql.question.dto;

/**
 * 임베딩 관리 화면의 문제 한 줄 요약 (미색인·실패 목록용)
 * topicName: 삭제된 토픽이면 빈 문자열, stemPreview: 삭제된 문제면 "(삭제된 문제)"
 */
public record IndexQuestionPreview(
        String questionUuid,
        String stemPreview,
        String topicName,
        Integer difficulty
) {}
