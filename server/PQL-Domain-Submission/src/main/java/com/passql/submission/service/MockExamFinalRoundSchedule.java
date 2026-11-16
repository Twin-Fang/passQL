package com.passql.submission.service;

import com.passql.submission.constant.MockExamRoundType;
import com.passql.submission.entity.MockExamRound;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * FINAL 회차 공개 시점 (순수, #1084): 대상 시험일 3일 전부터 목록·응시·학습 허용, 지난 FINAL 은 계속 열림
 * FINAL 이 아닌 회차는 늘 열림
 */
public final class MockExamFinalRoundSchedule {

    // 시험일 며칠 전에 여는지
    public static final int OPEN_DAYS_BEFORE_EXAM = 3;
    // 공개 알림 발송 시각 (KST)
    public static final LocalTime OPEN_NOTIFICATION_TIME = LocalTime.of(9, 0);

    private MockExamFinalRoundSchedule() {
    }

    /** 대상 시험일 > 여는 날 (시험일 - 3일) */
    public static LocalDate toOpenDate(LocalDate examDate) {
        return examDate.minusDays(OPEN_DAYS_BEFORE_EXAM);
    }

    /** 공개 알림 시각 (여는 날 09:00 KST) */
    public static LocalDateTime toOpenNotificationAt(LocalDate examDate) {
        return toOpenDate(examDate).atTime(OPEN_NOTIFICATION_TIME);
    }

    /** 오늘 회원에게 보이는 회차인지 (FINAL 만 여는 날 전 숨김, 시험일 없는 FINAL 은 숨김) */
    public static boolean isOpen(MockExamRound round, LocalDate today) {
        if (round.getRoundType() != MockExamRoundType.FINAL) {
            return true;
        }
        return round.getExamDate() != null && !today.isBefore(toOpenDate(round.getExamDate()));
    }
}
