package com.passql.meta.dto;

import com.passql.meta.constant.ExamScheduleSyncFailureReason;
import com.passql.meta.constant.ExamScheduleYearSource;

import java.util.List;

/**
 * 공식 일정 표 해석 결과: 성공(연도·근거·회차 목록) 또는 실패(사유·상세·원문 일부)
 */
public record DataqScheduleParseResult(
        boolean isSuccess,
        Integer scheduleYear,
        ExamScheduleYearSource yearSource,
        List<ParsedExamRound> rounds,
        ExamScheduleSyncFailureReason failureReason,
        String failureDetail,
        String sourceExcerpt
) {
    public static DataqScheduleParseResult success(int scheduleYear, ExamScheduleYearSource yearSource,
                                                   List<ParsedExamRound> rounds) {
        return new DataqScheduleParseResult(true, scheduleYear, yearSource, List.copyOf(rounds), null, null, null);
    }

    public static DataqScheduleParseResult failure(ExamScheduleSyncFailureReason failureReason, String failureDetail,
                                                   String sourceExcerpt) {
        return new DataqScheduleParseResult(false, null, null, List.of(), failureReason, failureDetail, sourceExcerpt);
    }

    /** 마지막(가장 큰) 회차, 회차가 없으면 null */
    public Integer findMaxRound() {
        return rounds.stream().map(ParsedExamRound::round).max(Integer::compare).orElse(null);
    }
}
