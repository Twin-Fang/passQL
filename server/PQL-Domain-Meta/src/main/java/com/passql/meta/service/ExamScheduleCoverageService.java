package com.passql.meta.service;

import com.passql.common.exception.CustomException;
import com.passql.meta.constant.CertType;
import com.passql.meta.dto.ExamCoverage;
import com.passql.meta.dto.ExamCoverage.Level;
import com.passql.meta.entity.ExamSchedule;
import com.passql.meta.repository.ExamScheduleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;

/**
 * 시험 일정 공고 확인 보조 (#411).
 *
 * <p>시험 날짜는 매년 바뀌고 자동으로 가져올 수 없어(공식 공고는 사람이 확인) 관리자가 직접 넣는다.
 * 그래서 "지금 확인해야 하는가"를 알려 주고, 마지막으로 공고를 확인한 날짜를 남긴다.
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ExamScheduleCoverageService {

    /** 공식 시험 일정 공고 페이지 (SQLD·SQLP 모두 데이터자격검정 사이트) */
    public static final String OFFICIAL_SCHEDULE_URL = "https://www.dataq.or.kr/www/accept/schedule.do";
    /** AppSetting 키 — 마지막으로 공고를 확인한 날짜(yyyy-MM-dd) */
    public static final String CHECKED_AT_KEY = "exam.announcement_checked_at";
    /** 등록된 마지막 시험이 이 일수 안으로 다가오면 다음 회차 공고를 확인하라고 알린다 */
    static final int WARN_DAYS = 60;
    /** 마지막 공고 확인이 이 일수보다 오래되면 화면에서 다시 확인을 권한다 */
    public static final int STALE_CHECK_DAYS = 30;

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");

    private final ExamScheduleRepository repository;
    private final AppSettingService appSettingService;

    /** SQLD 는 서비스 대상이라 일정이 없어도 평가하고, 나머지는 일정이 하나라도 있을 때만 평가한다. */
    public List<ExamCoverage> getCoverages() {
        LocalDate today = LocalDate.now(KST);
        return java.util.Arrays.stream(CertType.values())
                .map(type -> evaluate(type, repository.findByCertTypeOrderByRoundAsc(type), today))
                .flatMap(Optional::stream)
                .toList();
    }

    /** 조치가 필요한(WARN·ERROR) 것만 — 대시보드 경고용 */
    public List<ExamCoverage> getAlerts() {
        return getCoverages().stream().filter(ExamCoverage::needsAction).toList();
    }

    /** 순수 계산 — 테스트하기 쉽도록 날짜·목록을 받는다. 평가할 대상이 아니면 empty. */
    static Optional<ExamCoverage> evaluate(CertType type, List<ExamSchedule> schedules, LocalDate today) {
        if (schedules.isEmpty()) {
            if (type != CertType.SQLD) return Optional.empty();
            return Optional.of(new ExamCoverage(type, Level.ERROR,
                    "등록된 시험 일정이 없습니다. 공식 공고를 확인해 회차를 추가하세요.",
                    null, null, null, null, null, null, null));
        }

        ExamSchedule last = schedules.stream().max(Comparator.comparing(ExamSchedule::getExamDate)).orElseThrow();
        Optional<ExamSchedule> next = schedules.stream()
                .filter(s -> !s.getExamDate().isBefore(today))
                .min(Comparator.comparing(ExamSchedule::getExamDate));
        Integer expiredSelected = schedules.stream()
                .filter(s -> Boolean.TRUE.equals(s.getIsSelected()) && s.getExamDate().isBefore(today))
                .map(ExamSchedule::getRound).findFirst().orElse(null);

        long daysLast = ChronoUnit.DAYS.between(today, last.getExamDate());
        Long daysNext = next.map(n -> ChronoUnit.DAYS.between(today, n.getExamDate())).orElse(null);

        Level level;
        String message;
        if (next.isEmpty()) {
            level = Level.ERROR;
            message = "다가오는 시험이 없습니다. 마지막 등록 회차 제" + last.getRound() + "회(" + last.getExamDate()
                    + ")가 이미 지났습니다. 공식 공고를 확인해 새 회차를 추가하세요.";
        } else if (daysLast <= WARN_DAYS) {
            level = Level.WARN;
            message = "마지막 등록 회차 제" + last.getRound() + "회(" + last.getExamDate() + ")가 "
                    + Math.max(daysLast, 0) + "일 남았습니다. 이후 회차가 공고됐는지 확인하고 추가하세요.";
        } else {
            level = Level.OK;
            message = "마지막 등록 회차 제" + last.getRound() + "회(" + last.getExamDate() + ")까지 "
                    + daysLast + "일 남아 있어 당분간 추가할 일정이 없습니다.";
        }

        return Optional.of(new ExamCoverage(type, level, message,
                next.map(ExamSchedule::getRound).orElse(null),
                next.map(ExamSchedule::getExamDate).orElse(null),
                daysNext, last.getRound(), last.getExamDate(), daysLast, expiredSelected));
    }

    /** 마지막으로 공고를 확인한 날짜. 기록이 없거나 형식이 깨졌으면 empty. */
    public Optional<LocalDate> getCheckedAt() {
        try {
            return Optional.of(LocalDate.parse(appSettingService.getString(CHECKED_AT_KEY).trim()));
        } catch (CustomException | java.time.format.DateTimeParseException | NullPointerException e) {
            // 마이그레이션 전이거나 빈 값(최초) — 화면에서 "기록 없음"으로 보여 준다
            return Optional.empty();
        }
    }

    /** 마지막 확인일이 오래됐거나 기록이 없는지 */
    public boolean isCheckStale() {
        LocalDate today = LocalDate.now(KST);
        return getCheckedAt().map(d -> ChronoUnit.DAYS.between(d, today) > STALE_CHECK_DAYS).orElse(true);
    }

    /** "공식 공고를 확인했다"는 기록 — 오늘(KST) 날짜를 저장한다. */
    @Transactional
    public LocalDate markChecked() {
        LocalDate today = LocalDate.now(KST);
        appSettingService.save(CHECKED_AT_KEY, today.toString());
        log.info("[exam-schedule] 공고 확인 기록: {}", today);
        return today;
    }
}
