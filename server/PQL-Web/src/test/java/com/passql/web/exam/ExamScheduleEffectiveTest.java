package com.passql.web.exam;

import com.passql.meta.constant.CertType;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.repository.ExamScheduleRepository;
import com.passql.meta.service.ExamScheduleService;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * 홈 시험 카드에 지난 시험(D+129)이 보이던 문제의 회귀 테스트.
 * 선택된 일정이 지났으면 다가오는 가장 가까운 시험을 써야 한다.
 */
class ExamScheduleEffectiveTest {

    private final ExamScheduleRepository repo = mock(ExamScheduleRepository.class);
    private final ExamScheduleService service = new ExamScheduleService(repo);
    private final LocalDate today = LocalDate.now(ZoneId.of("Asia/Seoul"));

    private ExamSchedule exam(int round, LocalDate date, boolean selected) {
        return ExamSchedule.builder()
                .certType(CertType.SQLD).round(round).examDate(date).isSelected(selected).build();
    }

    @Test
    void 선택된_시험이_아직_안_지났으면_그대로_쓴다() {
        ExamSchedule selected = exam(63, today.plusDays(10), true);
        when(repo.findFirstByIsSelectedTrue()).thenReturn(Optional.of(selected));

        assertEquals(63, service.findEffectiveSchedule().orElseThrow().getRound());
        verify(repo, never()).findFirstByExamDateGreaterThanEqualOrderByExamDateAsc(any());
    }

    @Test
    void 선택된_시험이_오늘이면_그대로_쓴다() {
        when(repo.findFirstByIsSelectedTrue()).thenReturn(Optional.of(exam(62, today, true)));

        assertEquals(62, service.findEffectiveSchedule().orElseThrow().getRound());
    }

    @Test
    void 선택된_시험이_지났으면_다가오는_가장_가까운_시험으로_넘어간다() {
        when(repo.findFirstByIsSelectedTrue()).thenReturn(Optional.of(exam(61, today.minusDays(129), true)));
        when(repo.findFirstByExamDateGreaterThanEqualOrderByExamDateAsc(today))
                .thenReturn(Optional.of(exam(63, today.plusDays(38), false)));

        assertEquals(63, service.findEffectiveSchedule().orElseThrow().getRound());
    }

    @Test
    void 다가오는_시험이_없으면_선택된_일정을_그대로_쓴다() {
        when(repo.findFirstByIsSelectedTrue()).thenReturn(Optional.of(exam(61, today.minusDays(1), true)));
        when(repo.findFirstByExamDateGreaterThanEqualOrderByExamDateAsc(today)).thenReturn(Optional.empty());

        assertEquals(61, service.findEffectiveSchedule().orElseThrow().getRound());
    }

    @Test
    void 선택된_일정이_없으면_다가오는_시험을_쓴다() {
        when(repo.findFirstByIsSelectedTrue()).thenReturn(Optional.empty());
        when(repo.findFirstByExamDateGreaterThanEqualOrderByExamDateAsc(today))
                .thenReturn(Optional.of(exam(63, today.plusDays(5), false)));

        assertEquals(63, service.findEffectiveSchedule().orElseThrow().getRound());
    }
}
