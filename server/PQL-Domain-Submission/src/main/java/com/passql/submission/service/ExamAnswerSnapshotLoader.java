package com.passql.submission.service;

import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.examanswer.ExamAnswerGradingRuleResponse;
import com.passql.submission.dto.examanswer.ExamAnswerItemResponse;
import com.passql.submission.dto.examanswer.ExamAnswerRoundResponse;
import com.passql.submission.dto.examanswer.ExamAnswerSubjectRuleResponse;
import com.passql.submission.entity.ExamAnswerItem;
import com.passql.submission.entity.ExamAnswerRound;
import com.passql.submission.repository.ExamAnswerItemRepository;
import com.passql.submission.repository.ExamAnswerSheetRepository;
import com.passql.common.util.ServiceTimeZone;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 회차 집계 만들기: 문항 50개·전체 답안 조회 > 득표 > 표시용 정답 > 참여자 총점 분포
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExamAnswerSnapshotLoader {

    // 개념 태그 구분자 (exam_answer_item.concept_tags)
    private static final String CONCEPT_TAG_DELIMITER = ",";

    private final ExamAnswerItemRepository examAnswerItemRepository;
    private final ExamAnswerSheetRepository examAnswerSheetRepository;

    public ExamAnswerRoundSnapshot load(ExamAnswerRound round) {
        List<ExamAnswerItem> items = examAnswerItemRepository.findAllByExamAnswerRoundUuidOrderByQuestionNoAsc(round.getExamAnswerRoundUuid());
        List<String> sheetAnswers = examAnswerSheetRepository.findAllAnswersByRoundUuid(round.getExamAnswerRoundUuid());

        // 득표 > 문항별 채점 기준·공개 행
        int[][] voteCounts = ExamAnswerKeyResolver.countVotes(sheetAnswers, MockExamRule.TOTAL_QUESTION_COUNT);
        List<ExamAnswerKey> keys = new ArrayList<>(items.size());
        List<ExamAnswerItemResponse> itemResponses = new ArrayList<>(items.size());
        for (ExamAnswerItem item : items) {
            int[] voteCountByChoice = voteCounts[item.getQuestionNo() - 1];
            ExamAnswerKey key = ExamAnswerKeyResolver.resolve(item, voteCountByChoice);
            keys.add(key);
            itemResponses.add(toItemResponse(item, key, voteCountByChoice));
        }

        // 참여자 총점 분포 (표시용 정답 기준, 오름차순)
        int[] ascendingTotalScores = sheetAnswers.stream()
                .filter(answers -> answers != null && answers.length() == MockExamRule.TOTAL_QUESTION_COUNT)
                .mapToInt(answers -> ExamAnswerGrader.calculateTotalScore(answers, keys))
                .sorted()
                .toArray();

        ExamAnswerRoundResponse response = new ExamAnswerRoundResponse(
                round.getCertType().name(), round.getRoundNumber(), round.getTitle(), round.getExamDate(),
                round.getStatus().name(), round.getNotice(), buildGradingRule(), sheetAnswers.size(),
                LocalDateTime.now(ServiceTimeZone.ZONE), List.copyOf(itemResponses));
        return new ExamAnswerRoundSnapshot(round.getExamAnswerRoundUuid(), round.getStatus(), response, List.copyOf(keys),
                ascendingTotalScores);
    }

    private ExamAnswerItemResponse toItemResponse(ExamAnswerItem item, ExamAnswerKey key, int[] voteCountByChoice) {
        Map<String, Integer> tally = new LinkedHashMap<>();
        for (int choice = 1; choice <= ExamAnswerKeyResolver.CHOICE_COUNT; choice++) {
            tally.put(String.valueOf(choice), voteCountByChoice[choice]);
        }
        return new ExamAnswerItemResponse(
                item.getQuestionNo(), item.getSubjectNo(), item.getConceptTitle(), splitConceptTags(item.getConceptTags()),
                item.getTopicCode(), key.answer(), item.getOperatorAnswerStatus().name(),
                ExamAnswerKeyResolver.parseAlternativeAnswers(item.getAlternativeAnswers()), tally,
                ExamAnswerKeyResolver.sumVotes(voteCountByChoice),
                ExamAnswerKeyResolver.calculateAgreementRate(key.answer(), voteCountByChoice), item.getNote());
    }

    private static List<String> splitConceptTags(String conceptTags) {
        if (conceptTags == null || conceptTags.isBlank()) {
            return List.of();
        }
        return Arrays.stream(conceptTags.split(CONCEPT_TAG_DELIMITER))
                .map(String::trim)
                .filter(tag -> !tag.isEmpty())
                .toList();
    }

    /** SQLD 채점 규칙 (MockExamRule·MockExamSubject 원본) */
    public static ExamAnswerGradingRuleResponse buildGradingRule() {
        int subjectOneQuestionCount = MockExamSubject.SUBJECT_ONE.getQuestionCount();
        List<ExamAnswerSubjectRuleResponse> subjects = List.of(
                new ExamAnswerSubjectRuleResponse(1, MockExamSubject.SUBJECT_ONE.getDisplayName(), 1, subjectOneQuestionCount,
                        MockExamRule.maxScoreOf(MockExamSubject.SUBJECT_ONE), MockExamRule.failBelowScoreOf(MockExamSubject.SUBJECT_ONE)),
                new ExamAnswerSubjectRuleResponse(2, MockExamSubject.SUBJECT_TWO.getDisplayName(), subjectOneQuestionCount + 1,
                        MockExamRule.TOTAL_QUESTION_COUNT,
                        MockExamRule.maxScoreOf(MockExamSubject.SUBJECT_TWO), MockExamRule.failBelowScoreOf(MockExamSubject.SUBJECT_TWO)));
        return new ExamAnswerGradingRuleResponse(MockExamRule.TOTAL_QUESTION_COUNT, MockExamRule.POINTS_PER_QUESTION,
                MockExamRule.MAX_SCORE, MockExamRule.PASS_SCORE, MockExamRule.SUBJECT_FAIL_BELOW_PERCENT, subjects);
    }
}
