package com.passql.question.service;

import com.passql.question.constant.ExplanationOutlineSectionKind;
import com.passql.question.dto.explanation.ChoiceAnalysis;
import com.passql.question.dto.explanation.ChoiceExplanation;
import com.passql.question.dto.explanation.ExplanationOutline;
import com.passql.question.dto.explanation.ExplanationOutlineSection;
import com.passql.question.dto.explanation.KeyConcept;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.function.Function;

/**
 * 구조화 해설 > 잠금 표시용 구성 (#999): 섹션 종류·항목별 대략 글자 수만, 본문 없음
 * 해설 생성 전이면 기본 구성 (보기 수만큼 보기별 판단 + 핵심 개념 + 시험 팁, 평균 길이)
 */
public final class ExplanationOutlineBuilder {

    // 글자 수 반올림 단위 (정확한 길이로 내용을 짐작하지 못하게 10자 단위 올림)
    private static final int CHARACTER_COUNT_STEP = 10;

    // 기본 구성 평균 길이 (글자 수): 시험 팁, 핵심 개념 1개 설명, 보기별 판단 1개
    private static final int DEFAULT_EXAM_TIP_CHARACTER_COUNT = 50;
    private static final int DEFAULT_KEY_CONCEPT_CHARACTER_COUNT = 70;
    private static final int DEFAULT_KEY_CONCEPT_COUNT = 2;
    private static final int DEFAULT_CHOICE_ANALYSIS_CHARACTER_COUNT = 50;

    private ExplanationOutlineBuilder() {
    }

    /** 구조화 해설 있으면 그 구성, 없으면 기본 구성 */
    public static ExplanationOutline buildOrDefault(ChoiceExplanation explanation, int choiceCount) {
        if (explanation == null) {
            return buildDefault(choiceCount);
        }
        List<ExplanationOutlineSection> sections = new ArrayList<>();
        addSectionIfPresent(sections, ExplanationOutlineSectionKind.CORRECT_REASON, singletonOrEmpty(explanation.correctReason()), Function.identity());
        addSectionIfPresent(sections, ExplanationOutlineSectionKind.EXAM_TIP, singletonOrEmpty(explanation.examTip()), Function.identity());
        addSectionIfPresent(sections, ExplanationOutlineSectionKind.KEY_CONCEPTS, explanation.keyConcepts(), KeyConcept::description);
        addSectionIfPresent(sections, ExplanationOutlineSectionKind.CONFUSING_POINTS, explanation.confusingPoints(), Function.identity());
        addSectionIfPresent(sections, ExplanationOutlineSectionKind.CHOICE_ANALYSES, explanation.choiceAnalyses(), ChoiceAnalysis::reason);
        // 생성 결과가 비어 있으면 빈 화면 대신 기본 구성
        if (sections.isEmpty()) {
            return buildDefault(choiceCount);
        }
        return new ExplanationOutline(choiceCount, sections);
    }

    /** 기본 구성: 시험 팁 > 핵심 개념 2개 > 보기 수만큼 보기별 판단 */
    public static ExplanationOutline buildDefault(int choiceCount) {
        return new ExplanationOutline(choiceCount, List.of(
            new ExplanationOutlineSection(ExplanationOutlineSectionKind.EXAM_TIP, List.of(DEFAULT_EXAM_TIP_CHARACTER_COUNT)),
            new ExplanationOutlineSection(ExplanationOutlineSectionKind.KEY_CONCEPTS,
                Collections.nCopies(DEFAULT_KEY_CONCEPT_COUNT, DEFAULT_KEY_CONCEPT_CHARACTER_COUNT)),
            new ExplanationOutlineSection(ExplanationOutlineSectionKind.CHOICE_ANALYSES,
                Collections.nCopies(Math.max(choiceCount, 0), DEFAULT_CHOICE_ANALYSIS_CHARACTER_COUNT))));
    }

    /** 항목 글이 있는 것만 글자 수로 > 하나라도 있으면 섹션 추가 */
    private static <T> void addSectionIfPresent(List<ExplanationOutlineSection> sections, ExplanationOutlineSectionKind kind,
                                                List<T> items, Function<T, String> textOf) {
        if (items == null) return;
        List<Integer> characterCounts = items.stream()
            .map(item -> item == null ? null : textOf.apply(item))
            .filter(text -> text != null && !text.isBlank())
            .map(text -> roundUpCharacterCount(text.strip().length()))
            .toList();
        if (!characterCounts.isEmpty()) {
            sections.add(new ExplanationOutlineSection(kind, characterCounts));
        }
    }

    private static List<String> singletonOrEmpty(String text) {
        return text == null ? List.of() : List.of(text);
    }

    /** 글자 수 > 10자 단위 올림 (최소 10) */
    static int roundUpCharacterCount(int characterCount) {
        int steps = Math.max(1, (characterCount + CHARACTER_COUNT_STEP - 1) / CHARACTER_COUNT_STEP);
        return steps * CHARACTER_COUNT_STEP;
    }
}
