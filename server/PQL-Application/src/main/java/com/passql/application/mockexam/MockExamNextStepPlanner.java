package com.passql.application.mockexam;

import com.passql.ai.constant.AiAnalysisActionType;
import com.passql.ai.dto.AiAnalysisAction;
import com.passql.application.service.statsanalysis.AiAnalysisPlanner;
import com.passql.submission.constant.MockExamFailReason;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.mockexam.MockExamNextStep;
import com.passql.submission.dto.mockexam.MockExamResultResponse;
import com.passql.submission.service.MockExamRule;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * 모의고사 "다음에 할 일" (서버 판정, #861 방식): 1과목 과락 > 2과목 과락 > 총점 미달 > 합격선 근처 > 안정권 순 첫 해당
 * 버튼은 통계 AI 분석 버튼 재사용: 약한 토픽 풀기, 오답 3문제 이상이면 오답 노트
 */
public final class MockExamNextStepPlanner {

    // 합격선 근처 판정: 합격했지만 이 점수 미만 (점)
    static final int NEAR_PASS_LINE_SCORE = 70;
    // 약한 토픽 판정 최소 문항 수 (이번 시험 1문항짜리 토픽은 정답률을 믿지 않음)
    static final int WEAK_TOPIC_MIN_QUESTION_COUNT = 2;
    // 토픽 풀기 버튼 문제 수 (통계 AI 분석과 같은 값)
    static final int PRACTICE_COUNT = 5;
    // 오답 노트 버튼: 틀린 답 3문제 이상, 표시 최대 5
    static final int REVIEW_WRONG_MIN_COUNT = 3;
    static final int REVIEW_WRONG_MAX_COUNT = 5;

    private MockExamNextStepPlanner() {
    }

    public static MockExamNextStep plan(MockExamResultResponse result) {
        Optional<MockExamResultResponse.SubjectResult> failedSubject = result.subjects().stream()
            .filter(MockExamResultResponse.SubjectResult::isFailed)
            .findFirst();
        Optional<MockExamResultResponse.TopicResult> weakestTopic = failedSubject
            .map(subject -> findWeakestTopic(result, subject.subject()))
            .orElseGet(() -> findWeakestTopic(result, null));
        List<AiAnalysisAction> actions = buildActions(result, weakestTopic);

        // 과락 (1과목 먼저: 과목 목록이 1과목부터)
        if (failedSubject.isPresent()) {
            MockExamResultResponse.SubjectResult subject = failedSubject.get();
            String subjectLabel = subject.subject() == MockExamSubject.SUBJECT_ONE ? "1과목" : "2과목";
            return new MockExamNextStep(subjectLabel + " 과락이에요",
                subject.name() + " " + subject.score() + "점, " + subject.failBelowScore() + "점 이상이어야 해요. "
                    + weakestTopicPhrase(weakestTopic, "이 과목") + "부터 다져요", actions);
        }
        if (result.failReason() == MockExamFailReason.TOTAL_SCORE_BELOW) {
            int missingScore = MockExamRule.PASS_SCORE - result.totalScore();
            int missingQuestionCount = (missingScore + MockExamRule.POINTS_PER_QUESTION - 1) / MockExamRule.POINTS_PER_QUESTION;
            return new MockExamNextStep("합격선까지 " + missingScore + "점 남았어요",
                missingQuestionCount + "문제만 더 맞히면 합격이에요. " + weakestTopicPhrase(weakestTopic, "약한 토픽") + "부터 올려요",
                actions);
        }
        if (result.totalScore() < NEAR_PASS_LINE_SCORE) {
            return new MockExamNextStep("합격선에 가까워요",
                "시험장에선 몇 문제 차이로 갈려요. " + weakestTopicPhrase(weakestTopic, "약한 토픽") + " 먼저 보강해 여유를 만들어요",
                actions);
        }
        return new MockExamNextStep("안정권이에요",
            "틀린 문제만 다시 보고 다른 회차로 실전 감각을 유지해요", actions);
    }

    /** 가장 약한 토픽: 과목 지정 시 그 과목만, 2문항 이상 토픽 중 정답률 최저 (결과 토픽 목록이 이미 낮은 순) */
    private static Optional<MockExamResultResponse.TopicResult> findWeakestTopic(MockExamResultResponse result,
                                                                               MockExamSubject subjectOrNull) {
        return result.topics().stream()
            .filter(topic -> topic.questionCount() >= WEAK_TOPIC_MIN_QUESTION_COUNT)
            .filter(topic -> topic.correctCount() < topic.questionCount())
            .filter(topic -> subjectOrNull == null || topic.subject() == subjectOrNull)
            .findFirst();
    }

    private static String weakestTopicPhrase(Optional<MockExamResultResponse.TopicResult> weakestTopic, String fallback) {
        return weakestTopic.map(topic -> AiAnalysisPlanner.toShortTopicName(topic.topicName())).orElse(fallback);
    }

    /** 버튼 최대 2개: 약한 토픽 풀기 > 오답 노트 (답한 문항 중 틀린 것 3개 이상) */
    private static List<AiAnalysisAction> buildActions(MockExamResultResponse result,
                                                       Optional<MockExamResultResponse.TopicResult> weakestTopic) {
        List<AiAnalysisAction> actions = new ArrayList<>();
        weakestTopic.ifPresent(topic -> {
            String shortName = AiAnalysisPlanner.toShortTopicName(topic.topicName());
            actions.add(new AiAnalysisAction(AiAnalysisActionType.PRACTICE_TOPIC, topic.topicUuid(), shortName,
                PRACTICE_COUNT, shortName + " 문제 풀기"));
        });
        long answeredWrongCount = result.questionMarks().stream()
            .filter(mark -> mark.isAnswered() && !mark.isCorrect())
            .count();
        if (answeredWrongCount >= REVIEW_WRONG_MIN_COUNT) {
            actions.add(new AiAnalysisAction(AiAnalysisActionType.REVIEW_WRONG, null, null,
                (int) Math.min(answeredWrongCount, REVIEW_WRONG_MAX_COUNT), "틀린 문제 오답 노트에서 다시 풀기"));
        }
        return actions;
    }
}
