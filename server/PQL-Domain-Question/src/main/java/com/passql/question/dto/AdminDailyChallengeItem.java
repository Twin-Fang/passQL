package com.passql.question.dto;

import java.time.LocalDate;
import java.util.UUID;

/**
 * 관리자 일일 챌린지 배정 1건: 날짜, 순서, 문제 요약, 문제 활성 여부(비활성·삭제 문제 경고용)
 * 삭제된 문제는 isActive=false, stemPreview="(삭제된 문제)"
 */
public record AdminDailyChallengeItem(
        LocalDate challengeDate,
        int sortOrder,
        UUID questionUuid,
        String topicName,
        Integer difficulty,
        String stemPreview,
        Boolean isActive
) {}
