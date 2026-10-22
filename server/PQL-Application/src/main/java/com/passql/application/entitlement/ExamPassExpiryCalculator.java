package com.passql.application.entitlement;

import com.passql.meta.constant.CertType;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.repository.ExamScheduleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.Optional;

/**
 * 회차 패스 만료일 계산: 다음 SQLD 시험일 말일, 14일 이내면 다음 회차, 시험일 없으면 90일
 * 신규 구매 > 구매일 기준, 보유 중 재구매 > 현재 만료일 이후 회차로 연장
 */
@Component
@RequiredArgsConstructor
public class ExamPassExpiryCalculator {

    // 구매일부터 시험일까지 최소 일수 (미만이면 다음 회차까지)
    private static final long MINIMUM_DAYS_BEFORE_EXAM = 14;
    // 예정된 시험일이 없을 때 패스 유효 일수
    private static final long FALLBACK_PASS_DAYS = 90;
    // 만료 시각: 시험일 당일 끝 (KST 로컬)
    private static final LocalTime EXPIRY_TIME_OF_DAY = LocalTime.of(23, 59, 59);

    private final ExamScheduleRepository examScheduleRepository;

    /**
     * 만료일 계산: 보유 여부 확인 > 신규면 14일 규칙 적용, 재구매면 다음 회차로 연장
     * currentExpiresAt 은 없으면 null
     */
    public LocalDateTime calculateExpiresAt(LocalDateTime purchasedAt, LocalDateTime currentExpiresAt) {
        boolean isPassStillActive = currentExpiresAt != null && currentExpiresAt.isAfter(purchasedAt);
        if (isPassStillActive) {
            return calculateRepurchaseExpiresAt(currentExpiresAt);
        }
        return calculateNewPurchaseExpiresAt(purchasedAt);
    }

    /** 신규 구매: 구매일 이후 첫 시험, 14일 미만이면 그다음 시험, 없으면 구매 + 90일 */
    private LocalDateTime calculateNewPurchaseExpiresAt(LocalDateTime purchasedAt) {
        LocalDate purchaseDate = purchasedAt.toLocalDate();
        Optional<ExamSchedule> nextExam = examScheduleRepository
            .findFirstByCertTypeAndExamDateGreaterThanEqualOrderByExamDateAsc(CertType.SQLD, purchaseDate);

        boolean isNextExamTooClose = nextExam.isPresent()
            && ChronoUnit.DAYS.between(purchaseDate, nextExam.get().getExamDate()) < MINIMUM_DAYS_BEFORE_EXAM;
        if (isNextExamTooClose) {
            nextExam = examScheduleRepository
                .findFirstByCertTypeAndExamDateGreaterThanOrderByExamDateAsc(CertType.SQLD, nextExam.get().getExamDate());
        }

        return nextExam
            .map(exam -> exam.getExamDate().atTime(EXPIRY_TIME_OF_DAY))
            .orElseGet(() -> purchasedAt.plusDays(FALLBACK_PASS_DAYS));
    }

    /** 재구매: 현재 만료일 이후 첫 시험 (14일 규칙 없음), 없으면 현재 만료일 + 90일 */
    private LocalDateTime calculateRepurchaseExpiresAt(LocalDateTime currentExpiresAt) {
        return examScheduleRepository
            .findFirstByCertTypeAndExamDateGreaterThanOrderByExamDateAsc(CertType.SQLD, currentExpiresAt.toLocalDate())
            .map(exam -> exam.getExamDate().atTime(EXPIRY_TIME_OF_DAY))
            .orElseGet(() -> currentExpiresAt.plusDays(FALLBACK_PASS_DAYS));
    }
}
