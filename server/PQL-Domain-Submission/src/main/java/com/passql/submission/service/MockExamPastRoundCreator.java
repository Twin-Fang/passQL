package com.passql.submission.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.entity.Topic;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSet;
import com.passql.question.repository.QuestionRepository;
import com.passql.submission.constant.MockExamRoundStatus;
import com.passql.submission.constant.MockExamRoundType;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.mockexam.AdminMockExamComposeResult;
import com.passql.submission.dto.mockexam.AdminMockExamPastRoundCreateRequest;
import com.passql.submission.entity.MockExamRound;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.repository.MockExamRoundItemRepository;
import com.passql.submission.repository.MockExamRoundRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 기출 복원 회차 생성 (#1079): 문제별 출제 세트·과목 조회 > 구성 검증(MockExamPastRoundRule) > 초안 회차·50문항 저장
 * 공개·공개 검사는 모의고사와 같은 경로 (MockExamRoundAdminService)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MockExamPastRoundCreator {

    // 검증 오류 구분자 (응답 메시지)
    private static final String ERROR_DELIMITER = ", ";

    private final MockExamRoundRepository roundRepository;
    private final MockExamRoundItemRepository roundItemRepository;
    private final QuestionRepository questionRepository;
    private final TopicRepository topicRepository;
    private final MockExamEligibleSetFinder eligibleSetFinder;

    @Transactional
    public AdminMockExamComposeResult create(AdminMockExamPastRoundCreateRequest request) {
        List<UUID> questionUuids = request.questionUuids();
        Map<UUID, QuestionChoiceSet> preferredSetByQuestion = eligibleSetFinder.findPreferredSetByQuestionAmong(
            questionUuids.stream().filter(Objects::nonNull).distinct().toList());
        Map<UUID, Question> questionByUuid = questionRepository.findAllById(preferredSetByQuestion.keySet()).stream()
            .collect(Collectors.toMap(Question::getQuestionUuid, Function.identity()));
        Map<UUID, MockExamSubject> subjectByEligibleQuestionUuid = toSubjectByQuestion(questionByUuid.values());

        // 구성 검증 (회차 번호 중복이면 409, 그 외 400)
        boolean isExamRoundNumberTaken = roundRepository.existsByRoundTypeAndRoundNumber(
            MockExamRoundType.PAST_EXAM, request.examRoundNumber());
        List<String> errors = MockExamPastRoundRule.findCompositionErrors(request.examRoundNumber(),
            isExamRoundNumberTaken, questionUuids, subjectByEligibleQuestionUuid);
        if (!errors.isEmpty()) {
            log.info("[mock exam admin] past round rejected : examRound={}, errors={}", request.examRoundNumber(), errors.size());
            throw new CustomException(isExamRoundNumberTaken ? ErrorCode.MOCK_EXAM_ROUND_NUMBER_DUPLICATED
                : ErrorCode.INVALID_INPUT_VALUE, String.join(ERROR_DELIMITER, errors));
        }

        MockExamRound round = roundRepository.save(MockExamRound.builder()
            .roundNumber(request.examRoundNumber())
            .roundType(MockExamRoundType.PAST_EXAM)
            .examDate(request.examDate())
            .title(request.title().trim())
            .status(MockExamRoundStatus.DRAFT)
            .build());
        List<MockExamRoundItem> items = new ArrayList<>();
        List<String> warnings = new ArrayList<>();
        for (int index = 0; index < questionUuids.size(); index++) {
            int questionNumber = index + 1;
            Question question = questionByUuid.get(questionUuids.get(index));
            QuestionChoiceSet choiceSet = preferredSetByQuestion.get(question.getQuestionUuid());
            // 관리자 고정 세트가 없으면 최신 출제 가능 세트 (응시자마다 같은 보기는 그대로)
            if (!choiceSet.getSource().isCurated()) {
                warnings.add(questionNumber + "번 관리자 고정 보기 세트 없음 (최신 " + choiceSet.getSource() + " 세트 사용)");
            }
            items.add(MockExamRoundItem.builder()
                .mockExamRoundUuid(round.getMockExamRoundUuid())
                .questionNumber(questionNumber)
                .subject(MockExamPastRoundRule.subjectOfQuestionNumber(questionNumber))
                .topicUuid(question.getTopicUuid())
                .questionUuid(question.getQuestionUuid())
                .choiceSetUuid(choiceSet.getChoiceSetUuid())
                .build());
        }
        roundItemRepository.saveAll(items);
        log.info("[mock exam admin] past round created : examRound={}, items={}, warnings={}", request.examRoundNumber(),
            items.size(), warnings.size());
        return new AdminMockExamComposeResult(round.getMockExamRoundUuid(), items.size(), warnings);
    }

    /** 문제 > 과목 (토픽 코드 기준, 토픽 없는 문제는 빠짐 = 출제 불가) */
    private Map<UUID, MockExamSubject> toSubjectByQuestion(Iterable<Question> questions) {
        List<Question> questionList = new ArrayList<>();
        questions.forEach(questionList::add);
        Map<UUID, String> topicCodeByUuid = topicRepository.findAllById(questionList.stream()
                .map(Question::getTopicUuid).filter(Objects::nonNull).distinct().toList()).stream()
            .collect(Collectors.toMap(Topic::getTopicUuid, Topic::getCode));
        Map<UUID, MockExamSubject> subjectByQuestionUuid = new HashMap<>();
        for (Question question : questionList) {
            String topicCode = topicCodeByUuid.get(question.getTopicUuid());
            if (topicCode != null) {
                subjectByQuestionUuid.put(question.getQuestionUuid(), MockExamSubject.fromTopicCode(topicCode));
            }
        }
        return subjectByQuestionUuid;
    }
}
