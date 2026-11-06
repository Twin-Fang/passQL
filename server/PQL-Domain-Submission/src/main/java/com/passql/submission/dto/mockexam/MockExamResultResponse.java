package com.passql.submission.dto.mockexam;

import com.passql.question.dto.QuestionSchemaTable;
import com.passql.submission.constant.MockExamFailReason;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.constant.MockExamSubmitReason;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 응시 결과: 총점·합격·불합격 이유·문항별 정오 (모두 공개)
 * 과목별 점수·토픽별 정답률·문항 해설·다음에 할 일은 프로 전용 (무료는 비우고 lockedSections 표시)
 */
public record MockExamResultResponse(
    UUID attemptUuid,
    UUID roundUuid,
    int roundNumber,
    String title,
    MockExamSubmitReason submitReason,
    LocalDateTime startedAt,
    LocalDateTime submittedAt,
    @Schema(description = "푼 시간 (초, 시작 ~ 제출, 시험 시간 상한)") long elapsedSeconds,
    int totalScore,
    int maxScore,
    int passScore,
    int correctCount,
    int questionCount,
    boolean isPassed,
    MockExamFailReason failReason,
    List<SubjectResult> subjects,
    List<TopicResult> topics,
    List<QuestionMark> questionMarks,
    List<QuestionReview> reviews,
    @Schema(nullable = true) MockExamNextStep nextStep,
    @Schema(description = "무료 회원 응답에서 뺀 묶음 이름 (MOCK_EXAM_SUBJECT_DETAIL, MOCK_EXAM_REVIEW)")
    List<String> lockedSections
) {

    public record SubjectResult(MockExamSubject subject, String name, int correctCount, int questionCount,
                                int score, int maxScore, int failBelowScore, boolean isFailed) {
    }

    public record TopicResult(UUID topicUuid, String topicName, MockExamSubject subject, int correctCount, int questionCount) {
    }

    public record QuestionMark(int questionNumber, MockExamSubject subject, boolean isAnswered,
                               boolean isCorrect, boolean isFlagged) {
    }

    public record QuestionReview(
        int questionNumber,
        MockExamSubject subject,
        UUID questionUuid,
        @Schema(nullable = true) String topicName,
        String stem,
        @Schema(nullable = true) String schemaDisplay,
        List<QuestionSchemaTable> schemaTables,
        List<MockExamChoice> choices,
        @Schema(nullable = true) String selectedChoiceKey,
        String correctChoiceKey,
        boolean isCorrect,
        @Schema(nullable = true) String explanationSummary
    ) {
    }

    /** 프로 전용 묶음 제거본 (무료 회원 응답) */
    public MockExamResultResponse withoutProSections(List<String> addedLockedSections) {
        List<String> mergedLockedSections = new ArrayList<>(lockedSections);
        mergedLockedSections.addAll(addedLockedSections);
        return new MockExamResultResponse(attemptUuid, roundUuid, roundNumber, title, submitReason, startedAt,
            submittedAt, elapsedSeconds, totalScore, maxScore, passScore, correctCount, questionCount, isPassed,
            failReason, List.of(), List.of(), questionMarks, List.of(), null, mergedLockedSections);
    }

    /** 다음에 할 일 붙이기 */
    public MockExamResultResponse withNextStep(MockExamNextStep plannedNextStep) {
        return new MockExamResultResponse(attemptUuid, roundUuid, roundNumber, title, submitReason, startedAt,
            submittedAt, elapsedSeconds, totalScore, maxScore, passScore, correctCount, questionCount, isPassed,
            failReason, subjects, topics, questionMarks, reviews, plannedNextStep, lockedSections);
    }
}
