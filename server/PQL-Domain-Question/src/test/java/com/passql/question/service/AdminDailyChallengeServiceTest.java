package com.passql.question.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.repository.TopicRepository;
import com.passql.question.dto.DailyChallengeRangeResult;
import com.passql.question.entity.DailyChallenge;
import com.passql.question.entity.Question;
import com.passql.question.repository.DailyChallengeRepository;
import com.passql.question.repository.QuestionRepository;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationEventPublisher;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/** 일일 챌린지 기간 작업·배정 검증 (#617) */
class AdminDailyChallengeServiceTest {

    private final DailyChallengeRepository dailyChallengeRepository = mock(DailyChallengeRepository.class);
    private final QuestionRepository questionRepository = mock(QuestionRepository.class);

    private final AdminDailyChallengeService adminDailyChallengeService = new AdminDailyChallengeService(
            dailyChallengeRepository, questionRepository, mock(TopicRepository.class),
            mock(ApplicationEventPublisher.class), mock(DailyChallengeFallbackWriter.class));

    private Question newQuestion(UUID questionUuid, boolean isActive) {
        Question question = mock(Question.class);
        when(question.getQuestionUuid()).thenReturn(questionUuid);
        when(question.getIsActive()).thenReturn(isActive);
        return question;
    }

    private DailyChallenge newChallenge(LocalDate date, int sortOrder, UUID questionUuid) {
        return DailyChallenge.builder().challengeDate(date).sortOrder(sortOrder).questionUuid(questionUuid).build();
    }

    @Test
    void 하루_배정은_10문제를_넘으면_거부한다() {
        List<UUID> elevenQuestionUuids = IntStream.range(0, 11).mapToObj(index -> UUID.randomUUID()).toList();

        assertThatThrownBy(() -> adminDailyChallengeService.assign(LocalDate.of(2026, 11, 1), elevenQuestionUuids))
                .isInstanceOf(CustomException.class)
                .extracting(error -> ((CustomException) error).getErrorCode())
                .isEqualTo(ErrorCode.DAILY_CHALLENGE_TOO_MANY_QUESTIONS);
    }

    @Test
    void 기간은_시작일이_종료일보다_늦거나_62일을_넘으면_거부한다() {
        LocalDate startDate = LocalDate.of(2026, 11, 1);

        assertThatThrownBy(() -> adminDailyChallengeService.autoAssignRange(startDate, startDate.minusDays(1)))
                .isInstanceOf(CustomException.class);
        assertThatThrownBy(() -> adminDailyChallengeService.autoAssignRange(startDate, startDate.plusDays(62)))
                .isInstanceOf(CustomException.class)
                .extracting(error -> ((CustomException) error).getErrorCode())
                .isEqualTo(ErrorCode.DAILY_CHALLENGE_RANGE_INVALID);
    }

    @Test
    void 복사는_이미_배정된_날짜와_원본_날짜를_건너뛰고_덮어쓰기를_고르면_교체한다() {
        LocalDate sourceDate = LocalDate.of(2026, 11, 1);
        LocalDate assignedDate = LocalDate.of(2026, 11, 2);
        LocalDate emptyDate = LocalDate.of(2026, 11, 3);
        UUID questionUuid = UUID.randomUUID();
        when(dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(sourceDate))
                .thenReturn(List.of(newChallenge(sourceDate, 0, questionUuid)));
        when(dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(assignedDate))
                .thenReturn(List.of(newChallenge(assignedDate, 0, UUID.randomUUID())));
        when(dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(emptyDate)).thenReturn(List.of());
        Question activeQuestion = newQuestion(questionUuid, true);
        when(questionRepository.findById(questionUuid)).thenReturn(Optional.of(activeQuestion));

        DailyChallengeRangeResult skippedResult =
                adminDailyChallengeService.copyAssignment(sourceDate, sourceDate, emptyDate, false);

        // 원본 날짜·이미 배정된 날짜 건너뜀, 빈 날짜만 복사
        assertThat(skippedResult.processedDateCount()).isEqualTo(1);
        assertThat(skippedResult.skippedDateCount()).isEqualTo(2);
        verify(dailyChallengeRepository, never()).deleteByChallengeDate(assignedDate);
        verify(dailyChallengeRepository, times(1)).deleteByChallengeDate(emptyDate);

        DailyChallengeRangeResult overwriteResult =
                adminDailyChallengeService.copyAssignment(sourceDate, assignedDate, emptyDate, true);

        assertThat(overwriteResult.processedDateCount()).isEqualTo(2);
        verify(dailyChallengeRepository, times(1)).deleteByChallengeDate(assignedDate);
        verify(dailyChallengeRepository, times(3)).save(any(DailyChallenge.class));
    }

    @Test
    void 비활성_문제가_섞인_원본은_복사할_수_없다() {
        LocalDate sourceDate = LocalDate.of(2026, 11, 1);
        UUID inactiveQuestionUuid = UUID.randomUUID();
        when(dailyChallengeRepository.findByChallengeDateOrderBySortOrderAsc(sourceDate))
                .thenReturn(List.of(newChallenge(sourceDate, 0, inactiveQuestionUuid)));
        Question inactiveQuestion = newQuestion(inactiveQuestionUuid, false);
        when(questionRepository.findById(inactiveQuestionUuid)).thenReturn(Optional.of(inactiveQuestion));

        assertThatThrownBy(() -> adminDailyChallengeService.copyAssignment(
                sourceDate, sourceDate.plusDays(1), sourceDate.plusDays(2), true))
                .isInstanceOf(CustomException.class)
                .extracting(error -> ((CustomException) error).getErrorCode())
                .isEqualTo(ErrorCode.DAILY_CHALLENGE_QUESTION_INACTIVE);
    }
}
