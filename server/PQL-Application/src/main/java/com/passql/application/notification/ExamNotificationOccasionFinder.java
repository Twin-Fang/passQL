package com.passql.application.notification;

import com.passql.member.constant.AutoNotificationRuleType;
import com.passql.meta.constant.CertType;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.repository.ExamScheduleRepository;
import com.passql.meta.service.ExamScheduleSyncService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.function.Function;

/**
 * 시험 일정 자동 알림의 오늘 발송 여부 + 문구 치환 값 (#649 D-day, #991 일정 규칙 5종)
 * 시험 규칙이 아니면 항상 발송 대상(치환 값 없음), 시험 규칙은 오늘이 해당 날짜일 때만
 */
@Component
@RequiredArgsConstructor
public class ExamNotificationOccasionFinder {

    // 시험 D-day 알림을 보내는 남은 일수 3종
    private static final Set<Integer> EXAM_COUNTDOWN_DAYS = Set.of(30, 7, 1);
    // 새 연도 공개 알림 유효 기간 (일): 수집 뒤 이 기간 안의 첫 발송 시각에 1회
    static final int PUBLISHED_ANNOUNCE_WINDOW_DAYS = 7;
    // 문구의 날짜 표기 "3.7(토)"
    private static final DateTimeFormatter MONTH_DAY_FORMAT = DateTimeFormatter.ofPattern("M.d(E)", Locale.KOREAN);

    private final ExamScheduleRepository examScheduleRepository;
    private final ExamScheduleSyncService examScheduleSyncService;

    /**
     * 오늘 발송할 이유 1건
     *
     * @param placeholderValues 문구 치환 값 ("{round}" > "60")
     * @param publishedSyncRunUuid 새 연도 공개 규칙일 때 발송 후 처리할 수집 기록 (그 외 null)
     */
    public record Occasion(Map<String, String> placeholderValues, UUID publishedSyncRunUuid) {
        static Occasion withoutPlaceholders() {
            return new Occasion(Map.of(), null);
        }
    }

    /** 규칙 + 오늘 > 발송 이유 (오늘 보낼 날이 아니면 empty) */
    public Optional<Occasion> findTodayOccasion(AutoNotificationRuleType ruleType, LocalDate today) {
        return switch (ruleType) {
            case EXAM_COUNTDOWN -> findExamCountdownOccasion(today);
            case EXAM_SCHEDULE_PUBLISHED -> findPublishedOccasion(today);
            case EXAM_APPLICATION_OPEN -> findSqldRoundOn(today, ExamSchedule::getApplicationStartDate);
            case EXAM_APPLICATION_CLOSING -> findSqldRoundOn(today.plusDays(1), ExamSchedule::getApplicationEndDate);
            case EXAM_ADMISSION_TICKET -> findSqldRoundOn(today, ExamSchedule::getAdmissionTicketDate);
            case EXAM_RESULT_ANNOUNCED -> findSqldRoundOn(today, ExamSchedule::getResultAnnouncementDate);
            case DAILY_SET_REMINDER, STREAK_RISK, COMEBACK_SHORT, COMEBACK_LONG -> Optional.of(Occasion.withoutPlaceholders());
        };
    }

    /** 발송 뒤 처리: 새 연도 공개는 같은 공개를 다시 알리지 않게 표시 */
    public void markDispatched(Occasion occasion) {
        if (occasion.publishedSyncRunUuid() != null) {
            examScheduleSyncService.markPublishAnnounced(occasion.publishedSyncRunUuid());
        }
    }

    // 가장 가까운 시험의 D-30·D-7·D-1 (자격증 구분 없음)
    private Optional<Occasion> findExamCountdownOccasion(LocalDate today) {
        return examScheduleRepository.findFirstByExamDateGreaterThanEqualOrderByExamDateAsc(today)
                .map(ExamSchedule::getExamDate)
                .map(examDate -> (int) ChronoUnit.DAYS.between(today, examDate))
                .filter(EXAM_COUNTDOWN_DAYS::contains)
                .map(daysLeft -> new Occasion(Map.of("{days}", String.valueOf(daysLeft)), null));
    }

    // 최근 7일 안 수집으로 처음 생긴 연도 중 아직 안 알린 것
    private Optional<Occasion> findPublishedOccasion(LocalDate today) {
        return examScheduleSyncService.findUnannouncedPublishedRun(
                        today.minusDays(PUBLISHED_ANNOUNCE_WINDOW_DAYS).atStartOfDay())
                .map(run -> new Occasion(Map.of("{year}", String.valueOf(run.getPublishedYear())),
                        run.getExamScheduleSyncRunUuid()));
    }

    // SQLD 회차 중 기준 날짜 칸이 targetDate 인 첫 회차
    private Optional<Occasion> findSqldRoundOn(LocalDate targetDate, Function<ExamSchedule, LocalDate> dateGetter) {
        return examScheduleRepository.findByCertTypeOrderByRoundAsc(CertType.SQLD).stream()
                .filter(schedule -> targetDate.equals(dateGetter.apply(schedule)))
                .findFirst()
                .map(ExamNotificationOccasionFinder::toRoundOccasion);
    }

    private static Occasion toRoundOccasion(ExamSchedule schedule) {
        return new Occasion(Map.of(
                "{year}", String.valueOf(schedule.getExamDate().getYear()),
                "{round}", String.valueOf(schedule.getRound()),
                "{examDate}", schedule.getExamDate().format(MONTH_DAY_FORMAT),
                "{applicationEndDate}", schedule.getApplicationEndDate() == null ? ""
                        : schedule.getApplicationEndDate().format(MONTH_DAY_FORMAT)), null);
    }
}
