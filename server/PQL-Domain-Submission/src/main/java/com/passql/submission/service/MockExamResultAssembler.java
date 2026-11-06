package com.passql.submission.service;

import com.passql.question.entity.Question;
import com.passql.question.entity.QuestionChoiceSetItem;
import com.passql.question.service.SchemaPreviewParser;
import com.passql.submission.constant.MockExamSubject;
import com.passql.submission.dto.mockexam.MockExamChoice;
import com.passql.submission.dto.mockexam.MockExamResultResponse;
import com.passql.submission.entity.MockExamAnswer;
import com.passql.submission.entity.MockExamAttempt;
import com.passql.submission.entity.MockExamRoundItem;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 채점된 응시 > 결과 응답 (전체본): 과목 점수 > 토픽 정답률 > 정오 번호판 > 문항 해설
 * 프로 전용 묶음 제거·다음에 할 일은 응용 계층이 붙임
 */
public final class MockExamResultAssembler {

    private MockExamResultAssembler() {
    }

    public static MockExamResultResponse assemble(MockExamAttempt attempt, MockExamPaper paper,
                                                  Map<UUID, MockExamAnswer> answerByItemUuid) {
        // 문항별 정오 (채점 때 저장한 값)
        List<MockExamResultResponse.QuestionMark> questionMarks = new ArrayList<>();
        List<MockExamResultResponse.QuestionReview> reviews = new ArrayList<>();
        for (MockExamRoundItem item : paper.items()) {
            MockExamAnswer answer = answerByItemUuid.get(item.getMockExamRoundItemUuid());
            String selectedChoiceKey = answer != null ? answer.getSelectedChoiceKey() : null;
            boolean isCorrect = answer != null && Boolean.TRUE.equals(answer.getIsCorrect());
            boolean isFlagged = answer != null && Boolean.TRUE.equals(answer.getIsFlagged());
            questionMarks.add(new MockExamResultResponse.QuestionMark(item.getQuestionNumber(), item.getSubject(),
                selectedChoiceKey != null, isCorrect, isFlagged));
            reviews.add(toReview(item, paper, selectedChoiceKey, isCorrect));
        }

        return new MockExamResultResponse(
            attempt.getMockExamAttemptUuid(),
            paper.round().getMockExamRoundUuid(),
            paper.round().getRoundNumber(),
            paper.round().getTitle(),
            attempt.getSubmitReason(),
            attempt.getStartedAt(),
            attempt.getSubmittedAt(),
            MockExamTimer.elapsedSeconds(attempt.getStartedAt(), attempt.getSubmittedAt()),
            attempt.getTotalScore(),
            MockExamRule.MAX_SCORE,
            MockExamRule.PASS_SCORE,
            attempt.getCorrectCount(),
            paper.items().size(),
            Boolean.TRUE.equals(attempt.getIsPassed()),
            attempt.getFailReason(),
            toSubjectResults(paper, questionMarks),
            toTopicResults(paper, questionMarks),
            questionMarks,
            reviews,
            null,
            List.of());
    }

    /** 과목 2개: 저장된 채점과 같은 규칙(MockExamGrader)으로 다시 계산 (문항 정오는 저장값) */
    private static List<MockExamResultResponse.SubjectResult> toSubjectResults(
        MockExamPaper paper, List<MockExamResultResponse.QuestionMark> questionMarks) {
        MockExamGrader.MockExamScore score = MockExamGrader.grade(questionMarks.stream()
            .map(mark -> new MockExamGrader.GradedQuestion(mark.subject(), mark.isCorrect()))
            .toList());
        return Arrays.stream(MockExamSubject.values())
            .map(score::subjectScoreOf)
            .map(subjectScore -> new MockExamResultResponse.SubjectResult(
                subjectScore.subject(), subjectScore.subject().getDisplayName(), subjectScore.correctCount(),
                subjectScore.questionCount(), subjectScore.score(), subjectScore.maxScore(),
                MockExamRule.failBelowScoreOf(subjectScore.subject()), subjectScore.isFailed()))
            .toList();
    }

    /** 토픽별 정답 수 (정답률 낮은 순, 같으면 문항 많은 순) */
    private static List<MockExamResultResponse.TopicResult> toTopicResults(
        MockExamPaper paper, List<MockExamResultResponse.QuestionMark> questionMarks) {
        Map<UUID, int[]> correctAndTotalByTopic = new LinkedHashMap<>();
        Map<UUID, MockExamSubject> subjectByTopic = new LinkedHashMap<>();
        for (int index = 0; index < paper.items().size(); index++) {
            MockExamRoundItem roundItem = paper.items().get(index);
            subjectByTopic.putIfAbsent(roundItem.getTopicUuid(), roundItem.getSubject());
            int[] correctAndTotal = correctAndTotalByTopic.computeIfAbsent(roundItem.getTopicUuid(), topicUuid -> new int[2]);
            if (questionMarks.get(index).isCorrect()) {
                correctAndTotal[0]++;
            }
            correctAndTotal[1]++;
        }
        return correctAndTotalByTopic.entrySet().stream()
            .map(entry -> new MockExamResultResponse.TopicResult(entry.getKey(),
                paper.topicNameByUuid().get(entry.getKey()), subjectByTopic.get(entry.getKey()),
                entry.getValue()[0], entry.getValue()[1]))
            .sorted(Comparator
                .comparingDouble((MockExamResultResponse.TopicResult topic) ->
                    (double) topic.correctCount() / topic.questionCount())
                .thenComparing(MockExamResultResponse.TopicResult::questionCount, Comparator.reverseOrder()))
            .toList();
    }

    /** 문항 해설: 보기(정답·근거) + 내 답 + 문제 요약 해설 (미리 저장된 내용만, AI 호출 없음) */
    private static MockExamResultResponse.QuestionReview toReview(MockExamRoundItem item, MockExamPaper paper,
                                                                  String selectedChoiceKey, boolean isCorrect) {
        Question question = paper.questionOf(item);
        List<MockExamChoice> choices = paper.choiceItemsOf(item).stream()
            .map(MockExamResultAssembler::toReviewChoice)
            .toList();
        return new MockExamResultResponse.QuestionReview(
            item.getQuestionNumber(),
            item.getSubject(),
            item.getQuestionUuid(),
            paper.topicNameOf(item),
            question != null ? question.getStem() : "",
            question != null ? question.getSchemaDisplay() : null,
            question != null ? SchemaPreviewParser.parse(question.getSchemaDdl(), question.getSchemaSampleData()) : List.of(),
            choices,
            selectedChoiceKey,
            paper.correctChoiceKeyOf(item),
            isCorrect,
            question != null ? question.getExplanationSummary() : null);
    }

    private static MockExamChoice toReviewChoice(QuestionChoiceSetItem choiceItem) {
        return new MockExamChoice(choiceItem.getChoiceKey(), choiceItem.getKind(), choiceItem.getBody(),
            Boolean.TRUE.equals(choiceItem.getIsCorrect()), choiceItem.getRationale());
    }
}
