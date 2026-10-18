package com.passql.question.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.question.dto.explanation.ChoiceAnalysis;
import com.passql.question.dto.explanation.ChoiceExplanation;
import com.passql.question.dto.explanation.ChoiceSetExplanation;
import com.passql.question.dto.explanation.KeyConcept;
import lombok.extern.slf4j.Slf4j;

import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

/**
 * 구조화 해설 변환 (#521): 저장 JSON <-> ChoiceSetExplanation, 세트 해설 + 고른 보기 > ChoiceExplanation > 마크다운
 * 마크다운은 출시 앱 MarkdownLiteText 가 그리는 표기만 사용 (굵게, 인라인 코드, '- ' 목록)
 */
@Slf4j
public final class ChoiceExplanationComposer {

    // 알 수 없는 필드는 무시 (프롬프트 버전이 바뀌어 필드가 늘어도 옛 서버가 읽을 수 있게)
    private static final ObjectMapper EXPLANATION_JSON_MAPPER = new ObjectMapper()
            .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    private static final String CORRECT_LABEL = "정답";
    private static final String WRONG_LABEL = "오답";

    private ChoiceExplanationComposer() {
    }

    /** 저장 JSON > 세트 해설 (null·빈 값·깨진 JSON > empty) */
    public static Optional<ChoiceSetExplanation> parse(String explanationJson) {
        if (explanationJson == null || explanationJson.isBlank()) return Optional.empty();
        try {
            return Optional.ofNullable(EXPLANATION_JSON_MAPPER.readValue(explanationJson, ChoiceSetExplanation.class));
        } catch (JsonProcessingException e) {
            log.warn("[choice explanation] stored json unreadable : {}", e.getOriginalMessage());
            return Optional.empty();
        }
    }

    /** 세트 해설 > 저장 JSON */
    public static String toJson(ChoiceSetExplanation explanation) {
        try {
            return EXPLANATION_JSON_MAPPER.writeValueAsString(explanation);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("choice set explanation not serializable", e);
        }
    }

    /** 저장 JSON + 고른 보기 > 고른 보기 기준 해설 (저장본 없거나 깨졌으면 null) */
    public static ChoiceExplanation composeOrNull(String explanationJson, String selectedChoiceKey) {
        return parse(explanationJson)
                .map(explanation -> composeForSelectedChoice(explanation, selectedChoiceKey))
                .orElse(null);
    }

    /** 세트 해설 + 고른 보기 > 판정 한 줄 조립, 보기 키 순 정렬 */
    public static ChoiceExplanation composeForSelectedChoice(ChoiceSetExplanation explanation, String selectedChoiceKey) {
        List<ChoiceAnalysis> sortedAnalyses = nullSafe(explanation.choiceAnalyses()).stream()
                .filter(Objects::nonNull)
                .sorted(Comparator.comparing(analysis -> String.valueOf(analysis.choiceKey())))
                .toList();
        boolean isSelectedCorrect = selectedChoiceKey != null && selectedChoiceKey.equals(explanation.correctChoiceKey());
        String selectedReason = sortedAnalyses.stream()
                .filter(analysis -> Objects.equals(analysis.choiceKey(), selectedChoiceKey))
                .map(ChoiceAnalysis::reason)
                .findFirst()
                .orElse(null);
        return new ChoiceExplanation(
                selectedChoiceKey,
                explanation.correctChoiceKey(),
                isSelectedCorrect,
                buildVerdict(isSelectedCorrect, selectedChoiceKey, explanation.correctChoiceKey(), selectedReason),
                explanation.correctReason(),
                nullSafe(explanation.keyConcepts()),
                nullSafe(explanation.confusingPoints()),
                sortedAnalyses,
                explanation.examTip());
    }

    /**
     * 판정 한 줄: 정답 여부는 AI 가 아니라 DB 정답 키로 결정
     * 예: "정답 · DENSE_RANK 는 동점 뒤 순위를 건너뛰지 않음" / "오답 · B 선택, 정답은 A · RANK 기준 순위"
     */
    static String buildVerdict(boolean isSelectedCorrect, String selectedChoiceKey, String correctChoiceKey, String selectedReason) {
        String reasonSuffix = selectedReason == null || selectedReason.isBlank() ? "" : " · " + selectedReason.trim();
        if (isSelectedCorrect) return CORRECT_LABEL + reasonSuffix;
        return WRONG_LABEL + " · " + selectedChoiceKey + " 선택, 정답은 " + correctChoiceKey + reasonSuffix;
    }

    /**
     * 고른 보기 기준 해설 > 마크다운 (구조화 해설을 못 그리는 출시 앱·웹용 text)
     * 순서: 판정 > 정답 근거 > 핵심 개념 > 헷갈리는 지점 > 보기별 판단 > 시험 팁
     */
    public static String toMarkdown(ChoiceExplanation explanation) {
        StringBuilder markdown = new StringBuilder();
        markdown.append("**").append(explanation.verdict()).append("**\n\n");
        markdown.append("**정답 ").append(explanation.correctChoiceKey()).append(" 근거**\n")
                .append(explanation.correctReason()).append("\n\n");
        if (!explanation.keyConcepts().isEmpty()) {
            markdown.append("**핵심 개념**\n");
            for (KeyConcept concept : explanation.keyConcepts()) {
                markdown.append("- **").append(concept.name()).append("**: ").append(concept.description()).append("\n");
            }
            markdown.append("\n");
        }
        if (!explanation.confusingPoints().isEmpty()) {
            markdown.append("**헷갈리는 지점**\n");
            explanation.confusingPoints().forEach(point -> markdown.append("- ").append(point).append("\n"));
            markdown.append("\n");
        }
        if (!explanation.choiceAnalyses().isEmpty()) {
            markdown.append("**보기별 판단**\n");
            for (ChoiceAnalysis analysis : explanation.choiceAnalyses()) {
                // 내 선택 표시 (정답·오답 공통)
                String selectedMark = Objects.equals(analysis.choiceKey(), explanation.selectedChoiceKey()) ? ", 내 선택" : "";
                String correctLabel = Boolean.TRUE.equals(analysis.isCorrect()) ? CORRECT_LABEL : WRONG_LABEL;
                markdown.append("- **").append(analysis.choiceKey()).append("** (").append(correctLabel).append(selectedMark)
                        .append("): ").append(analysis.reason()).append("\n");
            }
            markdown.append("\n");
        }
        if (explanation.examTip() != null && !explanation.examTip().isBlank()) {
            markdown.append("**시험 팁** ").append(explanation.examTip());
        }
        return markdown.toString().trim();
    }

    private static <T> List<T> nullSafe(List<T> values) {
        return values == null ? List.of() : values;
    }
}
