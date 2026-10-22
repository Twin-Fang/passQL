package com.passql.application.entitlement;

import com.passql.meta.constant.CertType;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.repository.ExamScheduleRepository;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * 회차 패스 만료일 계산: 다음 SQLD 시험일 말일, 14일 이내면 다음 회차, 시험일 없으면 90일, 재구매 연장
 */
class ExamPassExpiryCalculatorTest {

    private static final LocalDate FIRST_EXAM_DATE = LocalDate.of(2026, 11, 16);
    private static final LocalDate SECOND_EXAM_DATE = LocalDate.of(2027, 3, 7);

    private final ExamScheduleRepository examScheduleRepository = mock(ExamScheduleRepository.class);
    private final ExamPassExpiryCalculator calculator = new ExamPassExpiryCalculator(examScheduleRepository);

    // SQLD 시험일 등록 (조회 기준일 이후 가장 가까운 순)
    private void givenSqldExamDates(LocalDate... examDates) {
        when(examScheduleRepository.findFirstByCertTypeAndExamDateGreaterThanEqualOrderByExamDateAsc(
            eq(CertType.SQLD), any(LocalDate.class))).thenAnswer(invocation -> {
                LocalDate baseDate = invocation.getArgument(1);
                return findFirstMatching(examDates, examDate -> !examDate.isBefore(baseDate));
            });
        when(examScheduleRepository.findFirstByCertTypeAndExamDateGreaterThanOrderByExamDateAsc(
            eq(CertType.SQLD), any(LocalDate.class))).thenAnswer(invocation -> {
                LocalDate baseDate = invocation.getArgument(1);
                return findFirstMatching(examDates, examDate -> examDate.isAfter(baseDate));
            });
    }

    private Optional<ExamSchedule> findFirstMatching(LocalDate[] examDates,
                                                    java.util.function.Predicate<LocalDate> condition) {
        return java.util.Arrays.stream(examDates)
            .sorted()
            .filter(condition)
            .findFirst()
            .map(examDate -> {
                ExamSchedule examSchedule = mock(ExamSchedule.class);
                when(examSchedule.getExamDate()).thenReturn(examDate);
                return examSchedule;
            });
    }

    @Test
    void nextExamMoreThan14DaysAway_expiresAtExamDayEnd() {
        givenSqldExamDates(FIRST_EXAM_DATE, SECOND_EXAM_DATE);

        LocalDateTime expiresAt = calculator.calculateExpiresAt(LocalDateTime.of(2026, 10, 22, 12, 0), null);

        assertThat(expiresAt).isEqualTo(LocalDateTime.of(2026, 11, 16, 23, 59, 59));
    }

    @Test
    void nextExamWithin14Days_expiresAtFollowingExam() {
        givenSqldExamDates(FIRST_EXAM_DATE, SECOND_EXAM_DATE);

        LocalDateTime expiresAt = calculator.calculateExpiresAt(LocalDateTime.of(2026, 11, 5, 12, 0), null);

        assertThat(expiresAt).isEqualTo(LocalDateTime.of(2027, 3, 7, 23, 59, 59));
    }

    @Test
    void noUpcomingSqldExam_expiresAfter90Days() {
        // SQLP 만 등록된 상태: SQLD 조회는 빈 결과
        givenSqldExamDates();
        LocalDateTime purchasedAt = LocalDateTime.of(2026, 10, 22, 12, 0);

        LocalDateTime expiresAt = calculator.calculateExpiresAt(purchasedAt, null);

        assertThat(expiresAt).isEqualTo(purchasedAt.plusDays(90));
    }

    @Test
    void activePassRepurchase_extendsToExamAfterCurrentExpiry() {
        givenSqldExamDates(FIRST_EXAM_DATE, SECOND_EXAM_DATE);
        LocalDateTime currentExpiresAt = LocalDateTime.of(2026, 11, 16, 23, 59, 59);

        LocalDateTime expiresAt = calculator.calculateExpiresAt(LocalDateTime.of(2026, 11, 1, 12, 0), currentExpiresAt);

        assertThat(expiresAt).isEqualTo(LocalDateTime.of(2027, 3, 7, 23, 59, 59));
    }
}
