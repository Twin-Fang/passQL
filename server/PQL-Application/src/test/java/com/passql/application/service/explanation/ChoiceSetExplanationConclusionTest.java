package com.passql.application.service.explanation;

import com.passql.question.dto.explanation.ChoiceAnalysis;
import com.passql.question.dto.explanation.ChoiceSetExplanation;
import com.passql.question.dto.explanation.KeyConcept;
import com.passql.question.entity.QuestionChoiceSetItem;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 해설 결론 검증 (#716): 운영에서 저장된 CTAS 문제 해설(정답 4, 결론 없음)이 거부되는지
 */
class ChoiceSetExplanationConclusionTest {

    // 정답 C = "4" 인 개수 문제 보기
    private static final List<QuestionChoiceSetItem> COUNT_QUESTION_ITEMS = List.of(
            item("A", "2", false), item("B", "3", false), item("C", "4", true), item("D", "5", false));

    @Test
    void 결론_미룬_정답근거_거부() {
        String unresolvedReason = "1번·2번·5번 중 2번은 ORD_ID 가 NULL 이 아니므로 성공 조건 확인이 필요하다. 4번은 ST NULL 로 실패한다.";
        List<String> violations = ChoiceSetExplanationValidator.validate(explanation(unresolvedReason), COUNT_QUESTION_ITEMS).violations();

        assertTrue(violations.stream().anyMatch(violation -> violation.contains("결론을 미루는 표현")));
        // "4번" 순번 언급은 정답 값 4 로 치지 않음
        assertTrue(violations.stream().anyMatch(violation -> violation.contains("정답 값 4 없음")));
    }

    @Test
    void 합계로_끝난_정답근거_통과() {
        String resolvedReason = "CTAS 는 NOT NULL 만 복제한다. 복사된 1행에 1·2·5번째 INSERT 3건이 성공해 총 4행이다.";
        assertFalse(ChoiceSetExplanationValidator.validate(explanation(resolvedReason), COUNT_QUESTION_ITEMS).violations()
                .stream().anyMatch(violation -> violation.contains("결론") || violation.contains("정답 값")));
    }

    @Test
    void 입력자료_언급_거부() {
        // 운영 저장본 (집합 연산 우선순위를 잘못 풀고 정답 표시와 다르다고 적은 해설)
        String metaTalkReason = "결과는 2, 5, 1, 2 이다. 입력 표시 정답 2행과 직접 계산 4행이 다르므로 계산 결과를 그대로 적는다.";
        assertTrue(ChoiceSetExplanationValidator.validate(explanation(metaTalkReason), COUNT_QUESTION_ITEMS).violations()
                .stream().anyMatch(violation -> violation.contains("입력 자료·작성 과정 언급")));
    }

    private static ChoiceSetExplanation explanation(String correctReason) {
        return new ChoiceSetExplanation("C", correctReason,
                List.of(new KeyConcept("CTAS 제약 복제", "NOT NULL 만 복제")),
                List.of("PK 의 NOT NULL 은 복제 안 됨"),
                List.of(new ChoiceAnalysis("A", false, "DEFAULT 복제 가정"), new ChoiceAnalysis("B", false, "PK NOT NULL 유지 가정"),
                        new ChoiceAnalysis("C", true, "1행 + 성공 3건 = 4"), new ChoiceAnalysis("D", false, "DEFAULT 복제 가정")),
                "CTAS 는 NOT NULL 만 복제");
    }

    private static QuestionChoiceSetItem item(String choiceKey, String body, boolean isCorrect) {
        return QuestionChoiceSetItem.builder().choiceKey(choiceKey).body(body).isCorrect(isCorrect).build();
    }
}
