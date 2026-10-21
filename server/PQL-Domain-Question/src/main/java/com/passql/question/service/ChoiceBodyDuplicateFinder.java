package com.passql.question.service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 보기 본문 중복 판별 (#555): 같은 결과 표·같은 SQL 보기가 두 개면 사실상 3지선다가 되는 것 방지
 * 비교 기준: 결과 JSON([...]·{...})은 공백 전부 제거, 그 외는 연속 공백을 하나로 + 앞뒤 공백 제거
 */
public final class ChoiceBodyDuplicateFinder {

    private ChoiceBodyDuplicateFinder() {
    }

    /** 보기 본문 목록 > 처음 중복된 본문 (없으면 null) */
    public static String findDuplicateBody(List<String> bodies) {
        Set<String> normalizedBodies = new HashSet<>();
        for (String body : bodies) {
            if (body == null || body.isBlank()) {
                continue;
            }
            if (!normalizedBodies.add(toComparableBody(body))) {
                return body;
            }
        }
        return null;
    }

    // 결과 JSON 은 들여쓰기 차이만 있는 같은 표, SQL·글은 줄바꿈 차이만 있는 같은 보기를 같게 본다
    private static String toComparableBody(String body) {
        String trimmed = body.trim();
        boolean isJsonBody = trimmed.startsWith("[") || trimmed.startsWith("{");
        return isJsonBody ? trimmed.replaceAll("\\s+", "") : trimmed.replaceAll("\\s+", " ");
    }
}
