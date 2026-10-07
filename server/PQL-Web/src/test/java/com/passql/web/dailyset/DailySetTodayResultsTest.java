package com.passql.web.dailyset;

import com.passql.application.service.HomeService;
import com.passql.question.dto.DailySetTodayResponse;
import com.passql.question.dto.QuestionSummary;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.entity.DailySetSubmission;
import com.passql.question.entity.Question;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.DailySetSubmissionRepository;
import com.passql.question.service.QuestionService;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/** 완료한 오늘의 세트를 다시 열면 문제별 정답 여부가 함께 내려와야 한다 (#372). */
class DailySetTodayResultsTest {

    private final QuestionService questionService = mock(QuestionService.class);
    private final DailyChallengeRepository challengeRepo = mock(DailyChallengeRepository.class);
    private final DailySetSubmissionRepository dailySetRepo = mock(DailySetSubmissionRepository.class);
    private final SubmissionRepository submissionRepo = mock(SubmissionRepository.class);
    private final HomeService service = new HomeService(questionService, challengeRepo, dailySetRepo, submissionRepo);

    private final UUID member = UUID.randomUUID();
    private final UUID q1 = UUID.randomUUID(), q2 = UUID.randomUUID();

    private void todaysSet(UUID... questions) {
        List<DailyChallenge> list = new java.util.ArrayList<>();
        for (UUID q : questions) {
            DailyChallenge c = mock(DailyChallenge.class);
            when(c.getQuestionUuid()).thenReturn(q);
            list.add(c);
            Question entity = mock(Question.class);
            when(questionService.getQuestionEntityOrNull(q)).thenReturn(entity);
            QuestionSummary summary = mock(QuestionSummary.class);
            when(summary.questionUuid()).thenReturn(q);
            when(questionService.toSummary(entity)).thenReturn(summary);
        }
        when(challengeRepo.findByChallengeDateOrderBySortOrderAsc(any(LocalDate.class))).thenReturn(list);
    }

    private Optional<Submission> sub(boolean correct) {
        Submission s = mock(Submission.class);
        when(s.getIsCorrect()).thenReturn(correct);
        return Optional.of(s);
    }

    @Test
    void 완료했으면_문제_순서대로_정답여부를_돌려준다() {
        todaysSet(q1, q2);
        DailySetSubmission record = mock(DailySetSubmission.class);
        when(record.getCorrectCount()).thenReturn(1);
        when(record.getCompletedAt()).thenReturn(LocalDateTime.now());
        when(dailySetRepo.existsByMemberUuidAndChallengeDate(eq(member), any())).thenReturn(true);
        when(dailySetRepo.findByMemberUuidAndChallengeDate(eq(member), any())).thenReturn(Optional.of(record));
        // 목은 스터빙 문장 밖에서 미리 만든다(안에서 만들면 Mockito가 미완료 스터빙으로 본다)
        Optional<Submission> correct = sub(true);
        Optional<Submission> wrong = sub(false);
        when(submissionRepo.findFirstByMemberUuidAndQuestionUuidAndSubmittedAtBetweenOrderBySubmittedAtDesc(
                eq(member), eq(q1), any(), any())).thenReturn(correct);
        when(submissionRepo.findFirstByMemberUuidAndQuestionUuidAndSubmittedAtBetweenOrderBySubmittedAtDesc(
                eq(member), eq(q2), any(), any())).thenReturn(wrong);

        DailySetTodayResponse res = service.getToday(member);

        assertTrue(res.alreadyCompleted());
        // 멤버별로 셔플된 questions 순서와 results 순서가 같아야 한다
        for (int i = 0; i < res.questions().size(); i++) {
            boolean expected = res.questions().get(i).questionUuid().equals(q1);
            assertEquals(expected, res.results().get(i));
        }
    }

    @Test
    void 아직_안_풀었으면_results는_null이다() {
        todaysSet(q1, q2);
        when(dailySetRepo.existsByMemberUuidAndChallengeDate(eq(member), any())).thenReturn(false);

        DailySetTodayResponse res = service.getToday(member);

        assertFalse(res.alreadyCompleted());
        assertNull(res.results());
    }
}
