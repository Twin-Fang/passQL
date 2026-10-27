package com.passql.application.concept.admin;

import com.passql.application.concept.admin.dto.ConceptBundle;
import com.passql.application.concept.admin.dto.ConceptBundleCheckQuestion;
import com.passql.application.concept.admin.dto.ConceptBundleChoice;
import com.passql.application.concept.admin.dto.ConceptBundleItem;
import com.passql.application.concept.admin.dto.ConceptBundleItemIssue;
import com.passql.application.concept.admin.dto.ConceptBundleValidationResult;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.meta.service.concept.ConceptDetailSectionParser;
import com.passql.question.entity.Question;
import com.passql.question.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * 개념 묶음 검증: 개념별 필수 칸·tagKey 형식·중복, 단원 코드, 자세히 문단 형식, 확인 문제 5개·보기 4개·정답 1개, 앵커 연결, 관련 문제 존재
 * 저장 없이 문제 목록만 돌려줌 (전부 모아서 한 번에 보여 주기 위함)
 */
@Component
@RequiredArgsConstructor
public class ConceptBundleValidator {

    // tagKey 형식: 소문자·숫자·하이픈 1~100자
    private static final Pattern TAG_KEY_PATTERN = Pattern.compile("[a-z0-9-]{1,100}");
    // 개념당 확인 문제 수 (설계 7장)
    static final int CHECK_QUESTION_COUNT = 5;
    // 확인 문제당 보기 수
    static final int CHOICE_COUNT = 4;

    private final TopicRepository topicRepository;
    private final QuestionRepository questionRepository;
    private final ConceptDetailSectionParser detailSectionParser;

    /** 묶음 전체 검증 (문제가 없으면 isValid=true) */
    public ConceptBundleValidationResult validate(ConceptBundle bundle) {
        List<ConceptBundleItemIssue> issues = new ArrayList<>();
        if (bundle == null || bundle.concepts() == null || bundle.concepts().isEmpty()) {
            issues.add(new ConceptBundleItemIssue(null, "concepts", "empty bundle"));
            return new ConceptBundleValidationResult(false, issues);
        }
        Set<String> activeTopicCodes = topicRepository.findByIsActiveTrueOrderBySortOrderAsc().stream()
            .map(Topic::getCode)
            .collect(Collectors.toSet());
        Set<String> seenTagKeys = new HashSet<>();

        for (ConceptBundleItem item : bundle.concepts()) {
            validateItem(item, activeTopicCodes, seenTagKeys, issues);
        }
        return new ConceptBundleValidationResult(issues.isEmpty(), issues);
    }

    private void validateItem(ConceptBundleItem item, Set<String> activeTopicCodes, Set<String> seenTagKeys,
                              List<ConceptBundleItemIssue> issues) {
        String tagKey = item.tagKey();

        // 식별·소속 (tagKey 형식·중복, 단원 코드)
        if (tagKey == null || !TAG_KEY_PATTERN.matcher(tagKey).matches()) {
            issues.add(new ConceptBundleItemIssue(tagKey, "tagKey", "must match [a-z0-9-]{1,100}"));
        } else if (!seenTagKeys.add(tagKey)) {
            issues.add(new ConceptBundleItemIssue(tagKey, "tagKey", "duplicate in bundle"));
        }
        if (item.topicCode() == null || !activeTopicCodes.contains(item.topicCode())) {
            issues.add(new ConceptBundleItemIssue(tagKey, "topicCode", "unknown or inactive topic: " + item.topicCode()));
        }

        // 본문 (제목, 핵심만, 자세히 문단 형식)
        if (isBlank(item.title())) {
            issues.add(new ConceptBundleItemIssue(tagKey, "title", "required"));
        }
        if (isBlank(item.coreMd())) {
            issues.add(new ConceptBundleItemIssue(tagKey, "coreMd", "required"));
        }
        Set<String> anchors = Set.of();
        if (isBlank(item.detailMd())) {
            issues.add(new ConceptBundleItemIssue(tagKey, "detailMd", "required"));
        } else {
            try {
                anchors = detailSectionParser.findAnchors(item.detailMd());
            } catch (IllegalArgumentException e) {
                issues.add(new ConceptBundleItemIssue(tagKey, "detailMd", e.getMessage()));
            }
        }

        // 확인 문제 (5개, 순서 1~5 중복 없음, 문제별 검사)
        List<ConceptBundleCheckQuestion> questions = item.checkQuestions() == null ? List.of() : item.checkQuestions();
        if (questions.size() != CHECK_QUESTION_COUNT) {
            issues.add(new ConceptBundleItemIssue(tagKey, "checkQuestions",
                "must be " + CHECK_QUESTION_COUNT + " but was " + questions.size()));
        }
        Set<Integer> seenOrders = new HashSet<>();
        for (ConceptBundleCheckQuestion question : questions) {
            validateCheckQuestion(tagKey, question, anchors, seenOrders, issues);
        }

        // 관련 문제 (존재하는 활성 문제만)
        validateRelatedQuestions(item, issues);
    }

    private void validateCheckQuestion(String tagKey, ConceptBundleCheckQuestion question, Set<String> anchors,
                                       Set<Integer> seenOrders, List<ConceptBundleItemIssue> issues) {
        Integer order = question.sortOrder();
        if (order == null || order < 1 || order > CHECK_QUESTION_COUNT || !seenOrders.add(order)) {
            issues.add(new ConceptBundleItemIssue(tagKey, "checkQuestions.sortOrder", "must be unique 1~5: " + order));
        }
        String where = "question " + order + ": ";
        if (isBlank(question.stem())) {
            issues.add(new ConceptBundleItemIssue(tagKey, "stem", where + "required"));
        }
        if (isBlank(question.explanation())) {
            issues.add(new ConceptBundleItemIssue(tagKey, "explanation", where + "required"));
        }
        if (question.rereadAnchor() == null || !anchors.contains(question.rereadAnchor())) {
            issues.add(new ConceptBundleItemIssue(tagKey, "rereadAnchor",
                where + "anchor not in detailMd: " + question.rereadAnchor()));
        }

        // 보기 (4개, 키 중복 없음, 정답 정확히 1개)
        List<ConceptBundleChoice> choices = question.choices() == null ? List.of() : question.choices();
        Set<String> choiceKeys = choices.stream().map(ConceptBundleChoice::choiceKey).collect(Collectors.toSet());
        long correctCount = choices.stream().filter(choice -> Boolean.TRUE.equals(choice.isCorrect())).count();
        boolean hasBlankBody = choices.stream().anyMatch(choice -> isBlank(choice.body()) || isBlank(choice.choiceKey()));
        if (choices.size() != CHOICE_COUNT || choiceKeys.size() != choices.size() || hasBlankBody) {
            issues.add(new ConceptBundleItemIssue(tagKey, "choices", where + "need 4 choices with unique keys and bodies"));
        }
        if (correctCount != 1) {
            issues.add(new ConceptBundleItemIssue(tagKey, "choices", where + "need exactly 1 correct, was " + correctCount));
        }
    }

    private void validateRelatedQuestions(ConceptBundleItem item, List<ConceptBundleItemIssue> issues) {
        List<UUID> relatedQuestionUuids = item.relatedQuestionUuids() == null ? List.of() : item.relatedQuestionUuids();
        if (relatedQuestionUuids.isEmpty()) {
            return;
        }
        Set<UUID> activeQuestionUuids = questionRepository.findAllById(relatedQuestionUuids).stream()
            .filter(question -> Boolean.TRUE.equals(question.getIsActive()))
            .map(Question::getQuestionUuid)
            .collect(Collectors.toSet());
        relatedQuestionUuids.stream()
            .filter(uuid -> !activeQuestionUuids.contains(uuid))
            .forEach(uuid -> issues.add(new ConceptBundleItemIssue(item.tagKey(), "relatedQuestionUuids",
                "unknown or inactive question: " + uuid)));
    }

    private static boolean isBlank(String text) {
        return text == null || text.isBlank();
    }
}
