package com.passql.submission.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.mockexam.AdminMockExamComposeRequest;
import com.passql.submission.dto.mockexam.AdminMockExamComposeResult;
import com.passql.submission.entity.MockExamRound;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.repository.MockExamRoundItemRepository;
import com.passql.submission.repository.MockExamRoundRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 회차 자동 구성: 요청 검증 > 후보 묶음 > 과목별 토픽 비율대로 고르기 > 모자라면 같은 과목 다른 토픽으로 > 초안 저장
 * 문항 번호는 1과목 먼저, 토픽 정렬 순서대로 (실제 시험지 흐름)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MockExamRoundComposer {

    // 제목 최대 길이 (mock_exam_round.title)
    private static final int TITLE_MAX_LENGTH = 100;

    private final MockExamRoundRepository roundRepository;
    private final MockExamRoundItemRepository roundItemRepository;
    private final QuestionRepository questionRepository;
    private final TopicRepository topicRepository;
    private final MockExamEligibleSetFinder eligibleSetFinder;
    private final Random random = new SecureRandom();

    @Transactional
    public AdminMockExamComposeResult compose(AdminMockExamComposeRequest request) {
        validateRequest(request);
        Map<String, Integer> questionCountByTopicCode = request.questionCountByTopicCode() == null
            || request.questionCountByTopicCode().isEmpty()
            ? MockExamComposition.DEFAULT_QUESTION_COUNT_BY_TOPIC_CODE : request.questionCountByTopicCode();
        validateSubjectTotals(questionCountByTopicCode);

        MockExamCandidatePool pool = loadCandidatePool();
        List<String> warnings = new ArrayList<>();
        List<PickedQuestion> pickedQuestions = new ArrayList<>();
        for (MockExamSubject subject : MockExamSubject.values()) {
            pickedQuestions.addAll(pickForSubject(subject, pool, questionCountByTopicCode, warnings));
        }
        long recentlyUsedCount = pickedQuestions.stream()
            .filter(picked -> pool.recentlyUsedQuestionUuids().contains(picked.question().getQuestionUuid()))
            .count();
        if (recentlyUsedCount > 0) {
            warnings.add("최근 3개 회차와 겹친 문제 " + recentlyUsedCount + "개 (토픽 후보 부족)");
        }

        MockExamRound round = roundRepository.save(MockExamRound.builder()
            .roundNumber(request.roundNumber())
            .title(request.title().trim())
            .status(MockExamRoundStatus.DRAFT)
            .build());
        List<MockExamRoundItem> items = new ArrayList<>();
        for (int index = 0; index < pickedQuestions.size(); index++) {
            PickedQuestion picked = pickedQuestions.get(index);
            items.add(MockExamRoundItem.builder()
                .mockExamRoundUuid(round.getMockExamRoundUuid())
                .questionNumber(index + 1)
                .subject(picked.subject())
                .topicUuid(picked.question().getTopicUuid())
                .questionUuid(picked.question().getQuestionUuid())
                .choiceSetUuid(pool.preferredSetByQuestion().get(picked.question().getQuestionUuid()).getChoiceSetUuid())
                .build());
        }
        roundItemRepository.saveAll(items);
        log.info("[mock exam admin] composed : round={}, items={}, warnings={}", request.roundNumber(), items.size(),
            warnings.size());
        return new AdminMockExamComposeResult(round.getMockExamRoundUuid(), items.size(), warnings);
    }

    /** 후보 묶음: 활성 토픽 + 출제 가능 세트가 있는 활성 문제 + 최근 3개 회차(공개·보관) 사용 문제 */
    public MockExamCandidatePool loadCandidatePool() {
        List<Topic> topics = topicRepository.findByIsActiveTrueOrderBySortOrderAsc();
        Map<UUID, QuestionChoiceSet> preferredSetByQuestion = eligibleSetFinder.findPreferredSetByQuestion();
        Map<UUID, Question> questionByUuid = questionRepository.findAllById(preferredSetByQuestion.keySet()).stream()
            .filter(question -> Boolean.TRUE.equals(question.getIsActive()))
            .collect(Collectors.toMap(Question::getQuestionUuid, Function.identity()));
        List<UUID> recentRoundUuids = roundRepository
            .findTop3ByStatusInOrderByRoundNumberDesc(List.of(MockExamRoundStatus.PUBLISHED, MockExamRoundStatus.ARCHIVED))
            .stream().map(MockExamRound::getMockExamRoundUuid).toList();
        Set<UUID> recentlyUsedQuestionUuids = roundItemRepository.findByMockExamRoundUuidIn(recentRoundUuids).stream()
            .map(MockExamRoundItem::getQuestionUuid)
            .collect(Collectors.toSet());
        return new MockExamCandidatePool(topics, preferredSetByQuestion, questionByUuid, recentlyUsedQuestionUuids);
    }

    /** 과목 1개: 토픽별 목표 수 > 모자란 수는 같은 과목 남은 후보에서 채움 */
    private List<PickedQuestion> pickForSubject(MockExamSubject subject, MockExamCandidatePool pool,
                                                Map<String, Integer> questionCountByTopicCode, List<String> warnings) {
        List<Topic> subjectTopics = pool.topics().stream()
            .filter(topic -> MockExamSubject.fromTopicCode(topic.getCode()) == subject)
            .toList();
        Set<UUID> pickedQuestionUuids = new HashSet<>();
        List<PickedQuestion> picked = new ArrayList<>();
        int shortfall = 0;
        for (Topic topic : subjectTopics) {
            int targetCount = questionCountByTopicCode.getOrDefault(topic.getCode(), 0);
            if (targetCount <= 0) {
                continue;
            }
            List<UUID> topicPicks = MockExamQuestionPicker.pick(
                pool.candidatesOf(topic.getTopicUuid(), pickedQuestionUuids), targetCount, random);
            addPicks(topicPicks, subject, pool, pickedQuestionUuids, picked);
            if (topicPicks.size() < targetCount) {
                warnings.add(topic.getCode() + " 토픽 후보 부족: 목표 " + targetCount + ", 고름 " + topicPicks.size());
                shortfall += targetCount - topicPicks.size();
            }
        }

        // 모자란 수: 같은 과목에서 목표가 있는 토픽의 남은 후보로 (목표 0 토픽은 일부러 뺀 것)
        if (shortfall > 0) {
            List<MockExamQuestionPicker.Candidate> restCandidates = subjectTopics.stream()
                .filter(topic -> questionCountByTopicCode.getOrDefault(topic.getCode(), 0) > 0)
                .flatMap(topic -> pool.candidatesOf(topic.getTopicUuid(), pickedQuestionUuids).stream())
                .toList();
            List<UUID> fillPicks = MockExamQuestionPicker.pick(restCandidates, shortfall, random);
            addPicks(fillPicks, subject, pool, pickedQuestionUuids, picked);
            if (fillPicks.size() < shortfall) {
                warnings.add(subject.getDisplayName() + " 출제 가능 문제 부족: " + (shortfall - fillPicks.size()) + "문항 비어 있음");
            }
        }

        // 번호 순서: 토픽 정렬 순서
        Map<UUID, Integer> topicOrder = new HashMap<>();
        for (int index = 0; index < subjectTopics.size(); index++) {
            topicOrder.put(subjectTopics.get(index).getTopicUuid(), index);
        }
        return picked.stream()
            .sorted(Comparator.comparing(
                (PickedQuestion pickedQuestion) -> topicOrder.getOrDefault(pickedQuestion.question().getTopicUuid(), 0)))
            .toList();
    }

    private static void addPicks(List<UUID> questionUuids, MockExamSubject subject, MockExamCandidatePool pool,
                                 Set<UUID> pickedQuestionUuids, List<PickedQuestion> picked) {
        for (UUID questionUuid : questionUuids) {
            pickedQuestionUuids.add(questionUuid);
            picked.add(new PickedQuestion(subject, pool.questionByUuid().get(questionUuid)));
        }
    }

    private void validateRequest(AdminMockExamComposeRequest request) {
        if (request == null || request.roundNumber() == null || request.roundNumber() <= 0) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "회차 번호는 1 이상이어야 합니다.");
        }
        if (request.title() == null || request.title().isBlank() || request.title().trim().length() > TITLE_MAX_LENGTH) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE, "제목은 1~100자여야 합니다.");
        }
        if (roundRepository.existsByRoundNumber(request.roundNumber())) {
            throw new CustomException(ErrorCode.MOCK_EXAM_ROUND_NUMBER_DUPLICATED);
        }
    }

    /** 과목별 합계 = 공식 문항 수 (1과목 10, 2과목 40) */
    private void validateSubjectTotals(Map<String, Integer> questionCountByTopicCode) {
        for (MockExamSubject subject : MockExamSubject.values()) {
            int subjectTotal = questionCountByTopicCode.entrySet().stream()
                .filter(entry -> MockExamSubject.fromTopicCode(entry.getKey()) == subject)
                .mapToInt(entry -> entry.getValue() == null ? 0 : Math.max(0, entry.getValue()))
                .sum();
            if (subjectTotal != subject.getQuestionCount()) {
                throw new CustomException(ErrorCode.INVALID_INPUT_VALUE,
                    subject.getDisplayName() + " 문항 수 합계는 " + subject.getQuestionCount() + "이어야 합니다.");
            }
        }
    }

    private record PickedQuestion(MockExamSubject subject, Question question) {
    }
}
