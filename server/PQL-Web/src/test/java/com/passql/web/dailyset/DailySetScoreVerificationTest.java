package com.passql.web.dailyset;

import com.passql.application.service.DailySetService;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.member.repository.MemberRepository;
import com.passql.question.dto.DailySetCompleteRequest;
import com.passql.question.dto.DailySetCompleteResponse;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.entity.DailySetSubmission;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.DailySetSubmissionRepository;
import com.passql.submission.entity.Submission;
import com.passql.submission.repository.SubmissionRepository;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/** 리더보드 점수는 클라이언트가 보낸 값이 아니라 서버의 제출 기록으로 계산되어야 한다. */
class DailySetScoreVerificationTest {

    private final DailySetSubmissionRepository dailySetRepo = mock(DailySetSubmissionRepository.class);
    private final SubmissionRepository submissionRepo = mock(SubmissionRepository.class);
    private final DailyChallengeRepository challengeRepo = mock(DailyChallengeRepository.class);
    private final DailySetService service =
            new DailySetService(dailySetRepo, mock(MemberRepository.class), submissionRepo, challengeRepo);

    private final UUID member = UUID.randomUUID();
    private final UUID session = UUID.randomUUID();
    private final UUID q1 = UUID.randomUUID(), q2 = UUID.randomUUID(), q3 = UUID.randomUUID();

    private void todaysSet(UUID... questions) {
        List<DailyChallenge> list = new java.util.ArrayList<>();
        for (UUID q : questions) {
            DailyChallenge c = mock(DailyChallenge.class);
            when(c.getQuestionUuid()).thenReturn(q);
            list.add(c);
        }
        when(challengeRepo.findByChallengeDateOrderBySortOrderAsc(any(LocalDate.class))).thenReturn(list);
        when(dailySetRepo.findByChallengeDateOrderByScore(any())).thenReturn(List.of());
    }

    private Submission sub(UUID question, boolean correct) {
        Submission s = mock(Submission.class);
        when(s.getQuestionUuid()).thenReturn(question);
        when(s.getIsCorrect()).thenReturn(correct);
        return s;
    }

    private void submissions(Submission... subs) {
        when(submissionRepo.findByMemberUuidAndSessionUuidOrderBySubmittedAtAsc(member, session))
                .thenReturn(List.of(subs));
    }

    @Test
    void 클라이언트가_부풀린_점수는_무시하고_서버_기록으로_계산한다() {
        todaysSet(q1, q2, q3);
        submissions(sub(q1, true), sub(q2, false), sub(q3, false));

        DailySetCompleteResponse res = service.complete(member, new DailySetCompleteRequest(3, session));

        assertEquals(1, res.correctCount());
        verify(dailySetRepo).saveAndFlush(argThat((DailySetSubmission s) -> s.getCorrectCount() == 1));
    }

    @Test
    void 같은_문제를_여러_번_제출해도_첫_제출만_인정한다() {
        todaysSet(q1, q2);
        // 처음엔 오답, 같은 세션에서 다시 풀어 정답 — 첫 제출(오답)만 센다
        submissions(sub(q1, false), sub(q1, true), sub(q2, true));

        DailySetCompleteResponse res = service.complete(member, new DailySetCompleteRequest(2, session));

        assertEquals(1, res.correctCount());
    }

    @Test
    void 오늘_세트에_없는_문제의_제출은_세지_않는다() {
        todaysSet(q1);
        submissions(sub(q1, true), sub(UUID.randomUUID(), true), sub(UUID.randomUUID(), true));

        DailySetCompleteResponse res = service.complete(member, new DailySetCompleteRequest(3, session));

        assertEquals(1, res.correctCount());
    }

    @Test
    void 인정할_제출이_없으면_완료할_수_없다() {
        todaysSet(q1);
        submissions();

        CustomException e = assertThrows(CustomException.class,
                () -> service.complete(member, new DailySetCompleteRequest(5, session)));

        assertEquals(ErrorCode.INVALID_REQUEST, e.getErrorCode());
        verify(dailySetRepo, never()).saveAndFlush(any());
    }

    @Test
    void 세션_UUID가_없으면_거절한다() {
        todaysSet(q1);

        CustomException e = assertThrows(CustomException.class,
                () -> service.complete(member, new DailySetCompleteRequest(5, null)));

        assertEquals(ErrorCode.INVALID_REQUEST, e.getErrorCode());
    }

    @Test
    void 이미_완료했으면_기존처럼_중복으로_거절한다() {
        when(dailySetRepo.existsByMemberUuidAndChallengeDate(eq(member), any())).thenReturn(true);

        CustomException e = assertThrows(CustomException.class,
                () -> service.complete(member, new DailySetCompleteRequest(1, session)));

        assertEquals(ErrorCode.DAILY_SET_ALREADY_COMPLETED, e.getErrorCode());
    }
}
