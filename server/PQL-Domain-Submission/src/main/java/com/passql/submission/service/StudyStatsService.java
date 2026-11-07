package com.passql.submission.service;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.common.util.ServiceTimeZone;
import com.passql.member.repository.MemberRepository;
import com.passql.submission.dto.AccuracyDetailResponse;
import com.passql.submission.dto.HeatmapEntry;
import com.passql.submission.dto.QuestionAttemptRow;
import com.passql.submission.dto.RecentAttemptProjection;
import com.passql.submission.dto.StudyPatternResponse;
import com.passql.submission.repository.StudyStatsQueryRepository;
import com.passql.submission.repository.SubmissionRepository;
import com.passql.submission.util.AccuracyDetailCalculator;
import com.passql.submission.util.StreakCalculator;
import com.passql.submission.util.StudyPatternCalculator;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 프로필 통계 (#909): 학습 패턴(무료), 정답률 상세(프로, 컨트롤러가 판정)
 * 조회 > 순수 계산기 집계, 하루 경계는 KST
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class StudyStatsService {

    private final StudyStatsQueryRepository studyStatsQueryRepository;
    private final SubmissionRepository submissionRepository;
    private final MemberRepository memberRepository;

    /** 학습 패턴: 최근 12주 제출 1회 조회 > 날짜별(4주)·요약·요일·시간대·가장 많은 칸, 전체 학습 날짜 > 학습일 수·최장 연속 */
    public StudyPatternResponse getStudyPattern(UUID memberUuid) {
        assertMemberExists(memberUuid);
        LocalDate today = LocalDate.now(ServiceTimeZone.ZONE);
        LocalDateTime patternSince = today.minusDays(StudyPatternCalculator.PATTERN_WINDOW_DAYS - 1L).atStartOfDay();
        List<RecentAttemptProjection> attempts = studyStatsQueryRepository.findAttemptsSince(memberUuid, patternSince);
        List<Date> studyDates = submissionRepository.findSubmissionDatesByMemberUuid(memberUuid.toString());

        List<HeatmapEntry> dailyRecords = StudyPatternCalculator.toDailyRecords(attempts, today);
        StudyPatternCalculator.RecentStudySummary summary = StudyPatternCalculator.summarize(dailyRecords);
        List<Integer> weekdayCounts = StudyPatternCalculator.toWeekdayAttemptCounts(attempts);
        List<Integer> hourCounts = StudyPatternCalculator.toHourAttemptCounts(attempts);

        return new StudyPatternResponse(
            StudyPatternCalculator.DAILY_WINDOW_DAYS,
            dailyRecords,
            summary.attemptCount(),
            summary.correctCount(),
            summary.studyDayCount(),
            summary.accuracyChangePoints(),
            StudyPatternCalculator.PATTERN_WINDOW_DAYS,
            weekdayCounts,
            hourCounts,
            attempts.size(),
            StudyPatternCalculator.MINIMUM_PATTERN_ATTEMPT_COUNT,
            StudyPatternCalculator.busiestIndexOf(weekdayCounts),
            StudyPatternCalculator.busiestIndexOf(hourCounts),
            studyDates.size(),
            StreakCalculator.calculateLongest(studyDates));
    }

    /** 정답률 상세: 전체 제출 시간순 조회 > 난이도별·오답 정리·주별 남은 오답 */
    public AccuracyDetailResponse getAccuracyDetail(UUID memberUuid) {
        assertMemberExists(memberUuid);
        List<QuestionAttemptRow> rows = studyStatsQueryRepository.findQuestionAttemptRows(memberUuid.toString())
            .stream()
            .map(StudyStatsService::toQuestionAttemptRow)
            .toList();
        return AccuracyDetailCalculator.calculate(rows, LocalDate.now(ServiceTimeZone.ZONE));
    }

    private void assertMemberExists(UUID memberUuid) {
        if (!memberRepository.existsByMemberUuidAndIsDeletedFalse(memberUuid)) {
            throw new CustomException(ErrorCode.MEMBER_NOT_FOUND);
        }
    }

    // 네이티브 행 > 계산 입력 (순서: questionUuid, isCorrect, submittedAt, difficulty, isActive)
    private static QuestionAttemptRow toQuestionAttemptRow(Object[] row) {
        return new QuestionAttemptRow(
            UUID.fromString((String) row[0]),
            (Boolean) row[1],
            toLocalDateTime(row[2]),
            ((Number) row[3]).intValue(),
            (Boolean) row[4]);
    }

    // 드라이버·Hibernate 버전에 따라 Timestamp 또는 LocalDateTime 으로 옴
    private static LocalDateTime toLocalDateTime(Object value) {
        return value instanceof Timestamp timestamp ? timestamp.toLocalDateTime() : (LocalDateTime) value;
    }
}
