package com.passql.application.concept.admin;

import com.passql.application.concept.admin.dto.ConceptBundle;
import com.passql.application.concept.admin.dto.ConceptBundleCheckQuestion;
import com.passql.application.concept.admin.dto.ConceptBundleChoice;
import com.passql.application.concept.admin.dto.ConceptBundleItem;

import java.util.ArrayList;
import java.util.List;

/**
 * 묶음 가져오기 테스트 데이터: 검증을 통과하는 개념 1개(확인 문제 5개, 보기 4개, 정답 B)
 */
final class ConceptBundleFixtures {

    static final String DETAIL_MD = "## 왜 필요한가요 {#why}\n가\n## 자주 헷갈리는 점 {#confusing}\n나";

    private ConceptBundleFixtures() {
    }

    static ConceptBundle bundleOf(ConceptBundleItem... items) {
        return new ConceptBundle(List.of(items));
    }

    static ConceptBundleItem validItem(String tagKey) {
        return itemWith(tagKey, checkQuestions(5, "confusing"));
    }

    static ConceptBundleItem itemWith(String tagKey, List<ConceptBundleCheckQuestion> checkQuestions) {
        return new ConceptBundleItem(tagKey, "SELECT_BASIC", 1, "WHERE 절과 NULL", "NULL 비교는 IS NULL",
            "핵심만", DETAIL_MD, checkQuestions, List.of());
    }

    static List<ConceptBundleCheckQuestion> checkQuestions(int count, String rereadAnchor) {
        List<ConceptBundleCheckQuestion> questions = new ArrayList<>();
        for (int order = 1; order <= count; order++) {
            questions.add(new ConceptBundleCheckQuestion(order, "문제 " + order, null, "풀이", rereadAnchor, choices("B")));
        }
        return questions;
    }

    static List<ConceptBundleChoice> choices(String... correctKeys) {
        List<String> correct = List.of(correctKeys);
        return List.of("A", "B", "C", "D").stream()
            .map(key -> new ConceptBundleChoice(key, "보기 " + key, correct.contains(key), "근거 " + key))
            .toList();
    }
}
