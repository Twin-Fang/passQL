package com.passql.submission.service;

import com.passql.submission.constant.MockExamAttemptStatus;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.constant.MockExamSubmitReason;
import com.passql.submission.entity.MockExamAnswer;
import com.passql.submission.entity.MockExamAttempt;
import com.passql.submission.entity.MockExamRoundItem;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.MockExamAnswerRepository;
import com.passql.submission.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * 응시 채점 (잠근 응시 행에서만 호출): 50문항 답 행 채움 > 정오 > 점수·합격 저장 > 답한 문항 제출 기록
 * 제출 기록은 오답 노트·통계·준비도 재료 (session_uuid = 응시 UUID, 하루 한도 판정에서는 제외)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class MockExamAttemptFinalizer {

    private final MockExamPaperLoader paperLoader;
    private final MockExamAnswerRepository answerRepository;
    private final SubmissionRepository submissionRepository;

    public void finalizeAttempt(MockExamAttempt attempt, MockExamSubmitReason submitReason, LocalDateTime now) {
        MockExamPaper paper = paperLoader.load(attempt.getMockExamRoundUuid());
        Map<UUID, MockExamAnswer> answerByItemUuid = answerRepository
            .findByMockExamAttemptUuid(attempt.getMockExamAttemptUuid())
            .stream()
            .collect(Collectors.toMap(MockExamAnswer::getMockExamRoundItemUuid, Function.identity()));
        // 시간 끝 채점은 마감 시각을 제출 시각으로 (늦게 채점돼도 푼 시간이 90분을 넘지 않게)
        LocalDateTime submittedAt = submitReason == MockExamSubmitReason.TIME_UP && now.isAfter(attempt.getDeadlineAt())
            ? attempt.getDeadlineAt() : now;

        // 문항별 정오 (안 푼 문항도 답 행을 만들어 문항 통계의 '안 고름'으로 셈)
        List<MockExamGrader.GradedQuestion> gradedQuestions = new ArrayList<>();
        List<MockExamAnswer> answersToSave = new ArrayList<>();
        List<Submission> submissions = new ArrayList<>();
        for (MockExamRoundItem item : paper.items()) {
            MockExamAnswer answer = answerByItemUuid.computeIfAbsent(item.getMockExamRoundItemUuid(),
                itemUuid -> newEmptyAnswer(attempt.getMockExamAttemptUuid(), item));
            String correctChoiceKey = paper.correctChoiceKeyOf(item);
            boolean isAnswered = answer.getSelectedChoiceKey() != null;
            boolean isCorrect = isAnswered && answer.getSelectedChoiceKey().equals(correctChoiceKey);
            answer.setIsCorrect(isCorrect);
            answersToSave.add(answer);
            gradedQuestions.add(new MockExamGrader.GradedQuestion(item.getSubject(), isCorrect));
            if (isAnswered) {
                submissions.add(toSubmission(attempt, item, answer, isCorrect, submittedAt));
            }
        }
        answerRepository.saveAll(answersToSave);
        submissionRepository.saveAll(submissions);

        // 점수·합격 고정 저장
        MockExamGrader.MockExamScore score = MockExamGrader.grade(gradedQuestions);
        attempt.setStatus(MockExamAttemptStatus.SUBMITTED);
        attempt.setSubmittedAt(submittedAt);
        attempt.setSubmitReason(submitReason);
        attempt.setCorrectCount(score.correctCount());
        attempt.setSubjectOneCorrectCount(score.subjectScoreOf(MockExamSubject.SUBJECT_ONE).correctCount());
        attempt.setSubjectTwoCorrectCount(score.subjectScoreOf(MockExamSubject.SUBJECT_TWO).correctCount());
        attempt.setTotalScore(score.totalScore());
        attempt.setIsPassed(score.isPassed());
        attempt.setFailReason(score.failReason());
        log.info("[mock exam] graded : attempt={}, reason={}, score={}, passed={}",
            attempt.getMockExamAttemptUuid(), submitReason, score.totalScore(), score.isPassed());
    }

    private static MockExamAnswer newEmptyAnswer(UUID attemptUuid, MockExamRoundItem item) {
        return MockExamAnswer.builder()
            .mockExamAttemptUuid(attemptUuid)
            .mockExamRoundItemUuid(item.getMockExamRoundItemUuid())
            .questionNumber(item.getQuestionNumber())
            .build();
    }

    private static Submission toSubmission(MockExamAttempt attempt, MockExamRoundItem item, MockExamAnswer answer,
                                           boolean isCorrect, LocalDateTime submittedAt) {
        return Submission.builder()
            .memberUuid(attempt.getMemberUuid())
            .questionUuid(item.getQuestionUuid())
            .choiceSetUuid(item.getChoiceSetUuid())
            .sessionUuid(attempt.getMockExamAttemptUuid())
            .questionIndex(item.getQuestionNumber())
            .selectedChoiceKey(answer.getSelectedChoiceKey())
            .isCorrect(isCorrect)
            .submittedAt(submittedAt)
            .build();
    }
}
