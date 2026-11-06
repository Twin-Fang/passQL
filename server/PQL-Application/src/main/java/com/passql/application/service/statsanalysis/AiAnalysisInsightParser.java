package com.passql.application.service.statsanalysis;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * LLM 출력 {"insights":[{"topicUuid","text"}]} > 토픽별 한 문장 (#861)
 * 방어 처리 5개: 코드 펜스 제거, 모르는 토픽 무시, 첫 문장만, 70자 자르기, 해요체("요")로 끝나지 않으면 버림
 * 해석 실패는 예외 그대로 > 호출부가 insight 없이 응답
 */
public final class AiAnalysisInsightParser {

    // 한 문장 최대 길이 (문자 수, 화면 두 줄 이내)
    static final int MAX_INSIGHT_LENGTH = 70;

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    // ```json ... ``` 감싼 출력에서 본문만
    private static final Pattern CODE_FENCE_PATTERN = Pattern.compile("^```[a-zA-Z]*\\s*(.*?)\\s*```$", Pattern.DOTALL);
    // 첫 문장: 마침표·느낌표·물음표 뒤 공백 또는 끝
    private static final Pattern FIRST_SENTENCE_PATTERN = Pattern.compile("^(.+?[.!?])(?:\\s|$)", Pattern.DOTALL);
    // 끝 문장부호 (요 판정 전 제거)
    private static final Pattern TRAILING_PUNCTUATION_PATTERN = Pattern.compile("[.!?。]+$");
    // "요"로 끝나지만 해요체가 아닌 명사 끝맺음 ("복습 필요." 같은 메모체)
    private static final List<String> NOUN_ENDINGS_WITH_YO = List.of("필요", "중요", "주요", "개요", "수요");

    private AiAnalysisInsightParser() {
    }

    /** LLM 원문 > 집중 토픽별 문장 (없는 토픽·버린 문장은 빠짐) */
    public static Map<UUID, String> parse(String rawOutput, Set<UUID> focusTopicUuids) throws Exception {
        JsonNode insights = OBJECT_MAPPER.readTree(stripCodeFence(rawOutput)).path("insights");
        Map<UUID, String> insightByTopicUuid = new LinkedHashMap<>();
        if (!insights.isArray()) {
            return insightByTopicUuid;
        }
        for (JsonNode insight : insights) {
            UUID topicUuid = toUuidOrNull(insight.path("topicUuid").asText(null));
            if (topicUuid == null || !focusTopicUuids.contains(topicUuid) || insightByTopicUuid.containsKey(topicUuid)) {
                continue;
            }
            JsonNode textNode = insight.path("text");
            String sentence = textNode.isTextual() ? toValidSentence(textNode.asText()) : null;
            if (sentence != null) {
                insightByTopicUuid.put(topicUuid, sentence);
            }
        }
        return insightByTopicUuid;
    }

    static String stripCodeFence(String rawOutput) {
        String trimmed = rawOutput == null ? "" : rawOutput.trim();
        Matcher fenceMatcher = CODE_FENCE_PATTERN.matcher(trimmed);
        return fenceMatcher.matches() ? fenceMatcher.group(1) : trimmed;
    }

    /** 첫 문장 > 70자 자르기 > "요"로 끝나는지 (아니면 null) */
    static String toValidSentence(String text) {
        String singleLine = text.replaceAll("\\s+", " ").trim();
        if (singleLine.isEmpty()) {
            return null;
        }
        Matcher sentenceMatcher = FIRST_SENTENCE_PATTERN.matcher(singleLine);
        String firstSentence = sentenceMatcher.find() ? sentenceMatcher.group(1).trim() : singleLine;
        String trimmedSentence = firstSentence.length() > MAX_INSIGHT_LENGTH
                ? firstSentence.substring(0, MAX_INSIGHT_LENGTH).trim()
                : firstSentence;
        return isPoliteEnding(trimmedSentence) ? trimmedSentence : null;
    }

    /** 해요체 끝맺음 (끝 문장부호 제외, 명사 "필요"·"중요" 등은 제외) */
    static boolean isPoliteEnding(String sentence) {
        String withoutPunctuation = TRAILING_PUNCTUATION_PATTERN.matcher(sentence).replaceAll("");
        return withoutPunctuation.endsWith("요") && NOUN_ENDINGS_WITH_YO.stream().noneMatch(withoutPunctuation::endsWith);
    }

    private static UUID toUuidOrNull(String value) {
        if (value == null) {
            return null;
        }
        try {
            return UUID.fromString(value.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
