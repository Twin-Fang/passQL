package com.passql.meta.dto;

import com.passql.meta.constant.CertType;

import java.time.LocalDate;

/**
 * 시험 일정이 앞으로 얼마나 채워져 있는지 — 관리자가 공식 공고를 확인해야 하는 시점을 알려 준다 (#411).
 *
 * @param nextRound         다가오는 가장 가까운 회차 (없으면 null)
 * @param nextExamDate      그 시험일
 * @param daysUntilNext     그 시험까지 남은 일수
 * @param lastRound         등록된 마지막 회차
 * @param lastExamDate      등록된 마지막 시험일
 * @param daysUntilLast     마지막 등록 시험일까지 남은 일수 (이미 지났으면 음수)
 * @param selectedExpiredRound 관리자가 '선택'한 회차가 이미 지났다면 그 회차 (홈에는 다가오는 시험이 자동 표시된다)
 */
public record ExamCoverage(
        CertType certType,
        Level level,
        String message,
        Integer nextRound,
        LocalDate nextExamDate,
        Long daysUntilNext,
        Integer lastRound,
        LocalDate lastExamDate,
        Long daysUntilLast,
        Integer selectedExpiredRound
) {
    public enum Level { OK, WARN, ERROR }

    /** 관리자가 조치해야 하는 상태인지 (대시보드 경고 대상) */
    public boolean needsAction() {
        return level != Level.OK;
    }
}
