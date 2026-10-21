package com.passql.application.service.explanation;

import com.passql.question.dto.explanation.ChoiceAnalysis;
import com.passql.question.dto.explanation.ChoiceSetExplanation;
import com.passql.question.dto.explanation.KeyConcept;
import com.passql.question.entity.QuestionChoiceSetItem;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * 구조화 해설 검증 (#521): 형식(필수·개수) > 사실(정답 키·보기별 판정 <-> DB 정답) > 길이·문체
 * 형식·사실·길이 상한 1.5배 초과는 위반(저장 거부), 상한 초과·서술 어미·코드 블록은 경고
 * 서버 저장 직전과 하네스가 같은 검증을 쓴다
 */
public final class ChoiceSetExplanationValidator {

    // 필드별 글자 수 상한 (프롬프트 {{...}} 자리에도 같은 값이 들어감)
    public static final int CORRECT_REASON_MAX_LENGTH = 220;
    public static final int CONCEPT_NAME_MAX_LENGTH = 30;
    public static final int CONCEPT_DESCRIPTION_MAX_LENGTH = 120;
    public static final int CONFUSING_POINT_MAX_LENGTH = 120;
    public static final int CHOICE_REASON_MAX_LENGTH = 120;
    public static final int EXAM_TIP_MAX_LENGTH = 80;
    // 상한의 이 배수를 넘으면 경고가 아니라 위반 (화면이 길어져 읽기 어려움)
    private static final double HARD_LENGTH_LIMIT_RATIO = 1.5;
    // 핵심 개념·헷갈리는 지점 개수 범위
    private static final int MIN_LIST_SIZE = 1;
    private static final int MAX_LIST_SIZE = 3;

    // 서술 어미 (명사형 문체 위반): "~습니다", "~해요" 등
    private static final Pattern POLITE_ENDING_PATTERN =
            Pattern.compile("(습니다|입니다|합니다|됩니다|해요|에요|예요|세요)[.!]?(\\s|$)");
    // "정답은 B", "정답: B" 같은 정답 키 언급 (D 뒤 영문이 이어지는 DENSE_RANK 등은 제외)
    private static final Pattern CORRECT_KEY_MENTION_PATTERN =
            Pattern.compile("정답(?:은|는|이|:)?\\s*\\(?([A-D])\\)?(?![A-Za-z_])");
    // 학습자에게 안 보이는 입력 섹션 이름: 해설에 나오면 위반 > 재생성 (#555)
    private static final List<String> INTERNAL_INPUT_LABELS = List.of("기준 SQL", "생성 근거");
    private static final String CODE_FENCE = "```";
    private static final String LATEX_DOLLAR = "$";

    private ChoiceSetExplanationValidator() {
    }

    /** 해설 1건 검증: 형식 > 사실 > 길이·문체 */
    public static ExplanationValidationResult validate(ChoiceSetExplanation explanation, List<QuestionChoiceSetItem> items) {
        List<String> violations = new ArrayList<>();
        List<String> warnings = new ArrayList<>();
        if (explanation == null) {
            return new ExplanationValidationResult(List.of("응답 JSON 없음"), List.of());
        }
        validateRequiredFields(explanation, violations);
        validateFactsAgainstAnswerKey(explanation, items, violations);
        validateLengths(explanation, violations, warnings);
        validateStyle(explanation, warnings);
        validateNoInternalInputLabels(explanation, violations);
        return new ExplanationValidationResult(List.copyOf(violations), List.copyOf(warnings));
    }

    /** 형식: 필수 문자열, 목록 개수(핵심 개념·헷갈리는 지점 1~3, 보기 판정은 빈 값 금지) */
    private static void validateRequiredFields(ChoiceSetExplanation explanation, List<String> violations) {
        requireText(explanation.correctChoiceKey(), "correctChoiceKey", violations);
        requireText(explanation.correctReason(), "correctReason", violations);
        requireText(explanation.examTip(), "examTip", violations);
        requireListSize(explanation.keyConcepts(), "keyConcepts", violations);
        requireListSize(explanation.confusingPoints(), "confusingPoints", violations);
        for (KeyConcept concept : nullSafe(explanation.keyConcepts())) {
            if (concept == null || isBlank(concept.name()) || isBlank(concept.description())) {
                violations.add("keyConcepts 항목에 name/description 빈 값");
            }
        }
        for (ChoiceAnalysis analysis : nullSafe(explanation.choiceAnalyses())) {
            if (analysis == null || isBlank(analysis.choiceKey()) || analysis.isCorrect() == null || isBlank(analysis.reason())) {
                violations.add("choiceAnalyses 항목에 choiceKey/isCorrect/reason 빈 값");
            }
        }
    }

    /** 사실: 정답 키 일치, 보기 판정이 모든 보기를 한 번씩 덮고 정답 여부가 DB 와 같음, 본문의 정답 키 언급 일치 */
    private static void validateFactsAgainstAnswerKey(ChoiceSetExplanation explanation, List<QuestionChoiceSetItem> items,
                                                      List<String> violations) {
        Map<String, Boolean> isCorrectByChoiceKey = items.stream().collect(Collectors.toMap(
                QuestionChoiceSetItem::getChoiceKey, item -> Boolean.TRUE.equals(item.getIsCorrect())));
        String correctChoiceKey = items.stream().filter(item -> Boolean.TRUE.equals(item.getIsCorrect()))
                .map(QuestionChoiceSetItem::getChoiceKey).findFirst().orElse(null);

        if (!Objects.equals(explanation.correctChoiceKey(), correctChoiceKey)) {
            violations.add("correctChoiceKey 불일치: 응답 " + explanation.correctChoiceKey() + ", 정답 " + correctChoiceKey);
        }
        List<ChoiceAnalysis> analyses = nullSafe(explanation.choiceAnalyses()).stream().filter(Objects::nonNull).toList();
        List<String> analyzedKeys = analyses.stream().map(ChoiceAnalysis::choiceKey).toList();
        if (analyzedKeys.size() != items.size() || !Set.copyOf(analyzedKeys).equals(isCorrectByChoiceKey.keySet())) {
            violations.add("choiceAnalyses 보기 키 불일치: 응답 " + analyzedKeys + ", 보기 " + isCorrectByChoiceKey.keySet());
        }
        for (ChoiceAnalysis analysis : analyses) {
            Boolean expectedIsCorrect = isCorrectByChoiceKey.get(analysis.choiceKey());
            if (expectedIsCorrect != null && analysis.isCorrect() != null && !expectedIsCorrect.equals(analysis.isCorrect())) {
                violations.add("choiceAnalyses " + analysis.choiceKey() + " 정답 여부 모순: 응답 " + analysis.isCorrect()
                        + ", 정답 데이터 " + expectedIsCorrect);
            }
        }
        allTexts(explanation).forEach(text -> {
            Matcher matcher = CORRECT_KEY_MENTION_PATTERN.matcher(text);
            while (matcher.find()) {
                if (correctChoiceKey != null && !correctChoiceKey.equals(matcher.group(1))) {
                    violations.add("본문이 다른 보기를 정답으로 언급: '" + matcher.group() + "'");
                }
            }
        });
    }

    /** 길이: 상한 초과 경고, 상한 1.5배 초과 위반 */
    private static void validateLengths(ChoiceSetExplanation explanation, List<String> violations, List<String> warnings) {
        checkLength(explanation.correctReason(), CORRECT_REASON_MAX_LENGTH, "correctReason", violations, warnings);
        checkLength(explanation.examTip(), EXAM_TIP_MAX_LENGTH, "examTip", violations, warnings);
        for (KeyConcept concept : nullSafe(explanation.keyConcepts())) {
            if (concept == null) continue;
            checkLength(concept.name(), CONCEPT_NAME_MAX_LENGTH, "keyConcepts.name", violations, warnings);
            checkLength(concept.description(), CONCEPT_DESCRIPTION_MAX_LENGTH, "keyConcepts.description", violations, warnings);
        }
        nullSafe(explanation.confusingPoints()).forEach(point ->
                checkLength(point, CONFUSING_POINT_MAX_LENGTH, "confusingPoints", violations, warnings));
        for (ChoiceAnalysis analysis : nullSafe(explanation.choiceAnalyses())) {
            if (analysis == null) continue;
            checkLength(analysis.reason(), CHOICE_REASON_MAX_LENGTH, "choiceAnalyses." + analysis.choiceKey(), violations, warnings);
        }
    }

    /** 문체: 서술 어미, 코드 블록, 수식 기호 (경고) */
    private static void validateStyle(ChoiceSetExplanation explanation, List<String> warnings) {
        long politeEndingCount = allTexts(explanation).filter(text -> POLITE_ENDING_PATTERN.matcher(text).find()).count();
        if (politeEndingCount > 0) warnings.add("서술 어미(~습니다/~해요) " + politeEndingCount + "곳");
        if (allTexts(explanation).anyMatch(text -> text.contains(CODE_FENCE))) warnings.add("코드 블록(```) 사용");
        if (allTexts(explanation).anyMatch(text -> text.contains(LATEX_DOLLAR))) warnings.add("수식 기호($) 사용");
    }

    /** 내부 입력 이름 노출 (위반: 학습자는 기준 SQL·생성 근거를 볼 수 없음) */
    private static void validateNoInternalInputLabels(ChoiceSetExplanation explanation, List<String> violations) {
        for (String label : INTERNAL_INPUT_LABELS) {
            if (allTexts(explanation).anyMatch(text -> text.contains(label))) {
                violations.add("학습자에게 보이지 않는 '" + label + "' 언급, 지문·보기·표의 말로만 설명");
            }
        }
    }

    /** 해설의 모든 문장 필드 (빈 값 제외) */
    static Stream<String> allTexts(ChoiceSetExplanation explanation) {
        Stream<String> conceptTexts = nullSafe(explanation.keyConcepts()).stream().filter(Objects::nonNull)
                .flatMap(concept -> Stream.of(concept.name(), concept.description()));
        Stream<String> analysisTexts = nullSafe(explanation.choiceAnalyses()).stream().filter(Objects::nonNull)
                .map(ChoiceAnalysis::reason);
        return Stream.of(
                        Stream.of(explanation.correctReason(), explanation.examTip()),
                        conceptTexts,
                        nullSafe(explanation.confusingPoints()).stream(),
                        analysisTexts)
                .flatMap(stream -> stream)
                .filter(text -> !isBlank(text));
    }

    private static void checkLength(String text, int maxLength, String fieldName, List<String> violations, List<String> warnings) {
        if (text == null) return;
        int length = text.strip().length();
        if (length > maxLength * HARD_LENGTH_LIMIT_RATIO) {
            violations.add(fieldName + " 길이 " + length + "자 (상한 " + maxLength + "자의 1.5배 초과)");
        } else if (length > maxLength) {
            warnings.add(fieldName + " 길이 " + length + "자 (상한 " + maxLength + "자)");
        }
    }

    private static void requireText(String value, String fieldName, List<String> violations) {
        if (isBlank(value)) violations.add(fieldName + " 빈 값");
    }

    private static void requireListSize(List<?> values, String fieldName, List<String> violations) {
        int size = values == null ? 0 : values.size();
        if (size < MIN_LIST_SIZE || size > MAX_LIST_SIZE) {
            violations.add(fieldName + " 개수 " + size + "개 (" + MIN_LIST_SIZE + "~" + MAX_LIST_SIZE + "개)");
        }
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private static <T> List<T> nullSafe(List<T> values) {
        return values == null ? List.of() : values;
    }
}
